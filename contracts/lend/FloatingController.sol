/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-06, inherit Controller
 * 
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./Controller.sol";
import "./FloatingMarket.sol";
import "../utils/SafeMath.sol";

contract FloatingController is Controller() {
    using SafeMath for uint256;

    constructor() public {
    }
    
    function accountValuesInternal(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _marketList.length; k++) {
            FloatingMarket market = FloatingMarket(_marketList[k]);
            uint price = _prices[_marketList[k]];
            
            supplyValue = supplyValue.add(market.updatedSupplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.updatedBorrowBy(account).mul(price));
        }
    }
}

