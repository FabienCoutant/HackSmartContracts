// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//The security breach coming from the deposit() function
//If scalingFactor == 0 you can call the deposit function with msg.value = 0 and block the contract
//due to the toAdd calculation for the next depositor, which will try to dived by a negative number for an uint

//*** Exercise 9 ***//
// Simple coffer you deposit to and withdraw from.
contract CommonCoffers {
    mapping(address => uint) public coffers;
    uint public scalingFactor;

    /** @dev Deposit money in one's coffer slot.
     *  @param _owner The coffer to deposit money on.
     * */
    function deposit(address _owner) payable external {
        if (scalingFactor != 0) {
            uint toAdd = (scalingFactor * msg.value) / (address(this).balance - msg.value);
            coffers[_owner] += toAdd;
            scalingFactor += toAdd;
        }
        else {
            scalingFactor = 100;
            coffers[_owner] = 100;
        }
    }

    /** @dev Withdraw all of the money of one's coffer slot.
    *  @param _amount The slot to withdraw money from.
    * */
    function withdraw(uint _amount) external {
        uint toRemove = (scalingFactor * _amount) / address(this).balance;
        coffers[msg.sender] -= toRemove;
        scalingFactor -= toRemove;
        payable(msg.sender).transfer(_amount);
    }

}
