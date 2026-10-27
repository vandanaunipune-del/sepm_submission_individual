// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    string public greet = "Hello World!";
    uint256 public newVal = 123;

    constructor(string memory _greet) {
        greet = _greet;
    }
}