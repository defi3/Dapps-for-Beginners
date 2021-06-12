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

interface IController {
    function collateralFactor() external view returns (uint);
    function setCollateralFactor(uint factor) external;
    
    function liquidationFactor() external view returns (uint);
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function size() external view returns (uint);
    function marketOf(address token) external view returns (address);

    function accountValues(address account) external view returns (uint supplyValue, uint borrowValue);
    function accountHealth(address account) external view returns (bool status, uint index);
}