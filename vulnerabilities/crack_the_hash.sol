// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;


///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
contract CrackTheHashChallenge {

		uint256 public constant DURATION = 20;
		uint256 public start_block;
		address public operator;
		address public winner;
		string public goal;
		mapping(string submission => address) participants;
		

		modifier canPlay (string calldata s) {
			// Within submission windows
			require(
				block.number <= start_block + DURATION,
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
			start_block = block.number;
		}

		function submitAnswer(string calldata answer) external canPlay(answer) {
			participants[answer] = msg.sender;
		}

		function announceWinner(string calldata answer) public view onlyOperator(){
			require(
				block.number > start_block + DURATION,
				"Challenge is still open!"
			);		
			require(
				participants[answer] != address(0x0), 
				"No one submitted the correct answer"
			);
			
			winner = participants[answer];
		}

		function claimPrice() external {
			require(msg.sender == winner, "You are not the winner");
			winner = address(0x0);
			payable(msg.sender).call{ value: address(this).balance }("");
		}

}
