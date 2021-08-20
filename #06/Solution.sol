// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Solution 6 ***//
// Simple token you can buy and send.
contract SimpleToken {
    mapping(address => uint) public balances;

    /// @dev Creator starts with all the tokens.
    constructor()  {
        balances[msg.sender]+= 1000e18;
    }

    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, uint _amount) public {
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }

}
