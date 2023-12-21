// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "reentrancy-victim.sol";

contract Attacker {
	
	Reentrancy public target;	
	
	constructor(address _target) {
		target = Reentrancy(_target);
	}
	
	function exploit() external payable {
		// Your code goes here!
	}

	receive() external payable {
		// Your code goes here!
	}

}