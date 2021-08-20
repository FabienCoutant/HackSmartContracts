// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Issue / Solution ***//
//The security breach is located in the closeAccount() function.
//When we call this function only the nbSlots is set to 0,
//so we can create a new one for the same address and the slots mapping will still has an amount to withdraw even without new deposit

//*** Exercise 8 ***//
// You can create coffers, deposit money and withdraw from them.
contract Coffers {
    struct Coffer {uint nbSlots; mapping(uint => uint) slots;}
    mapping(address => Coffer) coffers;

    /** @dev Create coffers.
     *  @param _slots The amount of slots the coffer will have.
     * */
    function createCoffer(uint _slots) external {
        Coffer storage coffer = coffers[msg.sender];
        require(coffer.nbSlots == 0, "Coffer already created");
        coffer.nbSlots = _slots;
    }

    /** @dev Deposit money in one's coffer slot.
     *  @param _owner The coffer to deposit money on.
     *  @param _slot The slot to deposit money.
     * */
    function deposit(address _owner, uint _slot) payable external {
        Coffer storage coffer = coffers[_owner];
        require(_slot < coffer.nbSlots);
        coffer.slots[_slot] += msg.value;
    }

    /** @dev Withdraw all of the money of one's coffer slot.
     *  @param _slot The slot to withdraw money from.
     * */
    function withdraw(uint _slot) external {
        Coffer storage coffer = coffers[msg.sender];
        require(_slot < coffer.nbSlots);
        payable(msg.sender).transfer(coffer.slots[_slot]);
        coffer.slots[_slot] = 0;
    }

    /** @dev Close an account withdrawing all the money.
     * */
    function closeAccount() external {
        Coffer storage coffer = coffers[msg.sender];
        uint amountToSend;
        for (uint i=0; i<coffer.nbSlots; ++i)
            amountToSend += coffer.slots[i];
        coffer.nbSlots = 0;
        payable(msg.sender).transfer(amountToSend);
    }
}
