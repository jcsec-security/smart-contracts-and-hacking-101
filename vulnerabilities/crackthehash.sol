// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;


contract CrackTheHashChallenge {

	uint256 public constant DURATION = 20;
	uint256 public start_block;
	address public operator;
	string public goal;
	mapping(string => address) participants;
	
	modifier canPlay (string calldata s) {
		require(
			block.number <= start_block + DURATION,
			"Challenge closed!"
		);
		require(
			participants[s] == address(0),
			"This answer has been submitted already!"
		);		
		_;
	}
	
	modifier onlyOperator() {
		require(msg.sender == operator, "Unauthorized");
		_;
	}
	
	constructor() {
		operator = msg.sender;
	}
	
	function newChallenge(string calldata _goal) external onlyOperator() {
		goal = _goal;
		start_block = block.number;
	}
	
	function submitAnswer(string calldata answer) external canPlay(answer) {
		participants[answer] = msg.sender;
	}
	
	function announceWinner(string calldata answer) public view onlyOperator() returns(address) {
		require(
			block.number > start_block + DURATION,
			"Challenge is still open!"
		);		
		
		return participants[answer];
	}
	

}