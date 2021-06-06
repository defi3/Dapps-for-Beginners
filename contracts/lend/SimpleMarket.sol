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

    mapping (address => uint) internal _supplies;
    mapping (address => uint) internal _borrows;

    uint public constant FACTOR = 1e6;


    constructor(IERC20 _token) Market(_token) public {
    }

    function supplyOf(address account) public view returns (uint) {
        return _supplies[account];
    }
    
    function borrowBy(address account) public view returns (uint) {
        return _borrows[account];
    }

    function supplyInternal(address supplier, uint amount) internal {
        _supplies[supplier] = _supplies[supplier].add(amount);
    }

    function redeemInternal(address supplier, address receiver, uint amount) internal {
        require(_supplies[supplier] >= amount);

        require(_token.transfer(receiver, amount), "No enough tokens");

        _supplies[supplier] = _supplies[supplier].sub(amount);
        
        Controller ctr = Controller(_controller);
        
        bool status;
        uint health;
        
        (status, health) = ctr.checkAccountHealth(supplier);
        
        require(status);
    }

    function borrowInternal(address borrower, uint amount) internal {
        Controller ctr = Controller(_controller);
        
        bool status;
        uint liquidity;
        
        (status, liquidity) = ctr.checkAccountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        require(_token.transfer(borrower, amount), "No enough tokens to borrow");

        _borrows[borrower] = _borrows[borrower].add(amount);
    }

    function payBorrowInternal(address payer, address borrower, uint amount) internal returns (uint paid, uint supplied) {
        require(_borrows[borrower] > 0);

        require(_token.transferFrom(payer, address(this), amount), "No enough tokens");

        _borrows[borrower] = _borrows[borrower].sub(amount);
            
        return (amount, 0);
    }
    
    function liquidateBorrow(address borrower, uint amount, address collateral) public {
        require(amount > 0);
        
        require(borrower != msg.sender);
        
        require(_token.balanceOf(msg.sender) >= amount);
        
        Controller ctr = Controller(_controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, collateral, collateralAmount);
    }
}
