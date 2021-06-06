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
 */
pragma solidity >=0.5.0 <0.6.0;

import "./IMarket.sol";
import "../token/IERC20.sol";
import "../utils/SafeMath.sol";


contract Market is IMarket {
    using SafeMath for uint256;

    address public owner;

    IERC20 public token;
    uint public totalSupply;
    uint public totalBorrow;
    
    address public controller;
    

    constructor(IERC20 _token) public {
        require(IERC20(_token).totalSupply() >= 0);
        owner = msg.sender;
        token = _token;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller);
        _;
    }
    
    function setController(address _controller) public onlyOwner {
        controller = _controller;
    }


    function balance() public view returns (uint) {
        return token.balanceOf(address(this));
    }


    function supply(uint amount) public {
        supplyInternal(msg.sender, amount);
        
        totalSupply = totalSupply.add(amount);

        emit Supply(msg.sender, amount);
    }

    function supplyInternal(address supplier, uint amount) internal;
    
    
    function borrow(uint amount) public {
        require(token.balanceOf(address(this)) >= amount);
        
        borrowInternal(msg.sender, amount);

        totalBorrow = totalBorrow.add(amount);
        
        emit Borrow(msg.sender, amount);
    }
 
    function borrowInternal(address user, uint amount) internal;


    function redeem(uint amount) public {
        require(token.balanceOf(address(this)) >= amount);
        
        redeemInternal(msg.sender, msg.sender, amount);
        
        totalSupply = totalSupply.sub(amount);

        emit Redeem(msg.sender, amount);
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal;


    function payBorrow(uint amount) public {
        uint paid;
        uint additional;
        
        (paid, additional) = payBorrowInternal(msg.sender, msg.sender, amount);
        
        totalBorrow = totalBorrow.sub(amount);
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function payBorrowInternal(address payer, address borrower, uint amount) internal returns (uint paid, uint supplied);

 
    function transferTo(address sender, address receiver, uint amount) public onlyController {
        require(amount > 0);
        
        redeemInternal(sender, receiver, amount);
    }
}

