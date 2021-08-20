// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Solution 13 ***//
// Each player tries to guess the average of all the player's revealed answers combined.
// They must pay 1 ETH to play.
// The winners are those who are the nearest from the average.
// Note that some players may not reveal and use multiple accounts, this is part of the game and can be used tactically.
// Also note that waiting the last minute to reveal is also part of the game and can be used tactically (but it would probably cost a lot of gas).
contract GuessTheAverage {

    uint256 immutable public start; // Beginning of the game.
    uint256 immutable public commitDuration; // Duration of the Commit Period.
    uint256 immutable public revealDuration; // Duration of the Reveal Period.
    uint256 public cursorWinner; // Cursor of the last winner.
    uint256 public cursorDistribute; // Cursor of the last distribution of rewards.
    uint256 public lastDifference; // Last best difference between a guess and the average.
    uint256 public average; // Average to guess.
    uint256 public totalBalance; // Total balance of the contract.
    uint256 public numberOfLosers; // Number of losers in the winners list.
    Stage public currentStage; // Current Stage.

    enum Stage {
        CommitAndRevealPeriod,
        AverageCalculated,
        WinnersFound,
        Distributed
    }

    struct Player {
        uint playerIndex; // Index of the player in the guesses list.
        bool hasGuessed; // Whether the player has guessed or not.
        bool hasReveal; // Whether the player has revealed or not.
        bytes32 commitment; // commitment of the player.
    }

    uint[] public guesses; // List of player's guesses.
    address[] public winners; // List of winners to reward.

    mapping(address => Player) public players; // Maps an address to its respective Player status.
    mapping(uint => address) public indexToPlayer; // Maps a guess index to the player who made the guess.
    mapping(address => uint) public failedDistribute; // Maps addresses who's .send in function distribute failed to allow reward to be claimable


    constructor(uint32 _commitDuration, uint32 _revealDuration) {
        start = block.timestamp;
        commitDuration = _commitDuration;
        revealDuration = _revealDuration;
    }

    /** @dev Adds the guess for the user.
     *  @param _commitment The commitment of the user under the form of keccak256(abi.encodePacked(msg.sender, _number, _blindingFactor) where the blinding factor is a bytes32.
     */
    function guess(bytes32 _commitment) public payable {
        Player storage player = players[msg.sender];
        require(!player.hasGuessed, "Player has already guessed");
        require(msg.value == 1 ether, "Player must send exactly 1 ETH");
        require(block.timestamp >= start && block.timestamp <= start + commitDuration, "Commit period must have begun and not ended");

        // Store the commitment.
        player.hasGuessed = true;
        player.commitment = _commitment;
    }

    /** @dev Reveals the guess for the user.
     *  @param _number The number guessed.
     *  @param _blindingFactor What has been used for the commitment to blind the guess.
     */
    function reveal(uint _number, bytes32 _blindingFactor) public {
        require(block.timestamp >= start + commitDuration && block.timestamp < start + commitDuration + revealDuration, "Reveal period must have begun and not ended");
        Player storage player = players[msg.sender];
        require(!player.hasReveal, "Player has already revealed");
        require(player.hasGuessed, "Player must have guessed");
        // Check the hash to prove the player's honesty
        require(keccak256(abi.encodePacked(msg.sender, _number, _blindingFactor)) == player.commitment, "Invalid hash");

        // Update player and guesses.
        player.hasReveal = true;
        average += _number;
        indexToPlayer[guesses.length] = msg.sender;
        guesses.push(_number);
        player.playerIndex = guesses.length;
    }

    /** @dev Finds winners among players who have revealed their guess.
     *  @param _count The number of transactions to execute. Executes until the end if set to "0" or number higher than number of transactions in the list.
     */
    function findWinners(uint256 _count) public {
        require(block.timestamp >= start + commitDuration + revealDuration, "Reveal period must have ended");
        require(currentStage < Stage.WinnersFound);
        // If we don't have calculated the average yet, we calculate it.
        if (currentStage < Stage.AverageCalculated) {
            average /= guesses.length;
            currentStage = Stage.AverageCalculated;
            totalBalance = address(this).balance;
            cursorWinner += 1;
        }
        // If there is no winner we push the first player into the winners list to initialize it.
        if (winners.length == 0) {
            winners.push(indexToPlayer[0]);
            // Avoid overflow.
            if (guesses[0] > average) lastDifference = guesses[0] - average;
            else lastDifference = average - guesses[0];
        }
        uint256 i = cursorWinner;
        for (; i < guesses.length && (_count == 0 || i < cursorWinner + _count); i++) {
            uint256 difference;
            // Avoid overflow.
            if (guesses[i] > average) difference = guesses[i] - average;
            else difference = average - guesses[i];
            // Compare difference with the latest lowest difference.
            if (difference < lastDifference) {
                // Add winner and update lastDifference.
                cursorDistribute = numberOfLosers = winners.length;
                winners.push(indexToPlayer[i]);
                lastDifference = difference;
            } else if (difference == lastDifference) winners.push(indexToPlayer[i]);
            // If we have passed through the entire array, update currentStage.

        }
        if (i == guesses.length) currentStage = Stage.WinnersFound;
        // Update the cursor in case we haven't finished going through the list.
        cursorWinner += _count;
    }

    /** @dev Distributes rewards to winners.
     *  @param _count The number of transactions to execute. Executes until the end if set to "0" or number higher than number of winners in the list.
     */
    function distribute(uint256 _count) public {
        require(currentStage == Stage.WinnersFound, "Winners must have been found");
        for (uint256 i = cursorDistribute; i < winners.length && (_count == 0 || i < cursorDistribute + _count); i++) {
            // Send ether to the winners, use send not to block.
            bool success = payable(winners[i]).send(totalBalance / (winners.length - numberOfLosers));
            if (!success) failedDistribute[winners[i]] = totalBalance / (winners.length - numberOfLosers);
            if (i == winners.length -1) currentStage = Stage.Distributed;
        }
        // Update the cursor in case we haven't finished going through the list.
        cursorDistribute += _count;
    }

    function claim() public payable {
        require(failedDistribute[msg.sender] > 0, "Err!: nothing to claim");
        uint _amount = failedDistribute[msg.sender];
        delete failedDistribute[msg.sender];
        (bool success, ) = address(msg.sender).call{value: _amount}("");
        require(!success, "Claim failed");
    }
}
