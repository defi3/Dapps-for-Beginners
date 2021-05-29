pragma solidity ^0.5.16;

contract metaCoin {
    mapping (address => uint)  public balances;
    
    constructor () public {
		balances[msg.sender] = 10000;
	}
	
	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		
		return true;
	}
}