/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference 1: https://medium.com/@blockchain101/calling-the-function-of-another-contract-in-solidity-f9edfa921f4c
 * 
 *  Reference 2: https://medium.com/@houzier.saurav/calling-functions-of-other-contracts-on-solidity-9c80eed05e0f
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

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
    
    constructor(address _t) {
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
 * abi.decode(data, (uint)) from https://etherscan.io/contractdiffchecker?a1=0x1568A7f0bdf67D37DC963c345Dbc4A598859ebA3
 * 
 * abi.decode(result, (string)) from https://stackoverflow.com/questions/60248647/return-value-from-a-deployed-smart-contract-via-a-smart-contract-to-a-smart-co
 * 
 * succesfully call DeployedContract in ^0.6.0
 * 
 */
 
contract ContractCallerAbi  {
    
    address dc;
    
    constructor(address _t) {
        dc = _t;
    }
    
    function setA(uint _a) public returns (uint) {
        (bool success, bytes memory result) = dc.call(abi.encodeWithSignature("setA(uint256)", _a));
        
        require(success, "fail to call setA");
        
        return abi.decode(result, (uint));
    }
    
    function setS(string memory _s) public returns (string memory) {
        (bool success, bytes memory result) = dc.call(abi.encodeWithSignature("setS(string)", _s));
        
        require(success, "fail to call setS");
        
        string memory sresult = abi.decode(result, (string));
        
        return sresult;
    }

    function set2(uint _a, string memory _s) public returns(uint) {
        (bool success, bytes memory result) = dc.call(abi.encodeWithSignature("set2(uint256,string)", _a, _s));
        
        require(success, "fail to call setS");
        
        return abi.decode(result, (uint));
    }
}
