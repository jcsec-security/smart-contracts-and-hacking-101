// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IVictim {
	function deposit() external payable;
	function withdraw() external;
	function userBalance (address user) public view returns (uint256);
}

contract Attacker {
	
	IVictim public target;	
	
	constructor(address _target) {
		target = IVictim(_target);
	}
	
	function exploit() external payable {
		// Your code goes here!
	}

	receive() external payable {
		// Your code goes here!
	}

}