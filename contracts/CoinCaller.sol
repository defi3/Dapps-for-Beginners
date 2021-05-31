pragma solidity >=0.5.0 <0.9.0;

import "./MetaCoin.sol";

contract CoinCaller {
    function transfer(address _address, address receiver, uint amount) public returns(bool) {
		MetaCoin mc = MetaCoin(_address);
		
		return mc.transferFrom(msg.sender, receiver, amount);
	}
}


contract CoinCaller2 {
    MetaCoin internal mc;
    
    constructor(address _address) public {
        mc = MetaCoin(_address);
    }
    
    function transfer(address receiver, uint amount) public returns(bool) {
		return mc.transferFrom(msg.sender, receiver, amount);
	}
}