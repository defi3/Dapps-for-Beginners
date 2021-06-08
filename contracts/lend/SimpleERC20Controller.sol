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
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./ERC20Controller.sol";
import "./SimpleERC20Market.sol";
import "../utils/SafeMath.sol";

contract SimpleERC20Controller is ERC20Controller() {
    using SafeMath for uint256;

    constructor() public {
    }
    
    function accountValuesInternal(address account) internal view returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _marketList.length; k++) {
            SimpleERC20Market market = SimpleERC20Market(_marketList[k]);
            uint price = _prices[_marketList[k]];
            
            supplyValue = supplyValue.add(market.supplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.borrowBy(account).mul(price));
        }
    }
}

