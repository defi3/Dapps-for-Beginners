/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://dappsforbeginners.wordpress.com/tutorials/interactions-between-contracts/
 * 
 *  @Author defi3
 * 
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */

pragma solidity ^0.8.0;

import "./MetaCoin.sol";

contract CoinCaller {
    /// sender is contract itself
    function transfer(address _address, address receiver, uint amount) public returns(bool) {
		MetaCoin mc = MetaCoin(_address);
		
		return mc.transfer(receiver, amount);
	}
}


contract CoinCaller2 {
    MetaCoin internal mc;
    
    constructor(address _address) {
        mc = MetaCoin(_address);
    }
    
    /// sender is contract itself
    function transfer(address receiver, uint amount) public returns(bool) {
		return mc.transfer(receiver, amount);
	}
}