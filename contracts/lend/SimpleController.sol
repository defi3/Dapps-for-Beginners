/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 * 
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./Controller.sol";
import "./SimpleMarket.sol";
import "../utils/SafeMath.sol";

contract SimpleController is Controller {
    using SafeMath for uint256;

    constructor() Controller() public {
    }
    
    function getAccountValues(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _marketList.length; k++) {
            SimpleMarket market = SimpleMarket(_marketList[k]);
            uint price = _prices[_marketList[k]];
            
            supplyValue = supplyValue.add(market.supplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.borrowBy(account).mul(price));
        }
    }
}

