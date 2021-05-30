pragma solidity ^0.5.16;

import "./MetaCoin.sol";

contract CoinCaller {
    function transfer(address _address, address receiver, uint amount) public returns(bool) {
		MetaCoin mc = MetaCoin(_address);
		
		return mc.transfer(msg.sender, receiver, amount);
	}
}


contract CoinCaller2 {
    MetaCoin internal mc;
    
    constructor(address _address) public {
        mc = MetaCoin(_address);
    }
    
    function transfer(address receiver, uint amount) public returns(bool) {
		return mc.transfer(msg.sender, receiver, amount);
	}
}