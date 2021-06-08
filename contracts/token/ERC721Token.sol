/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../utils/Ownable.sol";
import "./IERC721.sol";

contract ERC721Token is Ownable(), IERC721 {
    mapping (uint => address) internal owners;
    
    mapping (address => uint) internal balances;
    
    mapping (uint => mapping (address => bool)) internal _allowances;
    
    
    constructor() public {
        
    }

    
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return owners[_tokenId];
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require (owners[_tokenId] == msg.sender || _allowances[_tokenId][msg.sender]);
        
        _transfer(_from, _to, _tokenId);
    }
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        balances[_to]++;
        balances[_from]--;
        owners[_tokenId] = _to;
        
        emit Transfer(_from, _to, _tokenId);
    }
    
    function approve(address _approved, uint256 _tokenId) external {
        require(owners[_tokenId] == msg.sender);
        
        _allowances[_tokenId][_approved] = true;
        
        emit Approval(msg.sender, _approved, _tokenId);
    }
}