/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/ERC20Basic.sol
 * 
 *  @Author defi3
 * 
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
interface IERC20Basic {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}