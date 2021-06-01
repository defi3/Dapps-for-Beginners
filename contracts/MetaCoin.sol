/**
 *   Reference 1: https://dappsforbeginners.wordpress.com/tutorials/your-first-dapp/
 * 
 *   Reference 2: https://www.tutorialspoint.com/solidity/solidity_inheritance.htm
 * 
 *   @Author defi3
 * 
 *   Main Update 1, 2021-05-31, Use inheritance
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

import "./token/StandardToken.sol";


contract MetaCoin is StandardToken {
    /// @notice EIP-20 token name for this token
    string public constant name = "MetaCoin";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "MC";
    
    /// @notice Total number of tokens in circulation
    uint public constant initialSupply = 10000;
    
    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 2;
    
	
	constructor (address account) public {
	    require(msg.sender == account, "MetaCoin::constructor: only the specific account can create a new contract");
		
		totalSupply_ = initialSupply;
        balances[account] = initialSupply;
	}
}
