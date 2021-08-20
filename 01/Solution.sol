// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Solution 1 ***//
contract Store {

    mapping(address => uint) public safes;

    /// @dev Store some ETH.
    function store() public payable {
        require(msg.value > 0,"Err!");
        safes[msg.sender] = safes[msg.sender] + msg.value;
    }

    /// @dev Take back all the amount stored.
    function take() public {
        require(safes[msg.sender] > 0, "Err!");
        uint256 _amount = safes[msg.sender];
        delete safes[msg.sender];
        payable(msg.sender).transfer(_amount);

    }
}
