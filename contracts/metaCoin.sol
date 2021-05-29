pragma solidity ^0.5.16;

contract metaCoin {
    uint public constant totalSupply = 10000;
    
    mapping (address => uint)  public balances;
	
	constructor (address account) public {
		balances[account] = totalSupply;
	}
	
	function sendCoin(address receiver, uint amount) public returns(int8 result) {
		return sendCoin(msg.sender, receiver, amount);
	}
	
	function sendCoin(address sender, address receiver, uint amount) public returns(int8 result) {
		if (balances[sender] < amount) return 0;
		
		balances[sender] -= amount;
		balances[receiver] += amount;
		
		return 1;
	}
}