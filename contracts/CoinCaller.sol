pragma solidity >=0.5.0 <0.9.0;

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
    
    constructor(address _address) public {
        mc = MetaCoin(_address);
    }
    
    /// sender is contract itself
    function transfer(address receiver, uint amount) public returns(bool) {
		return mc.transfer(receiver, amount);
	}
}