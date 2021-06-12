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

import "./token/ERC20/ERC20Faucet.sol";


contract MetaCoin is ERC20Faucet {
    address internal _owner;
    
	constructor () ERC20Faucet("MetaCoin", "MC", 10000, 2) public {
	    _owner = msg.sender;
	}
}
