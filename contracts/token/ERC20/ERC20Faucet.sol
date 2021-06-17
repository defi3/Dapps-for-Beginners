/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference 1: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/FaucetToken.sol
 * 
 *  Reference 2: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
 * 
 *  @Author defi3
 * 
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./ERC20Standard.sol";
import "../../utils/Ownable.sol";

/**
  * @title The Compound Faucet Test Token
  * @author Compound
  * @notice A simple test token that lets anyone get more of it.
  */
contract ERC20Faucet is ERC20Standard, Ownable {
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    constructor(string memory name_, string memory symbol_, uint256 amount_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        
        _totalSupply = amount_;
        _balances[msg.sender] = amount_;
        
        _decimals = decimals_;
    }
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }
    
     /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
