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
import "./MarketFloating.sol";
import "../utils/SafeMath.sol";

contract ControllerFloating is Controller() {
    using SafeMath for uint256;

    constructor() public {
    }
    
    function accountValuesInternal(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _marketList.length; k++) {
            MarketFloating market = MarketFloating(_marketList[k]);
            uint price = _prices[_marketList[k]];
            
            supplyValue = supplyValue.add(market.updatedSupplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.updatedBorrowBy(account).mul(price));
        }
    }
}

