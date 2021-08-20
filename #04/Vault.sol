// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//Simple reentrancy attack.

//*** Exercise 4 ***//
// You can store ETH in this contract and redeem them.
contract Vault {
    mapping(address => uint) public balances;

    /// @dev Store ETH in the contract.
    function store() public payable {
        balances[msg.sender]+=msg.value;
    }

    /// @dev Redeem your ETH.
    function redeem() public {
        msg.sender.call{ value: balances[msg.sender] }("");
        balances[msg.sender]=0;
    }
}
