/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 * 
 * 
 *  Main Update 1, 2021-06-06, inherit Market 
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./Market.sol";
import "./Controller.sol";
import "../token/IERC20.sol";
import "../utils/SafeMath.sol";

contract SimpleMarket is Market {
    using SafeMath for uint256;

    mapping (address => uint) internal supplies;
    mapping (address => uint) internal borrows;

    uint public constant FACTOR = 1e6;


    constructor(IERC20 _token) Market(_token) public {
    }

    function supplyOf(address account) public view returns (uint) {
        return supplies[account];
    }
    
    function borrowBy(address account) public view returns (uint) {
        return borrows[account];
    }

    function supplyInternal(address supplier, uint amount) internal {
        supplies[supplier] = supplies[supplier].add(amount);
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal {
        require(supplies[supplier] >= amount);

        require(token.transfer(receiver, amount), "No enough tokens");

        supplies[supplier] = supplies[supplier].sub(amount);
        
        Controller ctr = Controller(controller);
        
        bool status;
        uint health;
        
        (status, health) = ctr.checkAccountHealth(supplier);
        
        require(status);
    }

    function borrowInternal(address borrower, uint amount) internal {
        Controller ctr = Controller(controller);
        
        bool status;
        uint liquidity;
        
        (status, liquidity) = ctr.checkAccountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        require(token.transfer(borrower, amount), "No enough tokens to borrow");

        borrows[borrower] = borrows[borrower].add(amount);
    }

    function payBorrowInternal(address payer, address borrower, uint amount) internal returns (uint paid, uint supplied) {
        require(borrows[borrower] > 0);

        require(token.transferFrom(payer, address(this), amount), "No enough tokens");

        borrows[borrower] = borrows[borrower].sub(amount);
            
        return (amount, 0);
    }
    
    function liquidateBorrow(address borrower, uint amount, address collateral) public {
        require(amount > 0);
        
        require(borrower != msg.sender);
        
        require(token.balanceOf(msg.sender) >= amount);
        
        Controller ctr = Controller(controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, collateral, collateralAmount);
    }
}

