/**
 *  Source: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";

interface IController {
    function setCollateralFactor(uint factor) external;
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function marketListSize() external view returns (uint);
    function setPrice(address market, uint price) external;

    function getAccountValues(address account) external view returns (uint supplyValue, uint borrowValue);
    function getAccountHealth(address account) external view returns (uint);
    function checkAccountHealth(address account) external view returns (bool);
    function getAccountLiquidity(address account) external view returns (uint);
    function checkAccountLiquidity(address account, address market, uint amount) external view returns (bool);
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, IMarket collateralMarket) external returns (uint collateralAmount);
}

