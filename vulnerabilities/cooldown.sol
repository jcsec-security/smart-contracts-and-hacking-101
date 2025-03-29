// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;


///@dev This contract includes an example of an integer underflow please be aware that although solidity > 0.8.0
/// checks arith it doesn´t mean that it can´t cause an issue then there is a over/underflow.
///@custom:deployed-at ETHERSCAN URL
///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
contract Example5 {

    mapping (address depositor => uint256) balance;
	mapping (address depositor => uint256 n_block) latest_deposit;
	

    function deposit() external payable {
        balance[msg.sender] += msg.value;
		latest_deposit[msg.sender] = block.number;
    }
	

	function withdraw() external {
		// Check
		require(latest_deposit[msg.sender] - block.number > 10,
			"A cooldown of 10 blocks is required!"
		);

		// Effects
		uint256 toWithdraw = balance[msg.sender];
		balance[msg.sender] = 0;

		// Interactions
		(bool success, ) = payable(msg.sender).call{value: toWithdraw}("");
		require(success, "Low level call failed");
	}

}