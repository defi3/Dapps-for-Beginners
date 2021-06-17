/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/ERC20.sol
 * 
 *  @Author defi3
 * 
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./IERC20Basic.sol";

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 is IERC20Basic {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    
    function allowance(address account, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}