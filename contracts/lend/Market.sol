/**
 *  Reference 1: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  Reference 2: https://blog.openzeppelin.com/onward-with-ethereum-smart-contract-security-97a827e47702/
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-05-31, change getCash() to balance()
 * 
 *  Main Update 2, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 3, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 *  Main Update 4, 2021-06-06, improve naming convention
 * 
 *  Main Update 5, 2021-06-12, use Controllable
 * 
 *  Main Update 6, 2021-06-12, add Market for inheritance
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";
import "../utils/Controllable.sol";
import "../utils/SafeMath.sol";


contract Market is IMarket, Controllable {
    using SafeMath for uint256;

    address internal _token;
    uint internal _totalSupply;
    uint internal _totalBorrow;
    

    constructor(address token_) Controllable() public {
        // require(IERC20(token_).totalSupply() >= 0);
        
        _token = token_;
    }

 
    function token() external view returns (address) {
        return _token;
    }
    
    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }
    
    function totalBorrow() external view returns (uint) {
        return _totalBorrow;
    }
}