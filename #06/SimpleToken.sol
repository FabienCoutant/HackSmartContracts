// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;


//*** Issue / Solution ***//
//The amount of token is typed as int that means that balances could be negative.
//The solution is to replace int by uint
//Note: As we contract using pragma > 0.8.x, overflow & underflow are already handled => otherwise using SafeMath will be required

//*** Exercise 6 ***//
// Simple token you can buy and send.
contract SimpleToken {
    mapping(address => int) public balances;

    /// @dev Creator starts with all the tokens.
    constructor()  {
        balances[msg.sender]+= 1000e18;
    }

    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, int _amount) public {
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }

}
