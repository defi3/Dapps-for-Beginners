/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";

interface IController {
    function owner() external view returns (address);
    
    function setCollateralFactor(uint factor) external;
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function marketListSize() external view returns (uint);
    function setPrice(address market, uint price) external;

    function checkAccountHealth(address account) external view returns (bool status, uint health);
    function checkAccountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity);
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external returns (uint collateralAmount);
}

