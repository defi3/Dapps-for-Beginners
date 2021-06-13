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
 *  Main Update 4, 2021-06-06, improve naming convention
 * 
 *  Main Update 5, 2021-06-12, move condtions from _supply() to supply(), _borrow() to borrow(), _redeem() to redeem(), _payBorrow() to payBorrow()
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../IMarketFloating.sol";
import "./ERC20Market.sol";
import "./ERC20Controller.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/SafeMath.sol";

contract ERC20MarketFloating is ERC20Market, IMarketFloating {
    using SafeMath for uint256;
    
    uint public constant FACTOR = 1e6;
    
    struct SupplySnapshot {
        uint supply;
        uint interestIndex;
    }

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint internal _supplyIndex;
    uint internal _borrowIndex;
    uint internal _baseBorrowRate;
    
    uint internal _utilizationRateFraction;
    
    uint internal _accrualBlockNumber;
    uint internal _blocksPerYear;

    mapping (address => SupplySnapshot) internal _supplies;
    mapping (address => BorrowSnapshot) internal _borrows;


    constructor(address token_, uint baseBorrowAnnualRate_, uint blocksPerYear_, uint utilizationRateFraction_) ERC20Market(token_) public {
        _borrowIndex = FACTOR;
        _supplyIndex = FACTOR;
        _blocksPerYear = blocksPerYear_;
        _baseBorrowRate = baseBorrowAnnualRate_.div(blocksPerYear_);
        _accrualBlockNumber = block.number;
        _utilizationRateFraction = utilizationRateFraction_.div(blocksPerYear_);
    }


    function utilizationRate(uint balance_, uint totalBorrow_, uint reserve_) public pure returns (uint) {
        if (totalBorrow_ == 0)
            return 0;

        return totalBorrow_.mul(FACTOR).div(balance_.add(totalBorrow_).sub(reserve_));
    }

    function borrowRate(uint balance_, uint totalBorrow_, uint reserve_) public view returns (uint) {
        uint ur = utilizationRate(balance_, totalBorrow_, reserve_);

        return ur.mul(_utilizationRateFraction).div(FACTOR).add(_baseBorrowRate);
    }

    function supplyRate(uint balance_, uint totalBorrow_, uint reserve_) public view returns (uint) {
        uint borrowRate__ = borrowRate(balance_, totalBorrow_, reserve_);

        return utilizationRate(balance_, totalBorrow_, reserve_).mul(borrowRate__).div(FACTOR);
    }

    function borrowRatePerBlock() public view returns (uint) {
        return borrowRate(balance(), _totalBorrow, 0);
    }

    function supplyRatePerBlock() public view returns (uint) {
        return supplyRate(balance(), _totalBorrow, 0);
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

    function _supply(address supplier, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].supply = _supplies[supplier].supply.add(amount);
        _supplies[supplier].interestIndex = _supplyIndex;
    }

    function _redeem(address supplier, uint amount) internal {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].interestIndex = _supplyIndex;

        require(supplySnapshot.supply >= amount);

        supplySnapshot.supply = supplySnapshot.supply.sub(amount);
        
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.accountHealth(supplier);
        
        require(status);
    }

    function _borrow(address borrower, uint amount) internal {
        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = _borrows[borrower];

        if (borrowSnapshot.principal > 0) {
            uint interest = borrowSnapshot.principal.mul(_borrowIndex).div(borrowSnapshot.interestIndex).sub(borrowSnapshot.principal);

            borrowSnapshot.principal = borrowSnapshot.principal.add(interest);
            borrowSnapshot.interestIndex = _borrowIndex;
        }
        
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.accountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        borrowSnapshot.principal = borrowSnapshot.principal.add(amount);
        borrowSnapshot.interestIndex = _borrowIndex;
    }
    
    
    function blockNumber() external view returns (uint) {
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

    function _payBorrow(address payer, address borrower, uint amount) internal returns (uint paid, uint additional_) {
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

        snapshot.principal = snapshot.principal.sub(amount);

        if (additional > 0)
            _supply(payer, additional);
            
        return (amount, additional);
    }
    
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external minimum(amount) {
        require(borrower != msg.sender);
        
        ERC20MarketFloating collateralMarket = ERC20MarketFloating(collateral);
        
        accrueInterest();
        collateralMarket.accrueInterest();

        uint debt = updatedBorrowBy(borrower);
        
        require(debt >= amount);
        
        require(IERC20(_token).balanceOf(msg.sender) >= amount);
        
        ERC20Controller ctr = ERC20Controller(_controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = _payBorrow(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
}

