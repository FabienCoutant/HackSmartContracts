// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
// The first one is to create and attack contract that can revert the guess if we are wrong (cf.Attack.sol)
// The second one is to check the choice() transaction on Etherscan, if the input data end with 0 it's a false
// other wise it's true, the solution is to hash the chosen value.
// Cf solution of this exercise is the same than exercise 5.

//*** Exercise ***//
// You choose Head or Tail and send 1 ETH.
// The next party send 1 ETH and try to guess what you chose.
// If it succeed it gets 2 ETH, else you get 2 ETH.
contract HeadOrTail {
    bool public chosen; // True if head/tail has been chosen.
    bool lastChoiceHead; // True if the choice is head.
    address payable public lastParty; // The last party who chose.

    /** @dev Must be sent 1 ETH.
     *  Choose head or tail to be guessed by the other player.
     *  @param _chooseHead True if head was chosen, false if tail was chosen.
     */
    function choose(bool _chooseHead) public payable {
        require(!chosen);
        require(msg.value == 1 ether);

        chosen = true;
        lastChoiceHead = _chooseHead;
        lastParty = payable(msg.sender);
    }

    function guess(bool _guessHead) public payable {
        require(chosen);
        require(msg.value == 1 ether);

        if (_guessHead == lastChoiceHead) payable(msg.sender).transfer(2 ether);
        else lastParty.transfer(2 ether);

        chosen = false;
    }

}
