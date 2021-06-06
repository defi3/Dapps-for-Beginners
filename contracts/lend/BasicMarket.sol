/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-02, add getCurrentBlockNumber()
 * 
 *  Main Update 2, 2021-06-05, update accrueInterest()
 * 
 *  Main Update 3, 2021-06-06, inherit Market 
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarketWithInterest.sol";
import "./Market.sol";
import "./Controller.sol";
import "../token/IERC20.sol";
import "../utils/SafeMath.sol";

contract BasicMarket is Market, IMarketWithInterest {
    using SafeMath for uint256;

    uint internal supplyIndex;
    uint internal borrowIndex;
    uint internal baseBorrowRate;
    
    uint internal utilizationRateFraction;
    
    uint internal accrualBlockNumber;
    uint internal blocksPerYear;

    struct SupplySnapshot {
        uint supply;
        uint interestIndex;
    }

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping (address => SupplySnapshot) internal supplies;
    mapping (address => BorrowSnapshot) internal borrows;

    uint public constant FACTOR = 1e6;


    constructor(IERC20 _token, uint _baseBorrowAnnualRate, uint _blocksPerYear, uint _utilizationRateFraction) Market(_token) public {
        borrowIndex = FACTOR;
        supplyIndex = FACTOR;
        blocksPerYear = _blocksPerYear;
        baseBorrowRate = _baseBorrowAnnualRate.div(_blocksPerYear);
        accrualBlockNumber = block.number;
        utilizationRateFraction = _utilizationRateFraction.div(_blocksPerYear);
    }


    function utilizationRate(uint cash, uint borrowed, uint reserves) internal pure returns (uint) {
        if (borrowed == 0)
            return 0;

        return borrowed.mul(FACTOR).div(cash.add(borrowed).sub(reserves));
    }

    function getBorrowRate(uint cash, uint borrowed, uint reserves) internal view returns (uint) {
        uint ur = utilizationRate(cash, borrowed, reserves);

        return ur.mul(utilizationRateFraction).div(FACTOR).add(baseBorrowRate);
    }

    function getSupplyRate(uint cash, uint borrowed, uint reserves) internal view returns (uint) {
        uint borrowRate = getBorrowRate(cash, borrowed, reserves);

        return utilizationRate(cash, borrowed, reserves).mul(borrowRate).div(FACTOR);
    }

    function borrowRatePerBlock() internal view returns (uint) {
        return getBorrowRate(token.balanceOf(address(this)), totalBorrow, 0);
    }

    function supplyRatePerBlock() internal view returns (uint) {
        return getSupplyRate(token.balanceOf(address(this)), totalBorrow, 0);
    }

    function supplyOf(address account) external view returns (uint) {
        return supplies[account].supply;
    }

    function borrowBy(address account) external view returns (uint) {
        return borrows[account].principal;
    }

    function updatedBorrowBy(address account) public view returns (uint) {
        BorrowSnapshot storage snapshot = borrows[account];

        if (snapshot.principal == 0)
            return 0;

        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return snapshot.principal.mul(newBorrowIndex).div(snapshot.interestIndex);
    }

    function updatedSupplyOf(address account) public view returns (uint) {
        SupplySnapshot storage snapshot = supplies[account];

        if (snapshot.supply == 0)
            return 0;

        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return snapshot.supply.mul(newSupplyIndex).div(snapshot.interestIndex);
    }

    function supplyInternal(address supplier, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        supplies[supplier].supply = supplies[supplier].supply.add(amount);
        supplies[supplier].interestIndex = supplyIndex;
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        supplies[supplier].interestIndex = supplyIndex;

        require(supplySnapshot.supply >= amount);

        require(token.transfer(receiver, amount), "No enough tokens");

        supplySnapshot.supply = supplySnapshot.supply.sub(amount);
        
        Controller ctr = Controller(controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.checkAccountHealth(supplier);
        
        require(status);
    }

    function borrowInternal(address borrower, uint amount) internal {
        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = borrows[borrower];

        if (borrowSnapshot.principal > 0) {
            uint interest = borrowSnapshot.principal.mul(borrowIndex).div(borrowSnapshot.interestIndex).sub(borrowSnapshot.principal);

            borrowSnapshot.principal = borrowSnapshot.principal.add(interest);
            borrowSnapshot.interestIndex = borrowIndex;
        }
        
        Controller ctr = Controller(controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.checkAccountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        require(token.transfer(borrower, amount), "No enough tokens to borrow");

        borrowSnapshot.principal = borrowSnapshot.principal.add(amount);
        borrowSnapshot.interestIndex = borrowIndex;
    }
    
    function getCurrentBlockNumber() external view returns (uint) {
        return block.number;
    }

    function accrueInterest() public {
        uint currentBlockNumber = block.number;
        
        if (currentBlockNumber > accrualBlockNumber) {
            (totalBorrow, borrowIndex) = calculateBorrowDataAtBlock(currentBlockNumber);
            (totalSupply, supplyIndex) = calculateSupplyDataAtBlock(currentBlockNumber);

            accrualBlockNumber = currentBlockNumber;
        }
    }

    function calculateBorrowDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalBorrows, uint newBorrowIndex) {
        if (totalBorrow == 0)
            return (totalBorrow, borrowIndex);

        uint blockDelta = newBlockNumber - accrualBlockNumber;

        uint simpleInterestFactor = borrowRatePerBlock().mul(blockDelta);
        uint interestAccumulated = simpleInterestFactor.mul(totalBorrow).div(FACTOR);

        newBorrowIndex = simpleInterestFactor.mul(borrowIndex).div(FACTOR).add(borrowIndex);
        newTotalBorrows = interestAccumulated.add(totalBorrow);
    }

    function calculateSupplyDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalSupply, uint newSupplyIndex) {
        if (totalSupply == 0)
            return (totalSupply, supplyIndex);

        uint blockDelta = newBlockNumber - accrualBlockNumber;

        uint simpleInterestFactor = supplyRatePerBlock().mul(blockDelta);
        uint interestAccumulated = simpleInterestFactor.mul(totalSupply).div(FACTOR);

        newSupplyIndex = simpleInterestFactor.mul(supplyIndex).div(FACTOR).add(supplyIndex);
        newTotalSupply = interestAccumulated.add(totalSupply);
    }

    function getUpdatedTotalBorrows() internal view returns (uint) {
        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return newTotalBorrows;
    }

    function getUpdatedTotalSupply() internal view returns (uint) {
        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return newTotalSupply;
    }

    function payBorrowInternal(address payer, address borrower, uint amount) internal returns (uint paid, uint supplied) {
        accrueInterest();

        BorrowSnapshot storage snapshot = borrows[borrower];

        require(snapshot.principal > 0);

        uint interest = snapshot.principal.mul(borrowIndex).div(snapshot.interestIndex).sub(snapshot.principal);

        snapshot.principal = snapshot.principal.add(interest);
        snapshot.interestIndex = borrowIndex;

        uint additional;

        if (snapshot.principal < amount) {
            additional = amount.sub(snapshot.principal);
            amount = snapshot.principal;
        }

        require(token.transferFrom(payer, address(this), amount), "No enough tokens");

        snapshot.principal = snapshot.principal.sub(amount);

        if (additional > 0)
            supplyInternal(payer, additional);
            
        return (amount, additional);
    }
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external {
        require(amount > 0);
        
        require(borrower != msg.sender);
        
        BasicMarket collateralMarket = BasicMarket(collateral);
        
        accrueInterest();
        collateralMarket.accrueInterest();

        uint debt = updatedBorrowBy(borrower);
        
        require(debt >= amount);
        
        require(token.balanceOf(msg.sender) >= amount);
        
        Controller ctr = Controller(controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
}

