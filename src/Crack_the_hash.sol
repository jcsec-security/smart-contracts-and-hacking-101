// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title  CrackTheHashChallenge
 * @notice Demonstrates a front-running vulnerability: the operator posts a goal
 *         string, participants race to submit it, and the winner claims the ETH
 *         prize pool.
 * @custom:deployed-at https://sepolia.etherscan.io/address/0x87F6564D9c065b5f20be57257727F86c7c10d61A
 * @custom:practice-at https://github.com/jcsec-security/learn-solidity-security
 */
contract CrackTheHashChallenge {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when the operator opens a new challenge round.
    /// @param goal       The plaintext string participants must submit.
    /// @param startBlock The block number at which the window opens.
    event ChallengeStarted(string goal, uint256 startBlock);

    /// @notice Emitted when a participant registers an answer.
    /// @param participant The submitting address.
    /// @param answer      The answer string submitted.
    event AnswerSubmitted(address indexed participant, string answer);

    /// @notice Emitted when the operator designates a winner.
    /// @param winner The address awarded the prize.
    event WinnerAnnounced(address indexed winner);

    /// @notice Emitted when the winner collects the prize pool.
    /// @param winner The claiming address.
    /// @param amount The wei transferred.
    event PrizeClaimed(address indexed winner, uint256 amount);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Thrown when a non-operator calls a restricted function.
    error NotOperator();

    /// @notice Thrown when a submission arrives after the window has closed.
    error ChallengeClosed();

    /// @notice Thrown when the same answer string has already been submitted.
    error AlreadySubmitted();

    /// @notice Thrown when a submitted answer exceeds 100 bytes.
    error AnswerTooLong();

    /// @notice Thrown when announceWinner is called before the window closes.
    error ChallengeStillOpen();

    /// @notice Thrown when no participant submitted the provided answer.
    error NoCorrectAnswer();

    /// @notice Thrown when a non-winner calls claimPrize.
    error NotWinner();

    /// @notice Thrown when the ETH transfer to the winner fails.
    error TransferFailed();

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @notice Number of blocks the submission window remains open.
    uint256 public constant DURATION = 20;

    /// @notice The address authorised to manage challenges and announce winners.
    address public operator;

    /// @notice Block number at which the current challenge started.
    uint256 public startBlock;

    /// @notice Winner of the current round; zero address if unclaimed or unset.
    address public winner;

    /// @notice The goal string participants must match to win.
    string public goal;

    /// @notice Maps each submitted answer to the first address that submitted it.
    mapping(string answer => address submitter) public participants;

    // -------------------------------------------------------------------------
    // Modifiers
    // -------------------------------------------------------------------------

    /// @dev Reverts if the caller is not the operator.
    modifier onlyOperator() {
        if (msg.sender != operator) revert NotOperator();
        _;
    }

    /**
     * @dev Validates a submission: window must be open, answer must be unique,
     *      and the answer must be at most 100 bytes long.
     */
    modifier canPlay(string calldata s) {
        if (block.number > startBlock + DURATION) revert ChallengeClosed();
        if (participants[s] != address(0)) revert AlreadySubmitted();
        if (bytes(s).length > 100) revert AnswerTooLong();
        _;
    }

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @dev Sets the deployer as the initial operator.
    constructor() {
        operator = msg.sender;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /// @notice Accept ETH donations to grow the prize pool.
    receive() external payable {}

    /**
     * @notice Open a new challenge round with the given goal string.
     * @dev    Can overwrite an active challenge. Emits {ChallengeStarted}.
     *         Only callable by the operator.
     * @param  _goal The plaintext goal string participants must submit.
     */
    function newChallenge(string calldata _goal) external onlyOperator {
        goal = _goal;
        startBlock = block.number;
        emit ChallengeStarted(_goal, block.number);
    }

    /**
     * @notice Submit an answer during the active challenge window.
     * @dev    Emits {AnswerSubmitted}. Protected by the canPlay modifier.
     * @param  answer The string the caller believes matches the goal.
     */
    function submitAnswer(string calldata answer) external canPlay(answer) {
        participants[answer] = msg.sender;
        emit AnswerSubmitted(msg.sender, answer);
    }

    /**
     * @notice Designate the winner after the submission window has closed.
     * @dev    Emits {WinnerAnnounced}. Only callable by the operator.
     * @param  answer The correct answer string whose first submitter wins.
     */
    function announceWinner(string calldata answer) external onlyOperator {
        if (block.number <= startBlock + DURATION) revert ChallengeStillOpen();
        if (participants[answer] == address(0)) revert NoCorrectAnswer();

        winner = participants[answer];
        emit WinnerAnnounced(winner);
    }

    /**
     * @notice Claim the full ETH prize pool as the announced winner.
     * @dev    Emits {PrizeClaimed}.
     */
    function claimPrize() external {
        if (msg.sender != winner) revert NotWinner();

        winner = address(0);
        uint256 prize = address(this).balance;

        (bool success,) = payable(msg.sender).call{value: prize}("");
        if (!success) revert TransferFailed();

        emit PrizeClaimed(msg.sender, prize);
    }

    /**
     * @notice Check whether the caller was the first to submit a given answer.
     * @param  answer The answer string to look up.
     * @return True if msg.sender submitted this answer first.
     */
    function getSubmitter(string calldata answer) external view returns (bool) {
        return participants[answer] == msg.sender;
    }
}
