// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;


///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
///@custom:deployed-at https://sepolia.etherscan.io/address/0x97c5482c40871c059126669c7ee16138da1f6de9
contract Password3 {

    bytes32 private hashedPw;
    string public greeting;

    constructor(bytes32 _hashed) {
        hashedPw = _hashed;
    }

    function setGreeting(string calldata _secret, bytes32 _newHash, string calldata _greeting) public {
        if (hashedPw == keccak256(bytes(_secret))) {
            hashedPw = _newHash;
            greeting = _greeting;
        } else {
            revert("Unauthorized");
        }
    }


    function getGreeting(string calldata _name) public view returns(string memory) {
        return string(abi.encodePacked(greeting, _name));
    }       

}