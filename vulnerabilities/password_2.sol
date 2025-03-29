// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;


///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
///@custom:deployed-at https://sepolia.etherscan.io/address/0x2cd375913249700a36975f55dcca58ae1d7f258a
contract Password2 {

    bytes32 private hashed;
    string public greeting;


    constructor(bytes32 _hashed) {
        hashed = _hashed;
    }


    function setGreeting(string calldata _secret, string calldata _greeting) public {
        if (hashed == keccak256(bytes(_secret))) {
            greeting = _greeting;
        } else {
            revert("Unauthorized");
        }
    }


    function getGreeting(string calldata _name) public view returns(string memory) {
        return string(abi.encodePacked(greeting, _name));
    }    

}