pragma solidity ^0.5.16;

import "./metaCoin.sol";

contract coinCaller2 {
    metaCoin internal mc;
    
    constructor(address coinContractAddress) public {
        mc = metaCoin(coinContractAddress);
    }
    
    function sendCoin(address receiver, uint amount) public returns(bool) {
		return mc.sendCoin(msg.sender, receiver, amount);
	}
}