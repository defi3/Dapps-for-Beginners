pragma solidity ^0.5.16;

import "./MetaCoin.sol";

contract CoinCaller2 {
    MetaCoin internal mc;
    
    constructor(address coinContractAddress) public {
        mc = MetaCoin(coinContractAddress);
    }
    
    function transfer(address receiver, uint amount) public returns(bool) {
		return mc.transfer(msg.sender, receiver, amount);
	}
}