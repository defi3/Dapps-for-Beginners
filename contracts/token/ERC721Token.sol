/**
 *   Reference 1: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 *   Reference 2: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
 * 
 *   @Author defi3
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IERC721.sol";
import "../utils/Ownable.sol";
import "../utils/SafeMath.sol";

contract ERC721Token is Ownable, IERC721 {
    using SafeMath for uint256;
    
    string internal _name;
    string internal _symbol;
    
    mapping (uint => address) internal _owners;
    
    mapping (address => uint) internal _balances;
    
    mapping (uint => address) internal _allowances;
    
    
    constructor(string memory name_, string memory symbol_) Ownable() public {
        _name = name_;
        _symbol = symbol_;
    }
    
    
    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function balanceOf(address owner_) external view returns (uint256) {
        require(owner_ != address(0), "ERC721: balance query for the zero address");
        
        return _balances[owner_];
    }
    
    function ownerOf(uint256 tokenId_) external view returns (address) {
        address owner = _owners[tokenId_];
        
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        
        return owner;
    }
    
    function transferFrom(address from, address to, uint256 tokenId_) external {
        require (_owners[tokenId_] == msg.sender || _allowances[tokenId_] == msg.sender, "ERC721: transfer caller is not owner nor approved");
        
        require(to != address(0), "ERC721: transfer to the zero address");
        
        _balances[to] = _balances[to].add(1);
        _balances[from] = _balances[from].sub(1);
        
        _owners[tokenId_] = to;
         _allowances[tokenId_] = address(0);
        
        
        emit Transfer(from, to, tokenId_);
    }
    
    function approve(address to, uint256 tokenId_) external {
        address owner = _owners[tokenId_];
        
        require(to != owner, "ERC721: approval to current owner");
        
        require(owner == msg.sender, "ERC721: approve caller is not owner");
        
        _allowances[tokenId_] = to;
        
        emit Approval(msg.sender, to, tokenId_);
    }
}