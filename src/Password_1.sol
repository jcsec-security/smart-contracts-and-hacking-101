// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  Password1
 * @notice Demonstrates that private storage variables are NOT secret on a
 *         public blockchain.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x089ad7a4096b73d03b36723313d9e9f7141d4234
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract Password1 {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when the greeting is updated with the correct password.
    /// @param newGreeting The new greeting string that was set.
    event GreetingUpdated(string newGreeting);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when the provided secret does not match the stored password.
    error Unauthorized();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @dev The plaintext password. Marked private but readable via storage inspection.
    string private passwd;

    /// @notice The public greeting string, settable by anyone who knows the password.
    string public greeting;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _passwd The initial password stored at deployment.
    constructor(string memory _passwd) {
        passwd = _passwd;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Update the greeting if the correct password is provided.
     * @dev    Emits {GreetingUpdated} on success.
     * @param  _secret   The caller's guess at the stored password.
     * @param  _greeting The new greeting to set if the password matches.
     */
    function setGreeting(string calldata _secret, string calldata _greeting) public {
        if (keccak256(bytes(passwd)) != keccak256(bytes(_secret))) revert Unauthorized();
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
