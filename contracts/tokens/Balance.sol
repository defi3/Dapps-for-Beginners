/**
 *   Source: https://docs.soliditylang.org/en/v0.8.0/solidity-by-example.html#modular-contracts
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

import "../utils/SafeMath.sol";

library Balances {
    using SafeMath for uint256;
    
    function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
        require(to != address(0));
        require(balances[from] >= amount);
        require(balances[to] + amount >= balances[to]);
        
        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
    }
}