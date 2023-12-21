// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;


contract Password1 {

    bytes32 private hashed;

    constructor(bytes32 _hashed) {
        hashed = _hashed;
    }

    function amITheOwner(string calldata secret, bytes32 newHash) public returns(bool) {
        if (hashed == keccak256(bytes(secret)) ) {
            return true;
        } else {
            hashed = newHash;
            return false;
        }
    }

}