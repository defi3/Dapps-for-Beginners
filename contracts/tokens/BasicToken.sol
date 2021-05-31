/**
 *   Source: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/BasicToken.sol
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

import "./ERC20Basic.sol";
import "./Balance.sol";


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    mapping(address => uint256) internal balances;
    using Balances for *;

    uint256 internal totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param amount The amount to be transferred.
    */
    function transfer(address to, uint256 amount) public returns (bool) {
        balances.move(msg.sender, to, amount);
        
        emit Transfer(msg.sender, to, amount);
        
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param account The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}