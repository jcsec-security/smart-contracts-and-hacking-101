// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
contract CrackTheHashChallenge {

	uint256 public constant DURATION = 20;
	uint256 public startBlock;
	address public operator;
	address public winner;
	string public goal;
	mapping(string submission => address) public participants;
	

	modifier canPlay (string calldata s) {
		// Within submission windows
		require(
			block.number <= startBlock + DURATION,
			"The challenge has closed!"
		);
		// No previous submission sent			
		require(
			participants[s] == address(0),
			"Your answer has been submitted already!"
		);
		// Answer sizer limitation
		require(
			bytes(s).length <= 100,
			"Your answer is too long!"
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

	// Anyone can donate to the contract
	receive() external payable {}

	function newChallenge(string calldata _goal) external onlyOperator() {
		goal = _goal;
		startBlock = block.number;
	}

	function submitAnswer(string calldata answer) external canPlay(answer) {
		participants[answer] = msg.sender;
	}

	function announceWinner(string calldata answer) public onlyOperator(){
		require(
			block.number > startBlock + DURATION,
			"Challenge is still open!"
		);		
		require(
			participants[answer] != address(0x0), 
			"No one submitted the correct answer"
		);
		
		winner = participants[answer];
	}

	function claimPrize() external {
		require(msg.sender == winner, "You are not the winner");
		winner = address(0x0);
		(bool success, ) = payable(msg.sender).call{ value: address(this).balance }("");
		require(success, "Low level call failed");
	}

	function getSubmitter(string calldata answer) external view returns (bool) {
		return participants[answer] == msg.sender;
	}

}
