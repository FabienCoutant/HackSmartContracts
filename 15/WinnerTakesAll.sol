// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//When admin delete rounds using the clearRounds() function, the array will be empty and the Rounds.rewards value
//set to 0 but not the isAllowed mapping. That means that after clearing rounds, new rounds is created the previous
//allowed address will be defined as isAllowed and call the withdrawRewards() function even if the owner doesn't
//defined the previous users as allowed and the function can be call directly after the owner set the reward.
//Solution: add an isActive bool in the struct instead of deleting. Using mapping for rounds instead of array is cost efficient

//*** Exercise 15 ***//.
// This is a game where an Owner considered as TRUSTED can set rounds with rewards.
// The Owner allows several users to compete for the rewards. The fastest user gets all the rewards.
// The users can propose new rounds but it's up to the Owner to fund them.
// The Owner can clear the rounds to create fresh new ones.
contract WinnerTakesAll {

    struct Round {
        uint rewards;
        mapping(address => bool) isAllowed;
    }

    address owner;
    Round[] rounds;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function createNewRounds(uint _numberOfRounds) external {
        for (uint i = 0; i < _numberOfRounds; i++) {
            rounds.push();
        }
    }

    function setRewardsAtRound(uint _roundIndex) external payable onlyOwner() {
        require(rounds[_roundIndex].rewards == 0);
        rounds[_roundIndex].rewards = msg.value;
    }

    function setRewardsAtRoundFor(uint _roundIndex, address[] calldata _recipients) external onlyOwner() {
        for (uint i; i < _recipients.length; i++) {
            rounds[_roundIndex].isAllowed[_recipients[i]] = true;
        }
    }

    function isAllowedAt(uint _roundIndex, address _recipient) external view returns (bool) {
        return rounds[_roundIndex].isAllowed[_recipient];
    }

    function withdrawRewards(uint _roundIndex) external {
        require(rounds[_roundIndex].isAllowed[msg.sender]);
        uint amount = rounds[_roundIndex].rewards;
        rounds[_roundIndex].rewards = 0;
        payable(msg.sender).transfer(amount);
    }

    function clearRounds() external onlyOwner {
        delete rounds;
    }

    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
