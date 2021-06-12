/**
 *  @Authoer defi3
 * 
 *  No interest
 *  
 * 
 *  Main Update 1, 2021-06-08, support tokenId
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../IMarket.sol";

contract IERC721Market is IMarket {
    event Supply(address user, uint256 tokenId_);
    event Redeem(address user, uint256 tokenId_);
    event Borrow(address user, uint256 tokenId_);
    event PayBorrow(address user, uint256 tokenId_);
    
    function borrow(uint256 tokenId_) external;
    function supply(uint256 tokenId_) external;
    function redeem(uint256 tokenId_) external;
    function payBorrow(uint256 tokenId_) external;

    function transferFrom(address sender, address receiver, uint256 tokenId_) external;
}
