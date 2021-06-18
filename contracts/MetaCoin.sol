/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference 1: https://dappsforbeginners.wordpress.com/tutorials/your-first-dapp/
 * 
 *  Reference 2: https://www.tutorialspoint.com/solidity/solidity_inheritance.htm
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-05-31, Use inheritance
 * 
 *  Main Update 2, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./token/ERC20/ERC20Faucet.sol";


contract MetaCoin is ERC20Faucet {
	constructor () ERC20Faucet("MetaCoin", "MC", 10000, 2) {
	}
}
