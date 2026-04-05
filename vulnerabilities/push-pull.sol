// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

uint256 constant BATCH = 5;

/**
    @notice This contract allows a total of `BATCH` participants enlist for equal funds
    distribution. 
    @custom:deployed-at INSERT ETHERSCAN URL
    @custom:practice-at https://github.com/jcsec-security/learn-solidity-security    
 */
contract PullOverPush is Ownable {

    address[] members;  
    uint256 public pot;

    constructor() {}

    // Checks if there is room for a new participant and that it is not already in the list
    modifier newParticipant() {
        require (members.length < BATCH, "The list is full!");
        for (uint256 i; i < members.length; i++) {
            if (members[i] == msg.sender) revert("Already a participant!");
        }
        _;
    }

    // Checks if the participation is closed
    modifier participationClosed() {
        require (members.length == BATCH, "Waiting for additional participants...");
        _;
    }

    receive() external payable {
        require(msg.value > 0, "Zero transfer not allowed");
        require(msg.value % BATCH == 0, "You should add at least 1 wei per participant");

        pot += msg.value;
    }

    // Enroll your own address into the re-distribution
    function participate() external newParticipant {
        members.push(msg.sender);
    }

    // Anyone can force the "push" of all the members
    function retrieveAllPush() external participationClosed {
        for (uint256 i; i < members.length; i++) {
            (bool success, ) = payable(members[i]).call{value: pot / BATCH}("");
            require(success, "Transfer failed.");         }
    }
}
