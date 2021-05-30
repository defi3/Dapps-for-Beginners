pragma solidity ^0.6.0; /// solidity version of fei-protocol
pragma experimental ABIEncoderV2;

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
