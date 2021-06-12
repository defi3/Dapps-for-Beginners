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
 *  Main Update 2, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../IMarket.sol";

contract IERC20Market is IMarket {
    event Supply(address user, uint amount);
    event Redeem(address user, uint amount);
    event Borrow(address user, uint amount);
    event PayBorrow(address user, uint amount);
    
    event LiquidateBorrow(address borrower, uint amount, address liquidator, address collateral, uint collateralAmount);
    
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    
    function borrow(uint amount) external;
    function supply(uint amount) external;
    function redeem(uint amount) external;
    function payBorrow(uint amount) external;
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external;
    function transferFrom(address from, address to, uint amount) external;
}

