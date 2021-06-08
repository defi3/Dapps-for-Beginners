/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IERC721.sol";
import "../utils/Ownable.sol";
import "../utils/SafeMath.sol";

contract ERC721Token is Ownable(), IERC721 {
    using SafeMath for uint256;
    
    mapping (uint => address) internal _owners;
    
    mapping (address => uint) internal _balances;
    
    mapping (uint => mapping (address => bool)) internal _allowances;

    
    function balanceOf(address owner_) external view returns (uint256) {
        return _balances[owner_];
    }
    
    function ownerOf(uint256 tokenId_) external view returns (address) {
        return _owners[tokenId_];
    }
    
    function transferFrom(address from, address to, uint256 tokenId_) external {
        require (_owners[tokenId_] == msg.sender || _allowances[tokenId_][msg.sender]);
        
        _balances[to] = _balances[to].add(1);
        _balances[from] = _balances[from].add(1);
        _owners[tokenId_] = to;
        
        emit Transfer(from, to, tokenId_);
    }
    
    function approve(address spender, uint256 tokenId_) external {
        require(_owners[tokenId_] == msg.sender);
        
        _allowances[tokenId_][spender] = true;
        
        emit Approval(msg.sender, spender, tokenId_);
    }
}