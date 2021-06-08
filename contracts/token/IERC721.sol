/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/02-erc721-2.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId_);
    event Approval(address indexed owner_, address indexed spender, uint256 indexed tokenId_);

    function balanceOf(address owner_) external view returns (uint256);
    function ownerOf(uint256 tokenId_) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId_) external;
    function approve(address to, uint256 tokenId_) external;
}