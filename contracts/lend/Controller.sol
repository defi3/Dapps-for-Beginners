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

    address public owner;

    mapping (address => bool) public markets;
    mapping (address => address) public marketsByToken;
    mapping (address => uint) public prices;

    address[] public marketList;

    uint public collateralFactor;
    uint public liquidationFactor;
    
    uint public constant MANTISSA = 1e6;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMarket() {
        require(markets[msg.sender]);
        _;
    }

    function marketListSize() external view returns (uint) {
      return marketList.length;
    }

    function setCollateralFactor(uint factor) external onlyOwner {
        collateralFactor = factor;
    }

    function setLiquidationFactor(uint factor) external onlyOwner {
        liquidationFactor = factor;
    }

    function setPrice(address market, uint price) external onlyOwner {
        require(markets[market]);

        prices[market] = price;
    }

    function addMarket(address market) external onlyOwner {
        address marketToken = IMarket(market).token();
        require(marketsByToken[marketToken] == address(0));
        markets[market] = true;
        marketsByToken[marketToken] = market;
        marketList.push(market);
    }
    
    
    function getAccountValues(address account) internal view returns (uint supplyValue, uint borrowValue);

    function getAccountLiquidity(address account) internal view returns (uint) {
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        borrowValue = borrowValue.mul(collateralFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);

        if (borrowValue < supplyValue)
            liquidity = supplyValue.sub(borrowValue);

        return liquidity;
    }
    
    function checkAccountLiquidity(address account, address market, uint amount) external view returns (bool) {
        uint price = prices[market];
        uint value = price.mul(amount);
        return (getAccountLiquidity(account) >= value.mul(2));
    }

    function getAccountHealth(address account) internal view returns (uint) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        return calculateHealthIndex(supplyValue, borrowValue);
    }
    
    function checkAccountHealth(address account) external view returns (bool) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        return supplyValue >= borrowValue.mul(MANTISSA.add(collateralFactor).div(MANTISSA));
    }
    
    function calculateHealthIndex(uint supplyValue, uint borrowValue) internal view returns (uint) {
        if (supplyValue == 0 || borrowValue == 0)
            return 0;

        borrowValue = borrowValue.mul(liquidationFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);
        
        return supplyValue.mul(MANTISSA).div(borrowValue);
    }
    
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external onlyMarket returns (uint collateralAmount)  {
        uint price = prices[msg.sender];        
        require(price > 0);

        uint collateralPrice = prices[collateral];        
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

