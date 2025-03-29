// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;


///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
///@custom:deployed-at https://sepolia.etherscan.io/address/0x089ad7a4096b73d03b36723313d9e9f7141d4234
contract Password1 {

    string private passwd;
    string public greeting;


    constructor(string memory _passwd) {
        passwd = _passwd;
    }


    function setGreeting(string calldata _secret, string calldata _greeting) public {
        if (keccak256(bytes(passwd)) == keccak256(bytes(_secret)) ) {
            greeting = _greeting;
        } else {
            revert("Unauthorized");
        }
    }


    function getGreeting(string calldata _name) public view returns(string memory) {
        return string(abi.encodePacked(greeting, _name));
    }

}