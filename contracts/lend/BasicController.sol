/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-06, inherit Controller 
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./Controller.sol";
import "./BasicMarket.sol";
import "../utils/SafeMath.sol";

contract BasicController is Controller {
    using SafeMath for uint256;

    constructor() Controller() public {
    }
    
    function getAccountValues(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < marketList.length; k++) {
            BasicMarket market = BasicMarket(marketList[k]);
            uint price = prices[marketList[k]];
            
            supplyValue = supplyValue.add(market.updatedSupplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.updatedBorrowBy(account).mul(price));
        }
    }
}

