/**
 *   Source: https://docs.soliditylang.org/en/v0.8.0/solidity-by-example.html#modular-contracts
 * 
 *   Reference: https://medium.com/coinmonks/math-in-solidity-part-2-overflow-3cd7283714b4
 * 
 *   @Author defi3
 * 
 *   Main Update 1, 2021-05-31, add error messages for require functions
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

import "../../utils/SafeMath.sol";

library ERC20Balances {
    using SafeMath for uint256;
    
    function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
        require(to != address(0), "Balances::move: do not transfer money to address 0.");
        
        require(balances[from] >= amount, "Balances::move: address from does not have enough amount.");
        
        require(balances[to] + amount >= balances[to], "Balances::move: overflow is possible in address to.");
        
        balances[from] = balances[from].sub(amount);
        
        balances[to] = balances[to].add(amount);
    }
}