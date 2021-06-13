/**
 *  Reference: https://jeancvllr.medium.com/solidity-tutorial-all-about-modifiers-a86cf81c14cb
 * 
 *  @Authoer defi3
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

contract Maximal {
    uint256 internal _max;

    constructor(uint256 max_) internal {
        _max = max_;
    }

    function max() public view returns(uint256) {
        return _max;
    }

    modifier maximum(uint256 amount) {
        require(amount < _max, "Maximal::_: too much amount to call it");
        _;
    }
}