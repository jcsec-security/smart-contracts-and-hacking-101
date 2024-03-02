// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Reentrancy {

    mapping (address => uint256) balance;
	
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }
	
	function withdraw() external {		
		
		require(balance[msg.sender] > 0, "Saldo cero!");	
		
		(bool success, ) = payable(msg.sender).call{value: balance[msg.sender]}("");
		require(success, "Low level call failed");
		
		balance[msg.sender] = 0;	
	}
	
	
	function userBalance (address user) public view returns (uint256) {
		return balance[user];
	}

}