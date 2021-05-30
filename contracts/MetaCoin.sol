pragma solidity ^0.5.16;

contract MetaCoin {
    /// @notice EIP-20 token name for this token
    string public constant name = "MetaCoin";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "MC";
    
    /// @notice Total number of tokens in circulation
    uint public constant totalSupply = 10000;
    
    /// @notice Official record of token balances for each account
    mapping (address => uint)  internal balances;
    
    /// @notice Allowance amounts on behalf of others
    mapping (address => mapping (address => uint)) internal allowances;
	
	constructor (address account) public {
	    require(msg.sender == account, "MetaCoin::constructor: only the specific account can create a new contract");
	    
		balances[account] = totalSupply;
	}
	
	function transfer(address _to, uint amount) public returns(bool) {
	    require(_to != address(0));
	    
		require(balances[msg.sender] >= amount, "MetaCoin::transfer: msg.sender does not have enough amount");
		
		balances[msg.sender] -= amount;
		balances[_to] += amount;
		
		return true;
	}
	
	function transfer(address _from, address _to, uint amount) public returns(bool) {
	    require(_to != address(0));
	    
		require(balances[_from] >= amount, "MetaCoin::transfer: _from does not have enough amount");
		
		require(allowances[_from][msg.sender] >= amount, "MetaCoin::transfer: msg.sender is not allowed to send amount from _from");
		
		balances[_from] -= amount;
		balances[_to] += amount;
		
		allowances[_from][msg.sender] -= amount;
		
		return true;
	}
	
	/**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
	
	/**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }
    
    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     */
    function approve(address spender, uint amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        
        /// emit Approval(msg.sender, spender, amount);
        
        return true;
    }
}
