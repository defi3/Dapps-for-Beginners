/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";

interface IController {
    function owner() external view returns (address);
    
    function setCollateralFactor(uint factor) external;
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function size() external view returns (uint);
    function marketOf(address token) external view returns (address);
    function setPrice(address market, uint price) external;
    function priceOf(address market) external view returns (uint);

    function checkAccountHealth(address account) external view returns (bool status, uint health);
    function checkAccountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity);
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external returns (uint collateralAmount);
}

