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

    uint internal _supplyIndex;
    uint internal _borrowIndex;
    uint internal _baseBorrowRate;
    
    uint internal _utilizationRateFraction;
    
    uint internal _accrualBlockNumber;
    uint internal _blocksPerYear;

    struct SupplySnapshot {
        uint supply;
        uint interestIndex;
    }

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping (address => SupplySnapshot) internal _supplies;
    mapping (address => BorrowSnapshot) internal _borrows;

    uint public constant FACTOR = 1e6;


    constructor(IERC20 token_, uint baseBorrowAnnualRate_, uint blocksPerYear_, uint utilizationRateFraction_) Market(token_) public {
        _borrowIndex = FACTOR;
        _supplyIndex = FACTOR;
        _blocksPerYear = blocksPerYear_;
        _baseBorrowRate = baseBorrowAnnualRate_.div(blocksPerYear_);
        _accrualBlockNumber = block.number;
        _utilizationRateFraction = utilizationRateFraction_.div(blocksPerYear_);
    }


    function utilizationRate(uint cash, uint borrowed, uint reserves) internal pure returns (uint) {
        if (borrowed == 0)
            return 0;

        return borrowed.mul(FACTOR).div(cash.add(borrowed).sub(reserves));
    }

    function getBorrowRate(uint cash, uint borrowed, uint reserves) internal view returns (uint) {
        uint ur = utilizationRate(cash, borrowed, reserves);

        return ur.mul(_utilizationRateFraction).div(FACTOR).add(_baseBorrowRate);
    }

    function getSupplyRate(uint cash, uint borrowed, uint reserves) internal view returns (uint) {
        uint borrowRate = getBorrowRate(cash, borrowed, reserves);

        return utilizationRate(cash, borrowed, reserves).mul(borrowRate).div(FACTOR);
    }

    function borrowRatePerBlock() internal view returns (uint) {
        return getBorrowRate(_token.balanceOf(address(this)), _totalBorrow, 0);
    }

    function supplyRatePerBlock() internal view returns (uint) {
        return getSupplyRate(_token.balanceOf(address(this)), _totalBorrow, 0);
    }

    function supplyOf(address account) external view returns (uint) {
        return _supplies[account].supply;
    }

    function borrowBy(address account) external view returns (uint) {
        return _borrows[account].principal;
    }

    function updatedBorrowBy(address account) public view returns (uint) {
        BorrowSnapshot storage snapshot = _borrows[account];

        if (snapshot.principal == 0)
            return 0;

        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return snapshot.principal.mul(newBorrowIndex).div(snapshot.interestIndex);
    }

    function updatedSupplyOf(address account) public view returns (uint) {
        SupplySnapshot storage snapshot = _supplies[account];

        if (snapshot.supply == 0)
            return 0;

        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return snapshot.supply.mul(newSupplyIndex).div(snapshot.interestIndex);
    }

    function supplyInternal(address supplier, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].supply = _supplies[supplier].supply.add(amount);
        _supplies[supplier].interestIndex = _supplyIndex;
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].interestIndex = _supplyIndex;

        require(supplySnapshot.supply >= amount);

        require(_token.transfer(receiver, amount), "No enough tokens");

        supplySnapshot.supply = supplySnapshot.supply.sub(amount);
        
        Controller ctr = Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.checkAccountHealth(supplier);
        
        require(status);
    }

    function borrowInternal(address borrower, uint amount) internal {
        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = _borrows[borrower];

        if (borrowSnapshot.principal > 0) {
            uint interest = borrowSnapshot.principal.mul(_borrowIndex).div(borrowSnapshot.interestIndex).sub(borrowSnapshot.principal);

            borrowSnapshot.principal = borrowSnapshot.principal.add(interest);
            borrowSnapshot.interestIndex = _borrowIndex;
        }
        
        Controller ctr = Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.checkAccountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        require(_token.transfer(borrower, amount), "No enough tokens to borrow");

        borrowSnapshot.principal = borrowSnapshot.principal.add(amount);
        borrowSnapshot.interestIndex = _borrowIndex;
    }
    
    function getCurrentBlockNumber() external view returns (uint) {
        return block.number;
    }

    function accrueInterest() public {
        uint currentBlockNumber = block.number;
        
        if (currentBlockNumber > _accrualBlockNumber) {
            (_totalBorrow, _borrowIndex) = calculateBorrowDataAtBlock(currentBlockNumber);
            (_totalSupply, _supplyIndex) = calculateSupplyDataAtBlock(currentBlockNumber);

            _accrualBlockNumber = currentBlockNumber;
        }
    }

    function calculateBorrowDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalBorrows, uint newBorrowIndex) {
        if (_totalBorrow == 0)
            return (_totalBorrow, _borrowIndex);

        uint blockDelta = newBlockNumber - _accrualBlockNumber;

        uint simpleInterestFactor = borrowRatePerBlock().mul(blockDelta);
        uint interestAccumulated = simpleInterestFactor.mul(_totalBorrow).div(FACTOR);

        newBorrowIndex = simpleInterestFactor.mul(_borrowIndex).div(FACTOR).add(_borrowIndex);
        newTotalBorrows = interestAccumulated.add(_totalBorrow);
    }

    function calculateSupplyDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalSupply, uint newSupplyIndex) {
        if (_totalSupply == 0)
            return (_totalSupply, _supplyIndex);

        uint blockDelta = newBlockNumber - _accrualBlockNumber;

        uint simpleInterestFactor = supplyRatePerBlock().mul(blockDelta);
        uint interestAccumulated = simpleInterestFactor.mul(_totalSupply).div(FACTOR);

        newSupplyIndex = simpleInterestFactor.mul(_supplyIndex).div(FACTOR).add(_supplyIndex);
        newTotalSupply = interestAccumulated.add(_totalSupply);
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

        BorrowSnapshot storage snapshot = _borrows[borrower];

        require(snapshot.principal > 0);

        uint interest = snapshot.principal.mul(_borrowIndex).div(snapshot.interestIndex).sub(snapshot.principal);

        snapshot.principal = snapshot.principal.add(interest);
        snapshot.interestIndex = _borrowIndex;

        uint additional;

        if (snapshot.principal < amount) {
            additional = amount.sub(snapshot.principal);
            amount = snapshot.principal;
        }

        require(_token.transferFrom(payer, address(this), amount), "No enough tokens");

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
        
        require(_token.balanceOf(msg.sender) >= amount);
        
        Controller ctr = Controller(_controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
}
