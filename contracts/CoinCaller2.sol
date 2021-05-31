pragma solidity ^0.6.0;

contract CoinCallerAbi {
    address internal mc;
    
    constructor(address _address) public {
        mc = _address;
    }
    
    function transfer(address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transfer(address,uint256)", receiver, amount));
        
        require(success, "fail to call transfer");
        
		return abi.decode(result, (bool));
	}
    
    function transferFrom(address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, receiver, amount));
        
        require(success, "fail to call transfer");
        
		return abi.decode(result, (bool));
	}
	
	function balanceOf(address account) public returns (uint) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("balanceOf(address)", account));
        
        require(success, "fail to call balanceOf");
        
		return abi.decode(result, (uint));
	}
}
