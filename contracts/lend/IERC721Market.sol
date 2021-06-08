/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 *  
 * 
 *  Main Update 1, 2021-06-08, support tokenId
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";

contract IERC721Market is IMarket {
    event Supply(address user, uint256 _tokenId);
    event Redeem(address user, uint256 _tokenId);
    event Borrow(address user, uint256 _tokenId);
    event PayBorrow(address user, uint256 _tokenId);
    
    function borrow(uint256 _tokenId) external;
    function supply(uint256 _tokenId) external;
    function redeem(uint256 _tokenId) external;
    function payBorrow(uint256 _tokenId) external;

    function transferTo(address sender, address receiver, uint256 _tokenId) external;
}
