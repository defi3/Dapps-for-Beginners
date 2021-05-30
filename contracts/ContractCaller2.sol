pragma solidity ^0.4.18;

contract DeployedContract {
    
    uint public a = 1;
    string public s = "a";
    
    function setA(uint _a) public returns (uint) {
        a = _a;
        return a;
    }
    
    function setS(string _s) public returns (string) {
        s = _s;
        return s;
    }

    function set2(uint _a, string _s) public returns (uint) {
        a = _a;
        s = _s;
        return a;
    }
}

contract ContractCaller  {
    
    DeployedContract dc;
    
    function ContractCaller(address _t) public {
        dc = DeployedContract(_t);
    }
    
    function setA(uint _a) public returns (uint) {
        return dc.setA(_a);
    }
    
    function setS(string _s) public returns (string) {
        return dc.setS(_s);
    }

    function set2(uint _a, string _s) public returns (uint) {
        return dc.set2(_a, _s);
    }
}

contract ContractCallerSig  {
    
    address dc;
    
    function ContractCallerSig(address _t) public {
        dc = _t;
    }
    
    function setA(uint _a) public returns (bool) {
        require(dc.call(bytes4(keccak256("setA(uint256)")), _a));
        
        return true;
    }
    
    /// s is not changed
    function setS(string _s) public returns (bool) {
        require(dc.call(bytes4(keccak256("setS(string)")), _s));
        
        return true;
    }

    /// a is chagned but s is not changed
    function set2(uint _a, string _s) public returns(bool) {
        require(dc.call(bytes4(keccak256("set2(uint256,string)")), _a, _s));
        
        return true;
    }
}

contract ContractCallerAbi  {
    
    address dc;
    
    function ContractCallerAbi(address _t) public {
        dc = _t;
    }
    
    function setA(uint _a) public returns (bool) {
        require(dc.call(abi.encodeWithSignature("setA(uint256)", _a)));
        
        return true;
    }
    
    function setS(string _s) public returns (bool) {
        require(dc.call(abi.encodeWithSignature("setS(string)", _s)));
        
        return true;
    }

    function set2(uint _a, string _s) public returns(bool) {
        require(dc.call(abi.encodeWithSignature("set2(uint256,string)", _a, _s)));
        
        return true;
    }
}
