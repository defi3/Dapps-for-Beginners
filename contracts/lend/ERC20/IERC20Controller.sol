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
 *  Main Update 3, 2021-06-12, add IController
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../IController.sol";

contract IERC20Controller is IController{
    function setPrice(address market, uint price) external;
    function priceOf(address market) external view returns (uint);

    function accountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity_);
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external returns (uint collateralAmount);
}

