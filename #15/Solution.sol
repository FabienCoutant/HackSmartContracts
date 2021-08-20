// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Solution 15 ***//.
// This is a game where an Owner considered as TRUSTED can set rounds with rewards.
// The Owner allows several users to compete for the rewards. The fastest user gets all the rewards.
// The users can propose new rounds but it's up to the Owner to fund them.
// The Owner can clear the rounds to create fresh new ones.
contract WinnerTakesAll2 {

    struct Round {
        bool isActive;
        uint rewards;
        mapping(address => bool) isAllowed;
    }

    address owner;
    mapping(uint => Round) public rounds;
    uint public roundsCounter = 1;
    uint public activeRoundsCounter;


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function createNewRounds(uint _numberOfRounds) external {
        uint i = roundsCounter;
        uint j = activeRoundsCounter;
        for (; i <= _numberOfRounds; i++) {
            rounds[i].isActive=true;
            j++;
        }
        roundsCounter = i;
        activeRoundsCounter=j;
    }

    function setRewardsAtRound(uint _roundIndex) external payable onlyOwner() {
        require(rounds[_roundIndex].rewards == 0 && rounds[_roundIndex].isActive);
        rounds[_roundIndex].rewards = msg.value;
    }

    function setRewardsAtRoundFor(uint _roundIndex, address[] calldata _recipients) external onlyOwner() {
        require(rounds[_roundIndex].isActive);
        for (uint i; i < _recipients.length; i++) {
            rounds[_roundIndex].isAllowed[_recipients[i]] = true;
        }
    }

    function isAllowedAt(uint _roundIndex, address _recipient) external view returns (bool) {
        return rounds[_roundIndex].isAllowed[_recipient];
    }

    function withdrawRewards(uint _roundIndex) external {
        require(rounds[_roundIndex].isActive);
        require(rounds[_roundIndex].rewards>0);
        require(rounds[_roundIndex].isAllowed[msg.sender]);
        uint amount = rounds[_roundIndex].rewards;
        rounds[_roundIndex].rewards = 0;
        rounds[_roundIndex].isActive=false;
        activeRoundsCounter--;
        payable(msg.sender).transfer(amount);
    }

    function withdrawETH() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
    }

    function clearRounds() public onlyOwner {
        uint[] memory _activeRoundsList = getActiveRoundsIndexList();
        for(uint i; i< _activeRoundsList.length;i++){
            rounds[_activeRoundsList[i]].isActive=false;
        }
        activeRoundsCounter=0;
    }

    function getActiveRoundsIndexList() public view returns(uint[] memory){
        uint[] memory _activeRoundsList= new uint[](activeRoundsCounter);
        uint j;
        for(uint i=1;i<=roundsCounter;i++){
            if(rounds[i].isActive){
                _activeRoundsList[j]=i;
                j++;
            }
        }
        return _activeRoundsList;
    }
}
