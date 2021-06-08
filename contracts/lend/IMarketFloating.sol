/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  Support Floating Interest Rate
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

contract IMarketFloating {
    function utilizationRate(uint balance_, uint totalBorrow_, uint reserve_) external pure returns (uint);
    function borrowRate(uint balance_, uint totalBorrow_, uint reserve_) external view returns (uint);
    function supplyRate(uint balance_, uint totalBorrow_, uint reserve_) external view returns (uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
    function blockNumber() external view returns (uint);
}

