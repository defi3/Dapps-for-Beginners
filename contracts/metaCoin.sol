pragma solidity ^0.5.16;

contract metaCoin {
    uint public constant totalSupply = 10000;
    
    mapping (address => uint)  public balances;
	
	constructor (address account) public {
		balances[account] = totalSupply;
	}
	
	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		
		return true;
	}
}