pragma solidity ^0.5.16;  /// solidity version used in compound-protocol

contract DeployedContract {
    
    uint public a = 1;
    string public s = "a";
    
    function setA(uint _a) public returns (uint) {
        a = _a;
        return a;
    }
    
    function setS(string memory _s) public returns (string memory) {
        s = _s;
        return s;
    }

    function set2(uint _a, string memory _s) public returns (uint) {
        a = _a;
        s = _s;
        return a;
    }
}

contract ContractCaller  {
    
    DeployedContract dc;
    
    constructor (address _t) public {
        dc = DeployedContract(_t);
    }
    
    function setA(uint _a) public returns (uint) {
        return dc.setA(_a);
    }
    
    function setS(string memory _s) public returns (string memory) {
        return dc.setS(_s);
    }

    function set2(uint _a, string memory _s) public returns (uint) {
        return dc.set2(_a, _s);
    }
}

/**
 * https://docs.soliditylang.org/en/v0.5.16/types.html#members-of-addresses
 * 
 * succesfully call DeployedContract in ^0.6.0
 * 
 */
 
contract ContractCallerAbi  {
    
    address dc;
    
    constructor (address _t) public {
        dc = _t;
    }
    
    function setA(uint _a) public returns (bool) {
        (bool success, bytes memory returnData) = dc.call(abi.encodeWithSignature("setA(uint256)", _a));
        
        return success;
    }
    
    function setS(string memory _s) public returns (bool) {
        (bool success, bytes memory returnData) = dc.call(abi.encodeWithSignature("setS(string)", _s));
        
        return success;
    }

    function set2(uint _a, string memory _s) public returns(bool) {
        (bool success, bytes memory returnData) = dc.call(abi.encodeWithSignature("set2(uint256,string)", _a, _s));
        
        return success;
    }
}
