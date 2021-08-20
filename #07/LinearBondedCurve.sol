// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//The maths of the curve has an issue and it's not really linear but more as steps. That means that we can
//buy and directly sell after for the exact amount needed to get back the investment.
//Add the end we can create as much as token we want for free

//*** Exercise 7 ***//
// Simple token you can buy and send through a bonded curve. We assume that order front running is fine.
contract LinearBondedCurve {
    mapping(address => uint) public balances;
    uint public totalSupply;

    /// @dev Buy token. The price is linear to the total supply.
    function buy() public payable {
        uint tokenToReceive =  (1e18 * msg.value) / (1e18 + totalSupply);
        balances[msg.sender] += tokenToReceive;
        totalSupply += tokenToReceive;
    }

    /// @dev Sell token. The price of it is linear to the supply.
    /// @param _amount The amount of tokens to sell.
    function sell(uint _amount) public {
        uint ethToReceive = ((1e18 + totalSupply) * _amount) / 1e18;
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        payable(msg.sender).transfer(ethToReceive);
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
