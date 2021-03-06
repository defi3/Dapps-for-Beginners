/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://medium.com/@houzier.saurav/calling-functions-of-other-contracts-on-solidity-9c80eed05e0f
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

contract CoinCallerAbi {
    address internal mc;
    
    constructor(address _address) {
        mc = _address;
    }
    
    /// sender is contract itself
    function transfer(address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transfer(address,uint256)", receiver, amount));
        
        require(success, "CoinCallerAbi::transfer: fail to call transfer");
        
		return abi.decode(result, (bool));
	}
    
	function transferFrom(address sender, address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, receiver, amount));
        
        require(success, "CoinCallerAbi::transfer3: fail to call transferFrom");
        
		return abi.decode(result, (bool));
	}
	
	function balanceOf(address account) public returns (uint) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("balanceOf(address)", account));
        
        require(success, "CoinCallerAbi::balanceOf: fail to call balanceOf");
        
		return abi.decode(result, (uint));
	}
}
