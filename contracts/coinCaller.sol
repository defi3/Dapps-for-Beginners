pragma solidity ^0.5.16;

import "./MetaCoin.sol";

contract CoinCaller {
    function transfer(address coinContractAddress, address receiver, uint amount) public returns(bool) {
		MetaCoin mc = MetaCoin(coinContractAddress);
		
		return mc.transfer(msg.sender, receiver, amount);
	}
}