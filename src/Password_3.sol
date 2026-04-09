// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  Password3
 * @notice Extends Password2 by allowing the password hash to be rotated on each
 *         successful setGreeting call.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x5023dA798a1bAa56D2152b6c85d7816Ef0133164
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract Password3 {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when the greeting and password hash are updated.
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

    /// @dev keccak256 hash of the current password.
    bytes32 private hashedPw;

    /// @notice The public greeting string.
    string public greeting;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _hashed The keccak256 hash of the initial password.
    constructor(bytes32 _hashed) {
        hashedPw = _hashed;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Update the greeting and rotate the password hash if authenticated.
     * @dev    Emits {GreetingUpdated} on success.
     * @param  _secret   The current plaintext password.
     * @param  _newHash  The keccak256 hash of the next password.
     * @param  _greeting The new greeting to set.
     */
    function setGreeting(string calldata _secret, bytes32 _newHash, string calldata _greeting) public {
        if (hashedPw != keccak256(bytes(_secret))) revert Unauthorized();

        hashedPw = _newHash;
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
