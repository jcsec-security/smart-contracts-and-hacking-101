// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;


contract Password2 {

    bytes32 private hashed;

    constructor(bytes32 _hashed) {
        hashed = _hashed;
    }

    function amITheOwner(string calldata secret) public view returns(bool) {
        if (hashed == keccak256(bytes(secret)) ) {
            return true;
        } else {
            return false;
        }
    }

}