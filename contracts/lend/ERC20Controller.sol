/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 * 
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 2, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 3, 2021-06-06, improve naming convention
 * 
 * 
 *  To-do: It currenlty uses three mapping: _markets, _marketsByToken, _prices and one array: _marketList for markets. Please optimize this part.
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IController.sol";
import "./ERC20Market.sol";
import "../utils/SafeMath.sol";

contract ERC20Controller is IController {
    using SafeMath for uint256;
    
    uint public constant MANTISSA = 1e6;

    address internal _owner;
    
    uint internal _collateralFactor;
    uint internal _liquidationFactor;

    mapping (address => bool) internal _markets;
    mapping (address => address) internal _marketsByToken;
    mapping (address => uint) internal _prices;
    address[] internal _marketList;


    constructor() public {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyMarket() {
        require(_markets[msg.sender]);
        _;
    }
    
    function owner() external view returns (address) {
        return _owner;
    }
    
    
    function collateralFactor() external view returns (uint) {
        return _collateralFactor;
    }
    
    function setCollateralFactor(uint factor) external onlyOwner {
        _collateralFactor = factor;
    }

    function liquidationFactor() external view returns (uint) {
        return _liquidationFactor;
    }
    
    function setLiquidationFactor(uint factor) external onlyOwner {
        _liquidationFactor = factor;
    }
    

    function addMarket(address market) external onlyOwner {
        address token = ERC20Market(market).token();
        
        require(_marketsByToken[token] == address(0));
        
        _markets[market] = true;
        _marketsByToken[token] = market;
        _marketList.push(market);
    }
    
    function size() external view returns (uint) {
      return _marketList.length;
    }
    
    function marketOf(address token) external view returns (address) {
        return _marketsByToken[token];
    }
    

    function setPrice(address market, uint price) external onlyOwner {
        require(_markets[market]);

        _prices[market] = price;
    }
    
    function priceOf(address market) external view returns (uint) {
        return _prices[market];
    }
    
    
    // for testing and UI
    function accountValues(address account) public view returns (uint supplyValue, uint borrowValue) {
        return accountValuesInternal(account);
    }
    
    function accountValuesInternal(address account) internal view returns (uint supplyValue, uint borrowValue);

   
   // called by borrowInternal() in Market 
    function accountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity_) {
        uint liquidity = accountLiquidityInternal(account);
        
        return (liquidity >= _prices[market].mul(amount).mul(2), liquidity);
    }
    
    function accountLiquidityInternal(address account) internal view returns (uint) {
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = accountValuesInternal(account);

        borrowValue = borrowValue.mul(_collateralFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);

        if (borrowValue < supplyValue)
            liquidity = supplyValue.sub(borrowValue);

        return liquidity;
    }
    
    
    function accountHealth(address account) external view returns (bool status, uint index) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = accountValuesInternal(account);

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

        (supplyValue, borrowValue) = accountValuesInternal(borrower);
        require(borrowValue > 0);
        
        uint healthIndex = calculateHealthIndex(supplyValue, borrowValue);
        
        require(healthIndex <= MANTISSA);
        
        uint liquidationValue = amount.mul(price);
        uint liquidationPercentage = liquidationValue.mul(MANTISSA).div(borrowValue);
        uint collateralValue = supplyValue.mul(liquidationPercentage).div(MANTISSA);
        
        collateralAmount = collateralValue.div(collateralPrice);
        
        ERC20Market collateralMarket = ERC20Market(collateral);
        collateralMarket.transferTo(borrower, liquidator, collateralAmount);
    }
}

