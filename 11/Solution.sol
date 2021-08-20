// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//*** Solution 11 ***//
// Contract for users to register. It will be used by other contracts to attach rights to those users (rights will be linked to user IDs).
// Note that simply being registered does not confer any right.
contract Registry {

    struct User {
        address payable regAddress;
        uint64 timestamp;
        bool registered;
        string name;
        string surname;
        uint nonce;
    }

    // Nonce is used so the contract can add multiple profiles with the same first name and last name.
    mapping(string => mapping(string => mapping(uint => bool))) public isRegistered; // name -> surname -> nonce -> registered/not registered.
    mapping(bytes32 => User) public users; // User isn't identified by address but by his ID, since the same person can have multiple addresses.

    /** @dev Add yourself to the registry.
     *  @param _name The first name of the user.
     *  @param _surname The last name of the user.
     *  @param _nonce An arbitrary number to allow multiple users with the same first and last name.
     */
    function register(string calldata _name, string calldata _surname, uint _nonce) public {
        require(!isRegistered[_name][_surname][_nonce], "This profile is already registered");
        isRegistered[_name][_surname][_nonce] = true;
        bytes32 ID = keccak256(abi.encode(_name, _surname, _nonce)); //Replaced encodePacked by encode
        User storage user = users[ID];
        user.regAddress = payable(msg.sender);
        user.timestamp = uint64(block.timestamp);
        user.registered = true;
        user.name = _name;
        user.surname = _surname;
        user.nonce = _nonce;
    }

}
