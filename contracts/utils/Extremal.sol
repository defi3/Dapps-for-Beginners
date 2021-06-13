/**
 *  Reference: https://jeancvllr.medium.com/solidity-tutorial-all-about-modifiers-a86cf81c14cb
 * 
 *  @Authoer defi3
 * 
 */
 
import "./Minimal.sol";
import "./Maximal.sol";

pragma solidity >=0.5.0 <0.6.0;

contract Extremal is Minimal, Maximal {

    constructor(uint256 min_, uint256 max_) Minimal(min_) Maximal(max_) internal {
    }
    
    modifier extremum(uint256 amount) {
        require(amount > _min, "Minimal::_: not enough amount to call it");
        require(amount < _max, "Maximal::_: too much amount to call it");
        // require((amount > _min) && (amount < _max), "Extremal::_: not enough amount or too much amount to call it");
        _;
    }
}