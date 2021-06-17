/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Source: https://docs.soliditylang.org/en/v0.8.0/solidity-by-example.html#modular-contracts
 * 
 *  Reference: https://medium.com/coinmonks/math-in-solidity-part-2-overflow-3cd7283714b4
 * 
 *  @Author defi3
 * 
 * 
 *  Main Update 1, 2021-05-31, add error messages for require functions
 * 
 *  Main Update 2, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

library ERC20Balances {
    function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
        require(to != address(0), "Balances::move: do not transfer money to address 0.");
        
        require(balances[from] >= amount, "Balances::move: address from does not have enough amount.");
        
        require(balances[to] + amount >= balances[to], "Balances::move: overflow is possible in address to.");
        
        balances[from] -= amount;
        
        balances[to] += amount;
    }
}