/**
 *  Source: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

interface IMarket {
    function token() external view returns (address);
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
    function transferTo(address sender, address receiver, uint amount) external;
}

