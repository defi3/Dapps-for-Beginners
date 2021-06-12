/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 2, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 3, 2021-06-06, improve naming convention
 * 
 *  Main Update 4, 2021-06-12, use Ownable
 * 
 *  Main Update 5, 2021-06-12, add Controller for inheritance
 * 
 * 
 *  To-do: It currenlty uses three mapping: _markets, _marketsByToken, _prices and one array: _marketList for markets. Please optimize this part.
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IController.sol";
import "./IMarket.sol";
import "../utils/Ownable.sol";
import "../utils/AddressArray.sol";
import "../utils/SafeMath.sol";

contract Controller is IController, Ownable {
    using SafeMath for uint256;
    
    using AddressArray for address[];
    
    uint public constant MANTISSA = 1e6;
    
    uint internal _collateralFactor;
    uint internal _liquidationFactor;

    mapping (address => bool) internal _markets;
    mapping (address => address) internal _marketsByToken;
    address[] internal _marketList;


    constructor() Ownable() public {
    }


    modifier onlyMarket() {
        require(_markets[msg.sender]);
        _;
    }
    
    
    function collateralFactor() external view returns (uint) {
        return _collateralFactor;
    }
    
    function setCollateralFactor(uint factor) external onlyOwner {
        _collateralFactor = factor;
    }

    function liquidationFactor() external view returns (uint) {
        return _liquidationFactor;
    }
    
    function setLiquidationFactor(uint factor) external onlyOwner {
        _liquidationFactor = factor;
    }
    

    function addMarket(address market) external onlyOwner {
        address token = IMarket(market).token();
        
        require(_marketsByToken[token] == address(0));
        
        _markets[market] = true;
        _marketsByToken[token] = market;
        _marketList.push(market);
    }
    
    function removeMarket(address market_) external onlyOwner returns (bool) {
        IMarket market = IMarket(market_);
        
        require(market.balance() == 0);
        require(market.totalSupply() == 0);
        require(market.totalBorrow() == 0);
        
        address token = market.token();
        
        require(_marketsByToken[token] != address(0));
        
        
        _markets[market_] = false;
        delete _marketsByToken[token];
        _marketList.removeByValue(market_);
    }
    
    function findMarket(address market_) internal returns (uint) {
        
    }
    
    function size() external view returns (uint) {
      return _marketList.length;
    }
    
    function marketOf(address token) external view returns (address) {
        return _marketsByToken[token];
    }
}