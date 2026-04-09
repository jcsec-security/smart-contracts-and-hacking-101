pragma solidity ^0.8.28;

/**
 * @title PullOverPush
 * @notice Allows exactly `BATCH` participants to enlist for an equal share of
 *         the accumulated pot.
 * @dev    After `retrieveAllPush` is called the contract becomes permanently
 *         inoperable — members and the isMember mapping are never reset.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x5EB4202694DD91546f3Dbc6c0Ee37eC2aEfa3E6E
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract PullOverPush {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when a new address joins the participant list.
    /// @param member The address that just enrolled.
    event NewMember(address indexed member);

    /// @notice Emitted when ETH is added to the pot via `receive`.
    /// @param amount The amount of wei received.
    event PotIncreased(uint256 amount);

    /// @notice Emitted after the pot has been distributed to all members.
    /// @param amount The total wei that was distributed.
    event PotDistributed(uint256 amount);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when an address that is already a member calls `participate`.
    error AlreadyJoined();

    /// @notice Thrown when `participate` is called but the member list is full.
    error ListIsFull();

    /// @notice Thrown when `retrieveAllPush` is called before `BATCH` members have joined.
    error WaitingForParticipants();

    /// @notice Thrown when an ETH transfer to one of the members fails.
    /// @dev    This is the root cause of the DoS: one failing recipient blocks everyone.
    error TransferFailed();

    /// @notice Thrown when the amount sent to `receive` is not divisible by `BATCH`.
    error AmountNotDivisible();

    /// @notice Thrown when a zero-value transfer is attempted via `receive`.
    error ZeroTransfer();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @notice The fixed number of participants required before distribution.
    uint256 constant BATCH = 5;

    /// @notice Ordered list of enrolled participant addresses.
    address[] public members;

    /// @notice Quick membership lookup; true if the address has already enrolled.
    mapping(address => bool) public isMember;

    /// @notice Total wei currently held and pending distribution.
    uint256 public pot;

    // -------------------------------------------------------------------------
    // Modifiers
    // -------------------------------------------------------------------------

    /// @dev Reverts if the list is already full or if the caller is already a member.
    modifier canJoin() {
        require(members.length < BATCH, ListIsFull());
        require(!isMember[msg.sender], AlreadyJoined());
        _;
    }

    /// @dev Reverts if fewer than `BATCH` members have enrolled.
    modifier membersReady() {
        require(members.length == BATCH, WaitingForParticipants());
        _;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Fund the pot. The sent amount must be divisible by `BATCH` so
     *         that each participant receives a whole number of wei.
     * @dev    Emits {PotIncreased}. Reverts with {ZeroTransfer} or
     *         {AmountNotDivisible} on invalid input.
     */
    receive() external payable {
        require(msg.value > 0, ZeroTransfer());
        require(msg.value % BATCH == 0, AmountNotDivisible());

        pot += msg.value;
        emit PotIncreased(msg.value);
    }

    /**
     * @notice Enroll the caller as a participant in the redistribution.
     * @dev    Emits {NewMember}. Protected by the `canJoin` modifier.
     */
    function participate() external canJoin {
        members.push(msg.sender);
        isMember[msg.sender] = true;
        emit NewMember(msg.sender);
    }

    /**
     * @notice Push each participant's share of the pot to their address.
     * @dev    Emits {PotDistributed}. Protected by the `membersReady` modifier.
     */
    function retrieveAllPush() external membersReady {
        for (uint256 i; i < members.length; i++) {
            (bool success,) = payable(members[i]).call{value: pot / BATCH}("");
            require(success, TransferFailed());
        }
        emit PotDistributed(pot);
        pot = 0;
    }

    /**
     * @notice Returns whether `_member` is enrolled.
     * @dev    Convenience wrapper around the public `isMember` mapping.
     * @param  _member The address to look up.
     * @return True if `_member` has enrolled, false otherwise.
     */
    function checkIsMember(address _member) public view returns (bool) {
        return isMember[_member];
    }
}
