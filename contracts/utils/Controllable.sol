/**
 *  @Authoer defi3
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";


contract Controllable is Ownable {
    address internal _controller;

    /**
     * @dev The Controllable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() Ownable() internal {
    }

    /**
     * @return the address of the controller.
     */
    function controller() public view returns(address) {
        return _controller;
    }
    
    function setController(address controller_) external onlyOwner {
        _controller = controller_;
    }

    modifier onlyController() {
        require(isController(), "Controllable: only controller can call it");
        _;
    }
    
    modifier onlyOwnerOrController() {
        require((msg.sender == _owner) || (msg.sender == _controller), "Controllable: only owner or controller can call it");
        _;
    }

    function isController() public view returns(bool) {
        return msg.sender == _controller;
    }
}