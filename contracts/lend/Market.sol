/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 *  Main Update 1, 2021-05-31, change getCash() to balance()
 * 
 *  Main Update 2, 2021-06-02, add getCurrentBlockNumber()
 * 
 *  Main Update 3, 2021-06-05, update accrueInterest()
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../token/IERC20.sol";
import "./Controller.sol";
import "../utils/SafeMath.sol";

contract Market is IMarket {
    using SafeMath for uint256;

    address public owner;

    IERC20 public token;
    Controller public controller;

    uint public totalSupply;
    uint public supplyIndex;

    uint public accrualBlockNumber;

    uint public totalBorrow;
    uint public borrowIndex;
    uint public baseBorrowRate;
    
    uint public utilizationRateFraction;
    
    uint public blocksPerYear;

    struct SupplySnapshot {
        uint supply;
        uint interestIndex;
    }

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping (address => SupplySnapshot) supplies;
    mapping (address => BorrowSnapshot) borrows;

    uint public constant FACTOR = 1e6;

    event Supply(address user, uint amount);
    event Redeem(address user, uint amount);
    event Borrow(address user, uint amount);
    event PayBorrow(address user, uint amount);
    event LiquidateBorrow(address borrower, uint amount, address liquidator, address collateralMarket, uint collateralAmount);

    constructor(IERC20 _token, uint _baseBorrowAnnualRate, uint _blocksPerYear, uint _utilizationRateFraction) public {
        require(IERC20(_token).totalSupply() >= 0);
        owner = msg.sender;
        token = _token;
        borrowIndex = FACTOR;
        supplyIndex = FACTOR;
        blocksPerYear = _blocksPerYear;
        baseBorrowRate = _baseBorrowAnnualRate.div(_blocksPerYear);
        accrualBlockNumber = block.number;
        utilizationRateFraction = _utilizationRateFraction.div(_blocksPerYear);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }
    
    function setController(Controller _controller) public onlyOwner {
        controller = _controller;
    }

    function balance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function utilizationRate(uint cash, uint borrowed, uint reserves) public pure returns (uint) {
        if (borrowed == 0)
            return 0;

        return borrowed.mul(FACTOR).div(cash.add(borrowed).sub(reserves));
    }

    function getBorrowRate(uint cash, uint borrowed, uint reserves) public view returns (uint) {
        uint ur = utilizationRate(cash, borrowed, reserves);

        return ur.mul(utilizationRateFraction).div(FACTOR).add(baseBorrowRate);
    }

    function getSupplyRate(uint cash, uint borrowed, uint reserves) public view returns (uint) {
        uint borrowRate = getBorrowRate(cash, borrowed, reserves);

        return utilizationRate(cash, borrowed, reserves).mul(borrowRate).div(FACTOR);
    }

    function borrowRatePerBlock() public view returns (uint) {
        return getBorrowRate(balance(), totalBorrow, 0);
    }

    function supplyRatePerBlock() public view returns (uint) {
        return getSupplyRate(balance(), totalBorrow, 0);
    }

    function supplyOf(address user) public view returns (uint) {
        return supplies[user].supply;
    }

    function borrowBy(address user) public view returns (uint) {
        return borrows[user].principal;
    }

    function updatedBorrowBy(address user) public view returns (uint) {
        BorrowSnapshot storage snapshot = borrows[user];

        if (snapshot.principal == 0)
            return 0;

        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return snapshot.principal.mul(newBorrowIndex).div(snapshot.interestIndex);
    }

    function updatedSupplyOf(address user) public view returns (uint) {
        SupplySnapshot storage snapshot = supplies[user];

        if (snapshot.supply == 0)
            return 0;

        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return snapshot.supply.mul(newSupplyIndex).div(snapshot.interestIndex);
    }

    function supply(uint amount) public {
        supplyInternal(msg.sender, amount);

        emit Supply(msg.sender, amount);
    }

    function supplyInternal(address supplier, uint amount) internal {
        // TODO check msg.sender != this
        require(token.transferFrom(supplier, address(this), amount), "No enough tokens");

        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        supplies[supplier].supply = supplies[supplier].supply.add(amount);
        supplies[supplier].interestIndex = supplyIndex;

        totalSupply = totalSupply.add(amount);
    }

    function redeem(uint amount) public {
        redeemInternal(msg.sender, msg.sender, amount);

        uint supplierSupplyValue;
        uint supplierBorrowValue;

        (supplierSupplyValue, supplierBorrowValue) = controller.getAccountValues(msg.sender);

        require(supplierSupplyValue >= supplierBorrowValue.mul(controller.MANTISSA().add(controller.collateralFactor())).div(controller.MANTISSA()));

        emit Redeem(msg.sender, amount);
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal {
        require(token.balanceOf(address(this)) >= amount);

        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        supplies[supplier].interestIndex = supplyIndex;

        require(supplySnapshot.supply >= amount);

        require(token.transfer(receiver, amount), "No enough tokens");

        supplySnapshot.supply = supplySnapshot.supply.sub(amount);

        totalSupply = totalSupply.sub(amount);
    }

    function borrow(uint amount) public {
        require(token.balanceOf(address(this)) >= amount);

        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = borrows[msg.sender];

        if (borrowSnapshot.principal > 0) {
            uint interest = borrowSnapshot.principal.mul(borrowIndex).div(borrowSnapshot.interestIndex).sub(borrowSnapshot.principal);

            borrowSnapshot.principal = borrowSnapshot.principal.add(interest);
            borrowSnapshot.interestIndex = borrowIndex;
        }

        require(controller.getAccountLiquidity(msg.sender) >= controller.prices(address(this)).mul(amount).mul(2), "Not enough account liquidity");

        require(token.transfer(msg.sender, amount), "No enough tokens to borrow");

        borrowSnapshot.principal = borrowSnapshot.principal.add(amount);
        borrowSnapshot.interestIndex = borrowIndex;

        totalBorrow = totalBorrow.add(amount);
        
        emit Borrow(msg.sender, amount);
    }
    
    function getCurrentBlockNumber() public view returns (uint) {
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

    function getUpdatedTotalBorrows() public view returns (uint) {
        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return newTotalBorrows;
    }

    function getUpdatedTotalSupply() public view returns (uint) {
        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return newTotalSupply;
    }

    function payBorrow(uint amount) public {
        uint paid;
        uint additional;
        
        (paid, additional) = payBorrowInternal(msg.sender, msg.sender, amount);
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
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
        totalBorrow = totalBorrow.sub(amount);

        if (additional > 0)
            supplyInternal(payer, additional);
            
        return (amount, additional);
    }
    
    function liquidateBorrow(address borrower, uint amount, IMarket collateralMarket) public {
        require(amount > 0);
        require(borrower != msg.sender);
        
        accrueInterest();
        collateralMarket.accrueInterest();

        uint debt = updatedBorrowBy(borrower);
        
        require(debt >= amount);
        require(token.balanceOf(msg.sender) >= amount);
        
        uint collateralAmount = controller.liquidateCollateral(borrower, msg.sender, amount, collateralMarket);

        uint paid;
        uint additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function transferTo(address sender, address receiver, uint amount) public onlyController {
        require(amount > 0);
        redeemInternal(sender, receiver, amount);
    }
}

