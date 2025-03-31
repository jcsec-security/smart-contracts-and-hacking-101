// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

///@custom:deployed-at https://sepolia.etherscan.io/address/0x4747df6e3bc844b21f681dcf0270e9cab51b33a6
///@custom:practice-at https://github.com/jcsec-security/learn-solidity-security
contract FirstApp {

    event Deposit(address depositor, uint256 amount);
    event Withdraw(address depositor, uint256 amount);  
    event ReceiveTrigered();
    error EmptyDeposit();
    error NoFunds();
    error FailedWithdrawal();

    string greeting;
    mapping(address depositor => uint256 funds) balance;
    mapping (address depositor => uint256 n_block) latest_deposit;


    // Sets the greeting msg
    constructor(string memory _hi) {
        greeting = _hi;
    }


    // Creates a deposit with the attached ether
    function deposit() payable public {
        if (msg.value == 0) {
            revert EmptyDeposit();
        }

        balance[msg.sender] += msg.value;
        latest_deposit[msg.sender] = block.number; 

        emit Deposit(msg.sender, msg.value);  
    } 


    // Withdraw user funds
    function withdraw() external returns(uint256 amount) {
        if (balance[msg.sender] == 0) {
            revert NoFunds();
        }

        amount = balance[msg.sender];
        balance[msg.sender] = 0; 

        // Send back the deposit
        (bool _success, ) = payable(msg.sender).call{value:amount}("");
        if(!_success) revert FailedWithdrawal();

        emit Withdraw(msg.sender, amount); 
    }


    // If the contract do not implement the special functions receive() or fallback()
    // the contract will not be able to receive funds transfers without calldata!
    receive() payable external {
        deposit();
        emit ReceiveTrigered();
    }


    // Get user balance
    function getBalance(address _addr) external view returns (uint256 amount) {
        return balance[_addr];
    }


    // Get a custom greeting back!
    function getGreeting(string calldata _name) public view returns (string memory) {
        return string(abi.encodePacked(greeting, _name));
    }

}