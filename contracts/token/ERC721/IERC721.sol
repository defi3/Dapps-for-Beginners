/**
 *  SPDX-License-Identifier: MIT
 *
 * 
 *  Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/02-erc721-2.md
 * 
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-06
 * 
 */
pragma solidity ^0.8.0;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId_);
    event Approval(address indexed owner_, address indexed to, uint256 indexed tokenId_);

    function balanceOf(address owner_) external view returns (uint256);
    function ownerOf(uint256 tokenId_) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId_) external;
    function approve(address to, uint256 tokenId_) external;
}