/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/02-erc721-2.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _approved, uint256 _tokenId) external;
}