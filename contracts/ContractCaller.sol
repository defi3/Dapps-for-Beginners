/**
 * https://medium.com/@blockchain101/calling-the-function-of-another-contract-in-solidity-f9edfa921f4c
 *
 */

pragma solidity ^0.4.18;

contract DeployedContract {
    
    uint public a = 1;

    function setA(uint _a) public returns (uint) {
        a = _a;
        return a;
    }
}

contract ContractCaller  {
    
    DeployedContract dc;
    
    function ContractCaller(address _t) public {
        dc = DeployedContract(_t);
    }
 
    function getA() public view returns (uint) {
        return dc.a();
    }
    
    function setA(uint _a) public returns (uint) {
        return dc.setA(_a);
    }
}

contract ContractCallerSig  {
    
    address dc;
    
    function ContractCallerSig(address _t) public {
        dc = _t;
    }
    
    function setA_Signature(uint _a) public returns(bool) {
        require(dc.call(bytes4(keccak256("setA(uint256)")), _a));
        
        return true;
    }
}

contract ContractCallerSig2  {
    
    address dc;
    bytes4 fs;  /// function signature
    
    function ContractCallerSig2(address _t) public {
        dc = _t;
        fs = bytes4(keccak256("setA(uint256)"));
    }
    
    function setA_Signature(uint _a) public returns(bool) {
        require(dc.call(fs, _a));
        
        return true;
    }
}

contract ContractCallerSig3  {
    
    address dc;
    
    function ContractCallerSig3(address _t) public {
        dc = _t;
    }
    
    function setA_ASM(uint _a) public returns(uint) {
        bytes4 sig = bytes4(keccak256("setA(uint256)"));
        
        assembly {
            // move pointer to free memory spot
            let ptr := mload(0x40)
            // put function sig at memory spot
            mstore(ptr,sig)
            // append argument after function sig
            mstore(add(ptr,0x04), _a)

            let result := call(
              15000, // gas limit
              sload(dc_slot),  // to addr. append var to _slot to access storage variable
              0, // not transfer any ether
              ptr, // Inputs are stored at location ptr
              0x24, // Inputs are 36 bytes long
              ptr,  //Store output over input
              0x20) //Outputs are 32 bytes long
            
            if eq(result, 0) {
                revert(0, 0)
            }
            
            let answer := mload(ptr) // Assign output to answer var
            mstore(0x40,add(ptr,0x24)) // Set storage pointer to new space
        }
    }
}