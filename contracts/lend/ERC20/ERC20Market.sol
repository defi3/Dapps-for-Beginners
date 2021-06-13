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
 *  Main Update 6, 2021-06-12, move condtions from _supply() to supply(), _borrow() to borrow(), _redeem() to redeem(), _payBorrow() to payBorrow()
 * 
 *  Main Update 7, 2021-06-12, add Market for inheritance
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "../Market.sol";
import "./IERC20Market.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/SafeMath.sol";


contract ERC20Market is Market, IERC20Market {
    using SafeMath for uint256;
    

    constructor(address token_) Market(token_) public {
    }


    function balance() public view returns (uint) {
        return IERC20(_token).balanceOf(address(this));
    }


    function supply(uint amount) external {
        require(IERC20(_token).balanceOf(msg.sender) >= amount, "ERC20Market::supply: msg.sender does not have enough tokens");
        
        _supply(msg.sender, amount);
        
        _totalSupply = _totalSupply.add(amount);
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "ERC20Market::supply: not able to do transferFrom");

        emit Supply(msg.sender, amount);
    }

    function _supply(address supplier, uint amount) internal;
    
    
    function borrow(uint amount) external {
        require(IERC20(_token).balanceOf(address(this)) >= amount, "ERC20Market::borrow: market does not have enough tokens");
        
        _borrow(msg.sender, amount);

        _totalBorrow = _totalBorrow.add(amount);
        
        require(IERC20(_token).transfer(msg.sender, amount), "ERC20Market::borrow: not able to do transfer");
        
        emit Borrow(msg.sender, amount);
    }
 
    function _borrow(address borrower, uint amount) internal;


    function redeem(uint amount) external {
        require(IERC20(_token).balanceOf(address(this)) >= amount, "ERC20Market::redeem: market does not have enough tokens");
        
        _redeem(msg.sender, amount);
        
        _totalSupply = _totalSupply.sub(amount);
        
        require(IERC20(_token).transfer(msg.sender, amount), "ERC20Market::redeem: not able to do transfer");

        emit Redeem(msg.sender, amount);
    }

    function _redeem(address supplier, uint amount) internal;


    function payBorrow(uint amount) external {
        require(IERC20(_token).balanceOf(msg.sender) >= amount, "ERC20Market::payBorrow: msg.sender does not have enough tokens");
        
        uint paid;
        uint additional;
        
        (paid, additional) = _payBorrow(msg.sender, msg.sender, amount);
        
        _totalBorrow = _totalBorrow.sub(paid);
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "ERC20Market::payBorrow: not able to do transferFrom");
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function _payBorrow(address payer, address borrower, uint amount) internal returns (uint paid, uint additional);

 
    function redeemFor(address supplier, address receiver, uint amount) external onlyController {
        require(amount > 0);
        
        require(IERC20(_token).balanceOf(address(this)) >= amount, "ERC20Market::redeemFor: market does not have enough tokens");
        
        _redeem(supplier, amount);
        
        _totalSupply = _totalSupply.sub(amount);
        
        require(IERC20(_token).transfer(receiver, amount), "ERC20Market::redeemFor: not able to do transferFrom");
    }
}

