/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 *  
 * 
 *  Main Update 1, 2021-06-06, add events
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IController.sol";

interface IMarket {
    function setController(address controller) external;
    
    function token() external view returns (address);
    function balance() external view returns (uint);
    
    function borrow(uint amount) external;
    function supply(uint amount) external;
    function redeem(uint amount) external;
    function payBorrow(uint amount) external;
    
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external;
    function transferTo(address sender, address receiver, uint amount) external;
    
    event Supply(address user, uint amount);
    event Redeem(address user, uint amount);
    event Borrow(address user, uint amount);
    event PayBorrow(address user, uint amount);
    
    event LiquidateBorrow(address borrower, uint amount, address liquidator, address collateral, uint collateralAmount);
}

