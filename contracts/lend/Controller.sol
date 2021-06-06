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
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IController.sol";
import "./Market.sol";
import "../utils/SafeMath.sol";

contract Controller is IController {
    using SafeMath for uint256;

    address internal _owner;

    mapping (address => bool) internal _markets;
    mapping (address => address) internal _marketsByToken;
    mapping (address => uint) internal _prices;

    address[] internal _marketList;

    uint internal _collateralFactor;
    uint internal _liquidationFactor;
    
    uint public constant MANTISSA = 1e6;


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
    

    function marketListSize() external view returns (uint) {
      return _marketList.length;
    }

    function setCollateralFactor(uint factor) external onlyOwner {
        _collateralFactor = factor;
    }

    function setLiquidationFactor(uint factor) external onlyOwner {
        _liquidationFactor = factor;
    }

    function setPrice(address market, uint price) external onlyOwner {
        require(_markets[market]);

        _prices[market] = price;
    }

    function addMarket(address market) external onlyOwner {
        address marketToken = Market(market).token();
        
        require(_marketsByToken[marketToken] == address(0));
        
        _markets[market] = true;
        _marketsByToken[marketToken] = market;
        _marketList.push(market);
    }
    
    
    function getAccountValues(address account) internal view returns (uint supplyValue, uint borrowValue);

    function getAccountLiquidity(address account) internal view returns (uint) {
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        borrowValue = borrowValue.mul(_collateralFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);

        if (borrowValue < supplyValue)
            liquidity = supplyValue.sub(borrowValue);

        return liquidity;
    }
    
    function checkAccountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity) {
        uint price = _prices[market];
        uint value = price.mul(amount);
        
        return (getAccountLiquidity(account) >= value.mul(2), value);
    }
    
    function checkAccountHealth(address account) external view returns (bool status, uint health) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

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

        (supplyValue, borrowValue) = getAccountValues(borrower);
        require(borrowValue > 0);
        
        uint healthIndex = calculateHealthIndex(supplyValue, borrowValue);
        
        require(healthIndex <= MANTISSA);
        
        uint liquidationValue = amount.mul(price);
        uint liquidationPercentage = liquidationValue.mul(MANTISSA).div(borrowValue);
        uint collateralValue = supplyValue.mul(liquidationPercentage).div(MANTISSA);
        
        collateralAmount = collateralValue.div(collateralPrice);
        
        Market collateralMarket = Market(collateral);
        collateralMarket.transferTo(borrower, liquidator, collateralAmount);
    }
}

