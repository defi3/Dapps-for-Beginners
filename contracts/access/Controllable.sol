/**
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  @Authoer defi3
 * 
 * 
 *  Creation, 2021-06
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 *  Main Update 2, 2021-06-19, follow style of Ownable from OpenZeppelin
 * 
 */
pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Controllable is Ownable {
    address private _controller;

    /**
     * @dev The Controllable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() Ownable() {
    }

    /**
     * @return the address of the controller.
     */
    function controller() public view returns(address) {
        return _controller;
    }
    
    function _isController() internal view returns(bool) {
        return _msgSender() == _controller;
    }
    
    function setController(address controller_) external onlyOwner {
        _controller = controller_;
    }
    

    modifier onlyController() {
        require(_isController(), "Controllable::_: only controller can call it");
        _;
    }
    
    modifier onlyOwnerOrController() {
        require(_isOwner() || _isController(), "Controllable::_: only owner or controller can call it");
        _;
    }
}