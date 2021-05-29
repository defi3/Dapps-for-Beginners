pragma solidity ^0.5.16;

import "./metaCoin.sol";

contract coinCaller {
    function sendCoin(address coinContractAddress, address receiver, uint amount) public returns(bool sufficient) {
		metaCoin m = metaCoin(coinContractAddress);
		
		return m.sendCoin(receiver, amount);
	}
}