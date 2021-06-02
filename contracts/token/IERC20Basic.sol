/**
 *   Source: https://github.com/ajlopez/DeFiProt/blob/master/contracts/test/ERC20Basic.sol
 * 
 */
pragma solidity >=0.5.0 <0.9.0;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract IERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address account) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 amount);
}