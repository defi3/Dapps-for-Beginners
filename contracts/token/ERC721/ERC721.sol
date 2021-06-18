/**
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  Reference 1: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 *  Reference 2: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
 * 
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-06
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "../../utils/Ownable.sol";

abstract contract ERC721 is Ownable, IERC721, IERC721Metadata {
    string internal _name;
    string internal _symbol;
    
    mapping (uint => address) internal _owners;
    
    mapping (address => uint) internal _balances;
    
    mapping (uint => address) internal _allowances;
    
    
    constructor(string memory name_, string memory symbol_) Ownable() {
        _name = name_;
        _symbol = symbol_;
    }
    
    
    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }
    
    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }


    /**
     * @dev Mints `tokenId_` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId_` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId_) internal onlyOwner {
        require(to != address(0), "ERC721: mint to the zero address");
        
        require(_owners[tokenId_] == address(0), "ERC721: token already minted");

        _balances[to] += 1;
        
        _owners[tokenId_] = to;

        emit Transfer(address(0), to, tokenId_);
    }
    
    /**
     * @dev Destroys `tokenId_`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId_` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId_) internal onlyOwner {
        address owner = _owners[tokenId_];
        
        require(owner != address(0));
        
        _allowances[tokenId_] = address(0);

        _balances[owner] -= 1;
        
        delete _owners[tokenId_];

        emit Transfer(owner, address(0), tokenId_);
    }
    
    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId_) internal view returns (bool) {
        return _owners[tokenId_] != address(0);
    }
    
    function balanceOf(address owner_) external view override returns (uint256) {
        require(owner_ != address(0), "ERC721: balance query for the zero address");
        
        return _balances[owner_];
    }

   
    /**
     * @dev See {IERC721-balanceOf}.
     */
    function ownerOf(uint256 tokenId_) external view override returns (address) {
        address owner = _owners[tokenId_];
        
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        
        return owner;
    }
    
    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId_) external override {
        require (_owners[tokenId_] == msg.sender || _allowances[tokenId_] == msg.sender, "ERC721: transfer caller is not owner nor approved");
        
        require(to != address(0), "ERC721: transfer to the zero address");
        
        _balances[to] += 1;
        _balances[from] -= 1;
        
        _owners[tokenId_] = to;
         _allowances[tokenId_] = address(0);
        
        
        emit Transfer(from, to, tokenId_);
    }
    
    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId_) external override {
        address owner = _owners[tokenId_];
        
        require(to != owner, "ERC721: approval to current owner");
        
        require(owner == msg.sender, "ERC721: approve caller is not owner");
        
        _allowances[tokenId_] = to;
        
        emit Approval(msg.sender, to, tokenId_);
    }
}