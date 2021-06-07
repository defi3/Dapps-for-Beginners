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

import "./IMarket.sol";
import "../token/IERC20.sol";
import "../utils/SafeMath.sol";


contract Market is IMarket {
    using SafeMath for uint256;

    address internal _owner;

    address internal _token;
    uint internal _totalSupply;
    uint internal _totalBorrow;
    
    address internal _controller;
    

    constructor(address token_) public {
        require(IERC20(token_).totalSupply() >= 0);
        
        _owner = msg.sender;
        
        _token = token_;
    }


    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyController() {
        require(msg.sender == _controller);
        _;
    }
    
    function setController(address controller_) external onlyOwner {
        _controller = controller_;
    }

    function owner() external view returns (address) {
        return _owner;
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
        // TODO check msg.sender != this
        require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "No enough tokens");
        
        supplyInternal(msg.sender, amount);
        
        _totalSupply = _totalSupply.add(amount);

        emit Supply(msg.sender, amount);
    }

    function supplyInternal(address supplier, uint amount) internal;
    
    
    function borrow(uint amount) external {
        require(IERC20(_token).balanceOf(address(this)) >= amount);
        
        borrowInternal(msg.sender, amount);

        _totalBorrow = _totalBorrow.add(amount);
        
        emit Borrow(msg.sender, amount);
    }
 
    function borrowInternal(address borrower, uint amount) internal;


    function redeem(uint amount) external {
        require(IERC20(_token).balanceOf(address(this)) >= amount);
        
        redeemInternal(msg.sender, msg.sender, amount);
        
        _totalSupply = _totalSupply.sub(amount);

        emit Redeem(msg.sender, amount);
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal;


    function payBorrow(uint amount) external {
        uint paid;
        uint additional;
        
        (paid, additional) = payBorrowInternal(msg.sender, msg.sender, amount);
        
        _totalBorrow = _totalBorrow.sub(amount);
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function payBorrowInternal(address payer, address borrower, uint amount) internal returns (uint paid, uint additional);

 
    function transferTo(address sender, address receiver, uint amount) external onlyController {
        require(amount > 0);
        
        redeemInternal(sender, receiver, amount);
    }
}

