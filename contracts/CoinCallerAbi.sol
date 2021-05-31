pragma solidity ^0.8.0;

contract CoinCallerAbi {
    address internal mc;
    
    constructor(address _address) public {
        mc = _address;
    }
    
    /// sender is contract itself
    function transfer(address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transfer(address,uint256)", receiver, amount));
        
        require(success, "CoinCallerAbi::transfer: fail to call transfer");
        
		return abi.decode(result, (bool));
	}
    
	function transferFrom(address sender, address receiver, uint amount) public returns(bool) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, receiver, amount));
        
        require(success, "CoinCallerAbi::transfer3: fail to call transferFrom");
        
		return abi.decode(result, (bool));
	}
	
	function balanceOf(address account) public returns (uint) {
        (bool success, bytes memory result) = mc.call(abi.encodeWithSignature("balanceOf(address)", account));
        
        require(success, "CoinCallerAbi::balanceOf: fail to call balanceOf");
        
		return abi.decode(result, (uint));
	}
}
