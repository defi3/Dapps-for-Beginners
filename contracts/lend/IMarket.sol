/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  Support ERC20, ERC721
 * 
 * 
 *  Main Update 1, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

interface IMarket {
    function owner() external view returns (address);
    
    function controller() external view returns(address);
    function setController(address controller_) external;
    
    function token() external view returns (address);
    function totalSupply() external view returns (uint);
    function totalBorrow() external view returns (uint);
    function balance() external view returns (uint);
    
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
}