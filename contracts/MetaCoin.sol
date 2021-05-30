pragma solidity ^0.5.16;

contract MetaCoin {
    uint public constant totalSupply = 10000;
    
    mapping (address => uint)  public balances;
	
	constructor (address account) public {
	    require(msg.sender == account, "MetaCoin::constructor: only the specific account can create a new contract");
	    
		balances[account] = totalSupply;
	}
	
	function transfer(address receiver, uint amount) public returns(bool) {
		return transfer(msg.sender, receiver, amount);
	}
	
	function transfer(address sender, address receiver, uint amount) public returns(bool) {
		require(balances[sender] >= amount, "MetaCoin::transfer: sender does not have enough amount");
		
		balances[sender] -= amount;
		balances[receiver] += amount;
		
		return true;
	}
}
