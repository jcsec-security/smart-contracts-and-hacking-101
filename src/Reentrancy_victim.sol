// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  Reentrancy
 * @notice Demonstrates a classic reentrancy vulnerability.
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract Reentrancy {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted on a successful deposit.
    /// @param depositor The depositing address.
    /// @param amount    Wei deposited.
    event Deposited(address indexed depositor, uint256 amount);

    /// @notice Emitted on a successful withdrawal.
    /// @param depositor The withdrawing address.
    /// @param amount    Wei withdrawn.
    event Withdrawn(address indexed depositor, uint256 amount);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when a withdrawal is attempted with a zero balance.
    error ZeroBalance();

    /// @notice Thrown when the low-level ETH transfer fails.
    error TransferFailed();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @dev Tracks each user's deposited balance.
    mapping(address depositor => uint256 amount) private balance;

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Deposit ETH into the contract.
     * @dev    Emits {Deposited}.
     */
    function deposit() external payable {
        balance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw the caller's full balance.
     * @dev    Emits {Withdrawn}.
     */
    function withdraw() external {
        if (balance[msg.sender] == 0) revert ZeroBalance();

        uint256 amount = balance[msg.sender];

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        balance[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Returns the recorded balance for a given user.
     * @param  user The address to query.
     * @return The wei balance of user.
     */
    function userBalance(address user) public view returns (uint256) {
        return balance[user];
    }
}
