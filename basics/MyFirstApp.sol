// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  FirstApp
 * @notice A basic deposit/withdraw contract for teaching Solidity fundamentals.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x4747df6e3bc844b21f681dcf0270e9cab51b33a6
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract FirstApp {

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when a user deposits ETH.
    /// @param depositor The address that made the deposit.
    /// @param amount    The amount of wei deposited.
    event Deposit(address indexed depositor, uint256 amount);

    /// @notice Emitted when a user withdraws their full balance.
    /// @param depositor The address that withdrew.
    /// @param amount    The amount of wei withdrawn.
    event Withdraw(address indexed depositor, uint256 amount);

    /// @notice Emitted when the contract's receive hook is triggered.
    event ReceiveTriggered();

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when a deposit of zero wei is attempted.
    error EmptyDeposit();

    /// @notice Thrown when a withdrawal is attempted with a zero balance.
    error NoFunds();

    /// @notice Thrown when the low-level ETH transfer in withdraw fails.
    error FailedWithdrawal();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @notice A greeting message set at deployment.
    string public greeting;

    /// @notice Tracks each depositor's current balance.
    mapping(address depositor => uint256 funds) public balance;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _hi The initial greeting string.
    constructor(string memory _hi) {
        greeting = _hi;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Deposit ETH into the contract. The sent value is credited to the caller.
     * @dev    Emits {Deposit}. Reverts with {EmptyDeposit} if msg.value is zero.
     */
    function deposit() public payable {
        if (msg.value == 0) revert EmptyDeposit();
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw the caller's entire balance back to their address.
     * @dev    Emits {Withdraw}. Reverts with {NoFunds} or {FailedWithdrawal}.
     * @return amount The wei sent back to the caller.
     */
    function withdraw() external returns (uint256 amount) {
        if (balance[msg.sender] == 0) revert NoFunds();
        
        amount = balance[msg.sender];
        balance[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert FailedWithdrawal();

        emit Withdraw(msg.sender, amount);
    }

    /**
     * @notice Fallback for plain ETH transfers — routes them through deposit().
     * @dev    Emits {ReceiveTriggered} in addition to {Deposit} from the
     *         internal deposit() call.
     */
    receive() external payable {
        deposit();
        emit ReceiveTriggered();
    }

    /**
     * @notice Returns the ETH balance recorded for a given address.
     * @dev    Note: the public mapping already exposes an auto-generated getter.
     *         This function exists for teaching clarity.
     * @param  _addr The address to query.
     * @return amount The wei balance of _addr.
     */
    function getBalance(address _addr) external view returns (uint256 amount) {
        return balance[_addr];
    }

    /**
     * @notice Prepends the stored greeting to a provided name.
     * @param  _name A name to append to the greeting.
     * @return The concatenated greeting string.
     */
    function getGreeting(string calldata _name) public view returns (string memory) {
        return string(abi.encodePacked(greeting, _name));
    }
}