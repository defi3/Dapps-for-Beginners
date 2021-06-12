/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 2, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 3, 2021-06-06, improve naming convention
 * 
 *  Main Update 4, 2021-06-12, add Controller for inheritance
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../Controller.sol";
import "./IERC20Controller.sol";
import "./ERC20Market.sol";
import "../../utils/SafeMath.sol";

contract ERC20Controller is Controller, IERC20Controller {
    using SafeMath for uint256;

    mapping (address => uint) internal _prices;


    constructor() Controller() public {
    }
    

    function setPrice(address market, uint price) external onlyOwner {
        require(_markets.include(market), "ERC20Controller::setPrice: market is not added");

        _prices[market] = price;
    }
    
    function priceOf(address market) external view returns (uint) {
        return _prices[market];
    }
    
    
    // for testing and UI
    function accountValues(address account) public view returns (uint supplyValue, uint borrowValue) {
        return _accountValues(account);
    }
    
    function _accountValues(address account) internal view returns (uint supplyValue, uint borrowValue);

   
   // called by borrowInternal() in Market 
    function accountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity_) {
        uint liquidity = _accountLiquidity(account);
        
        return (liquidity >= _prices[market].mul(amount).mul(2), liquidity);
    }
    
    function _accountLiquidity(address account) internal view returns (uint) {
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(account);

        borrowValue = borrowValue.mul(_collateralFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);

        if (borrowValue < supplyValue)
            liquidity = supplyValue.sub(borrowValue);

        return liquidity;
    }
    
    
    function accountHealth(address account) external view returns (bool status, uint index) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(account);

        return (supplyValue >= borrowValue.mul(MANTISSA.add(_collateralFactor).div(MANTISSA)), calculateHealthIndex(supplyValue, borrowValue));
    }
    
    function calculateHealthIndex(uint supplyValue, uint borrowValue) internal view returns (uint) {
        if (supplyValue == 0 || borrowValue == 0)
            return 0;

        borrowValue = borrowValue.mul(_liquidationFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);
        
        return supplyValue.mul(MANTISSA).div(borrowValue);
    }
    
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external onlyMarket returns (uint collateralAmount)  {
        uint price = _prices[msg.sender];        
        require(price > 0);

        uint collateralPrice = _prices[collateral];        
        require(collateralPrice > 0);
        
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(borrower);
        require(borrowValue > 0);
        
        uint healthIndex = calculateHealthIndex(supplyValue, borrowValue);
        
        require(healthIndex <= MANTISSA);
        
        uint liquidationValue = amount.mul(price);
        uint liquidationPercentage = liquidationValue.mul(MANTISSA).div(borrowValue);
        uint collateralValue = supplyValue.mul(liquidationPercentage).div(MANTISSA);
        
        collateralAmount = collateralValue.div(collateralPrice);
        
        ERC20Market collateralMarket = ERC20Market(collateral);
        collateralMarket.transferFrom(borrower, liquidator, collateralAmount);
    }
}

