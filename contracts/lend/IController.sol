/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

interface IController {
    function collateralFactor() external view returns (uint);
    function setCollateralFactor(uint factor) external;
    
    function liquidationFactor() external view returns (uint);
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function removeMarket(address market) external returns (bool);
    function size() external view returns (uint);
    function marketOf(address token) external view returns (address);
    function include(address market_) external returns (bool);

    function accountValues(address account) external view returns (uint supplyValue, uint borrowValue);
    function accountHealth(address account) external view returns (bool status, uint index);
}
