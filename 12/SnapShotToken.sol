// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//Float problem: The _newBalance calculated in the buyToken() function rounds down
//if msg.value is not a multiple of 10^18
//The simplest solution is to decide that the token has 18 decimals like Ether which means that now
//we can only do  uint _newBalance = _balance + msg.value

//*** Exercise 12 ***//
// A Token contract that keeps a record of the users past balances.
contract SnapShotToken {
    mapping(address => uint) public balances;
    mapping(address => mapping(uint => uint)) public balanceAt;

    event BalanceUpdated(address indexed user, uint oldBalance, uint newBalance);

    /// @dev Buy token at the price of 1ETH/token.
    function buyToken() public payable {
        uint _balance = balances[msg.sender];
        uint _newBalance = _balance + msg.value / 1 ether;
        balances[msg.sender] = _newBalance;

        _updateCheckpoint(msg.sender, _balance, _newBalance);
    }

    /** @dev Transfer tokens.
     *  @param _to The recipient.
     *  @param _value The amount to send.
     */
    function transfer(address _to, uint _value) public {
        uint _balancesFrom = balances[msg.sender];
        uint _balancesTo = balances[_to];

        uint _balancesFromNew = _balancesFrom - _value;
        balances[msg.sender] = _balancesFromNew;

        uint _balancesToNew = _balancesTo + _value;
        balances[_to] = _balancesToNew;

        _updateCheckpoint(msg.sender, _balancesFrom, _balancesFromNew);
        _updateCheckpoint(_to, _balancesTo, _balancesToNew);
    }

    /**
     * @dev Record the users balance at this blockNumber
     *
     * @param _user The address who's balance is updated.
     * @param _oldBalance The previous balance.
     * @param _newBalance The updated balance.
     */
    function _updateCheckpoint(address _user, uint _oldBalance, uint _newBalance) internal {
        balanceAt[_user][block.timestamp] = _newBalance;
        emit BalanceUpdated(_user, _oldBalance, _newBalance);
    }
}
