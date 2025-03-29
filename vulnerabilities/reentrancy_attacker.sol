// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
interface IVictim {
	function deposit() external payable;
	function withdraw() external;
	function userBalance (address user) external view returns (uint256);
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