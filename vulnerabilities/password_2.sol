// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  Password2
 * @notice Stores a keccak256 hash of the password instead of the plaintext.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x2cd375913249700a36975f55dcca58ae1d7f258a
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract Password2 {

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when the greeting is successfully updated.
    /// @param newGreeting The new greeting string that was set.
    event GreetingUpdated(string newGreeting);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when the provided secret does not match the stored hash.
    error Unauthorized();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @dev keccak256 hash of the password. Still readable from storage off-chain.
    bytes32 private hashed;

    /// @notice The public greeting string.
    string public greeting;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _hashed The keccak256 hash of the initial password.
    constructor(bytes32 _hashed) {
        hashed = _hashed;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Update the greeting if the hash of the provided secret matches.
     * @dev    Emits {GreetingUpdated} on success.
     * @param  _secret   The plaintext password to verify.
     * @param  _greeting The new greeting to set if the password matches.
     */
    function setGreeting(string calldata _secret, string calldata _greeting) public {
        if (hashed != keccak256(bytes(_secret))) revert Unauthorized();
        greeting = _greeting;
        emit GreetingUpdated(_greeting);
    }

    /**
     * @notice Return the greeting with a custom name appended.
     * @param  _name A name to append to the greeting.
     * @return The concatenated greeting string.
     */
    function getGreeting(string calldata _name) public view returns (string memory) {
        return string(abi.encodePacked(greeting, _name));
    }
}