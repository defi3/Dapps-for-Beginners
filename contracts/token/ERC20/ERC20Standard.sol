/**
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/StandardToken.sol
 * 
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./ERC20Basic.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20Standard is IERC20, ERC20Basic {
    using ERC20Balances for mapping(address => uint256);
    
    mapping (address => mapping (address => uint256)) internal _allowances;

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(_allowances[from][msg.sender] >= amount);
        
        _balances.move(from, to, amount);

        _allowances[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
}