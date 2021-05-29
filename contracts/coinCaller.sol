pragma solidity ^0.5.16;

import "./metaCoin.sol";

contract coinCaller {
    function sendCoin(address coinContractAddress, address receiver, uint amount) public returns(bool) {
		metaCoin m = metaCoin(coinContractAddress);
		
		return m.sendCoin(msg.sender, receiver, amount);
	}
}