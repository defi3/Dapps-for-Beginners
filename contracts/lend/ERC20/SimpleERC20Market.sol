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
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./ERC20Market.sol";
import "./ERC20Controller.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/SafeMath.sol";

contract SimpleERC20Market is ERC20Market {
    using SafeMath for uint256;
    
    uint public constant FACTOR = 1e6;

    mapping (address => uint) internal _supplies;
    mapping (address => uint) internal _borrows;


    constructor(address token_) ERC20Market(token_) public {
    }


    function supplyOf(address account) external view returns (uint) {
        return _supplies[account];
    }
    
    function borrowBy(address account) external view returns (uint) {
        return _borrows[account];
    }


    function _supply(address supplier, uint amount) internal {
        _supplies[supplier] = _supplies[supplier].add(amount);
    }

    function _redeem(address supplier, address receiver, uint amount) internal {
        require(_supplies[supplier] >= amount);

        require(IERC20(_token).transfer(receiver, amount), "No enough tokens");

        _supplies[supplier] = _supplies[supplier].sub(amount);
        
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint health;
        
        (status, health) = ctr.accountHealth(supplier);
        
        require(status);
    }

    function _borrow(address borrower, uint amount) internal {
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint liquidity;
        
        (status, liquidity) = ctr.accountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        require(IERC20(_token).transfer(borrower, amount), "No enough tokens to borrow");

        _borrows[borrower] = _borrows[borrower].add(amount);
    }

    function _payBorrow(address payer, address borrower, uint amount) internal returns (uint paid, uint additional_) {
        require(_borrows[borrower] > 0);

        require(IERC20(_token).transferFrom(payer, address(this), amount), "No enough tokens");
        
        uint additional;
        
        if (amount > _borrows[borrower]) {
            additional = amount.sub(_borrows[borrower]);
            amount = _borrows[borrower];
        }

        _borrows[borrower] = _borrows[borrower].sub(amount);
        
        if (additional > 0)
            _supply(payer, additional);
            
        return (amount, additional);
    }
    
    
    function liquidateBorrow(address borrower, uint amount, address collateral) public {
        require(amount > 0);
        
        require(borrower != msg.sender);
        
        require(IERC20(_token).balanceOf(msg.sender) >= amount);
        
        ERC20Controller ctr = ERC20Controller(_controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = _payBorrow(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, collateral, collateralAmount);
    }
}

