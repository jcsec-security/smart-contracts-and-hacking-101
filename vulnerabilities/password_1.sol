// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;


contract Password1 {

    string private passwd;

    constructor(string memory _passwd) {
        passwd = _passwd;
    }

    function amITheOwner(string calldata secret) public view returns(bool) {
        if (keccak256(bytes(passwd)) == keccak256(bytes(secret)) ) {
            return true;
        } else {
            return false;
        }
    }

}