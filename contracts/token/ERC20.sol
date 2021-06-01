/**
 *   Source: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/ERC20.sol
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

import "./ERC20Basic.sol";

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address account, address spender) public view returns (uint256);
    function approve(address spender, uint256 amount) public returns (bool);
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
}