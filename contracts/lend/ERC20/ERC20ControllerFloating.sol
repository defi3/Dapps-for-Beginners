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

import "./ERC20Controller.sol";
import "./ERC20MarketFloating.sol";
import "../../utils/SafeMath.sol";

contract ERC20ControllerFloating is ERC20Controller() {
    using SafeMath for uint256;

    constructor() public {
    }
    
    function _accountValues(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _markets.length; k++) {
            ERC20MarketFloating market = ERC20MarketFloating(_markets[k]);
            uint price = _prices[_markets[k]];
            
            supplyValue = supplyValue.add(market.updatedSupplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.updatedBorrowBy(account).mul(price));
        }
    }
}

