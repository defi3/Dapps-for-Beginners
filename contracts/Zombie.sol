/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./utils/Ownable.sol";
import "./token/IERC721.sol";

contract Zombie is Ownable, IERC721 {
    struct ZData {
        string name;
        uint dna;
    }
    
    ZData[] public zombies;
    
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerToCount;
    
    mapping (uint => address) approvals;
    
    event NewZombie(uint _tokenId, string name, uint dna);
    
    function balanceOf(address _owner) external view returns (uint256) {
        return ownerToCount[_owner];
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (zombieToOwner[_tokenId] == msg.sender || approvals[_tokenId] == msg.sender);
        
        _transfer(_from, _to, _tokenId);
    }
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownerToCount[_to]++;
        ownerToCount[_from]--;
        zombieToOwner[_tokenId] = _to;
        
        emit Transfer(_from, _to, _tokenId);
    }
    
    function approve(address _approved, uint256 _tokenId) external payable {
        require (zombieToOwner[_tokenId] == msg.sender);
        
        approvals[_tokenId] = _approved;
    }
}