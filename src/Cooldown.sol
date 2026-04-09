// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  Cooldown
 * @notice Demonstrates an integer underflow vulnerability in Solidity >= 0.8.
 * @dev    Despite checked arithmetic preventing silent wrapping, the subtraction
 *         in withdraw() has its operands reversed (latestDeposit - block.number
 *         instead of block.number - latestDeposit), causing a panic revert on
 *         every withdrawal attempt. Deposited funds are permanently locked.
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract Cooldown {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when a user successfully deposits ETH.
    /// @param depositor The depositing address.
    /// @param amount    Wei deposited.
    event Deposited(address indexed depositor, uint256 amount);

    /// @notice Emitted when a user successfully withdraws ETH.
    /// @param depositor The withdrawing address.
    /// @param amount    Wei withdrawn.
    event Withdrawn(address indexed depositor, uint256 amount);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when a withdrawal is attempted with no balance.
    error NoFunds();

    /// @notice Thrown when the cooldown period has not elapsed.
    error CooldownNotElapsed();

    /// @notice Thrown when the low-level transfer in withdraw fails.
    error TransferFailed();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @dev Tracks each depositor's balance.
    mapping(address depositor => uint256 amount) private balance;

    /// @dev Records the block number of each depositor's last deposit.
    mapping(address depositor => uint256 blockNumber) private latestDeposit;

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Deposit ETH. Records the current block number for the cooldown check.
     * @dev    Emits {Deposited}.
     */
    function deposit() external payable {
        balance[msg.sender] += msg.value;
        latestDeposit[msg.sender] = block.number;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Attempt to withdraw the caller's balance after a 10-block cooldown.
     * @dev    Emits {Withdrawn} on success (unreachable in practice).
     */
    function withdraw() external {
        if (balance[msg.sender] == 0) revert NoFunds();

        if (latestDeposit[msg.sender] - block.number <= 10) revert CooldownNotElapsed();

        uint256 toWithdraw = balance[msg.sender];
        balance[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: toWithdraw}("");
        if (!success) revert TransferFailed();

        emit Withdrawn(msg.sender, toWithdraw);
    }
}
