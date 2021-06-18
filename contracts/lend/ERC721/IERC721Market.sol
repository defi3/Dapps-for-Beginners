/**
 *  SPDX-License-Identifier: MIT
 * 
 *  @Authoer defi3
 * 
 *  No interest
 *  
 * 
 *  Creation, 2021-06
 * 
 *  Main Update 1, 2021-06-08, support tokenId
 * 
 *  Main Update 2, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "../IMarket.sol";

interface IERC721Market is IMarket {
    event Supply(address user, uint256 tokenId_);
    event Redeem(address user, uint256 tokenId_);
    event Borrow(address user, uint256 tokenId_);
    event PayBorrow(address user, uint256 tokenId_);
    
    function supplyOf(address account) external view returns (uint[] memory);
    function borrowBy(address account) external view returns (uint[] memory);
    
    function borrow(uint256 tokenId_) external;
    function supply(uint256 tokenId_) external;
    function redeem(uint256 tokenId_) external;
    function payBorrow(uint256 tokenId_) external;

    function transferFrom(address from, address to, uint256 tokenId_) external;
}
