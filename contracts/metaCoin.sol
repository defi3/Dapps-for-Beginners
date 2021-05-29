pragma solidity ^0.5.16;

contract metaCoin {
    uint public constant totalSupply = 10000;
    
    mapping (address => uint)  public balances;
	
	constructor (address account) public {
	    require(msg.sender == account, "metaCoin::constructor: only the specific account can create a new contract");
	    
		balances[account] = totalSupply;
	}
	
	function sendCoin(address receiver, uint amount) public returns(bool) {
		return sendCoin(msg.sender, receiver, amount);
	}
	
	function sendCoin(address sender, address receiver, uint amount) public returns(bool) {
		require(balances[sender] >= amount, "metaCoin::sendCoin: sender does not have enough amount");
		
		balances[sender] -= amount;
		balances[receiver] += amount;
		
		return true;
	}
}