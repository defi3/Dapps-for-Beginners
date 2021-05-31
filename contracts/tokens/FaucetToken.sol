pragma solidity ^0.5.16;

import "./StandardToken.sol";

/**
  * @title The Compound Faucet Test Token
  * @author Compound
  * @notice A simple test token that lets anyone get more of it.
  */
contract FaucetToken is StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint256 _amount, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        
        totalSupply_ = _amount;
        balances[msg.sender] = _amount;
        
        decimals = _decimals;
    }
}
