/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  Support Interest
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";

contract IMarketWithInterest is IMarket {
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
}
