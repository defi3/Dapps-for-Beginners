/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IController.sol";

interface IMarket {
    function setController(IController controller) external;
    
    function token() external view returns (address);
    function balance() external view returns (uint);
    
    function borrow(uint amount) external;
    function supply(uint amount) external;
    function redeem(uint amount) external;
    function payBorrow(uint amount) external;
    
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
    
    function liquidateBorrow(address borrower, uint amount, IMarket collateralMarket) external;
    function transferTo(address sender, address receiver, uint amount) external;
}

