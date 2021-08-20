// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//Denied of Service (DoS): using a selfdestruct() function from another contract we could block the fund because
//the balance of piggyBank will be > 10 ether.
//The solution is to avoid strict equality on withdraw

//*** Exercise 14 ***//
// This is a piggy bank.
// The owner can deposit 1 ETH whenever he wants.
// He can only withdraw when the deposited amount reaches 10 ETH.
contract PiggyBank {

    address owner;

    /// @dev Set msg.sender as owner
    constructor() {
        owner = msg.sender;
    }

    /// @dev Deposit 1 ETH in the smart contract
    function deposit() public payable {
        require(msg.sender == owner && msg.value == 1 ether && address(this).balance <= 10 ether);
    }

    /// @dev Withdraw the entire smart contract balance
    function withdrawAll() public {
        require(msg.sender == owner && address(this).balance == 10 ether);
        payable(owner).send(address(this).balance);
    }
}
