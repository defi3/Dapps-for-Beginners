/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
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
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IERC20Market.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/Controllable.sol";
import "../../utils/SafeMath.sol";


contract ERC20Market is IERC20Market, Controllable {
    using SafeMath for uint256;

    address internal _token;
    uint internal _totalSupply;
    uint internal _totalBorrow;
    

    constructor(address token_) Controllable() public {
        require(IERC20(token_).totalSupply() >= 0);
        
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
        
        _totalBorrow = _totalBorrow.sub(amount);
        
        require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "ERC20Market::payBorrow: not able to do transferFrom");
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function _payBorrow(address payer, address borrower, uint amount) internal returns (uint paid, uint additional);

 
    function transferFrom(address from, address to, uint amount) external onlyController {
        require(amount > 0);
        
        require(IERC20(_token).balanceOf(address(this)) >= amount, "ERC20Market::redeem: market does not have enough tokens");
        
        _redeem(from, amount);
        
        _totalSupply = _totalSupply.sub(amount);
        
        require(IERC20(_token).transferFrom(from, to, amount), "ERC20Market::transferFrom: not able to do transferFrom");
    }
}

