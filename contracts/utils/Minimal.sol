/**
 *  Reference: https://jeancvllr.medium.com/solidity-tutorial-all-about-modifiers-a86cf81c14cb
 * 
 *  @Authoer defi3
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

contract Minimal {
    uint256 internal _min;

    constructor(uint256 min_) internal {
        _min = min_;
    }

    function min() public view returns(uint256) {
        return _min;
    }

    modifier minimum(uint256 amount) {
        require(amount > _min, "Minimal::_: not enough amount to call it");
        _;
    }
}