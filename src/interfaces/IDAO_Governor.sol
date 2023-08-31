// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
interface IDAO_Governor {
    // event Proposed(address proposer, uint256 proposalID, string, Proposal proposal);
    // event ProposalCancelled(address canceller, uint256 proposalID, Proposal proposal);
    // event ProposalExecuted(address executor, uint256 proposalID, Proposal proposal);
    // event ProposalWon(uint256 proposalID, Proposal proposal, Result results);
    // event ProposalLost(uint256 proposalID, Proposal proposal, Result results);
    // event Voted(address voter, uint256 proposalID, Proposal proposal, Vote vote);
    // event RelayedCall(address target, uint256 value, bytes, Relay relayType);
    // event UpdatedURI(string oldURI, string newURI);

    enum Vote {
        Abstain,
        For,
        Against
    }
    enum ProposalStatus {
        None,
        Delay,
        Cancelled,
        Active,
        Passed,
        Failed,
        Pending,
        Executed
    }

    event Proposed();

    event ProposalCancelled();

    event ProposalExecuted();

    struct Call {
        address targetAddress;
        bytes targetCalldata;
    }

    struct Proposal {
        uint256 proposalId;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 proposalCreationTimestamp;
        uint256 voteStartTimestamp;
        uint256 voteEndTimestamp;
        uint256 executionTimestamp;
        ProposalStatus proposalStatus;
        address proposer;
        string descriptionURI;
        Call[] calls;
    }

    function uri() external view returns (string memory);

    function isMember(address user) external view returns (bool);

    function getShares(address user) external view returns (uint8);

    function proposeListing(
        uint256 supplyAmount,
        uint256 recieveAmount,
        uint256 votingPeriod,
        string memory listingDescriptionURI
    ) external;

    function proposeListings(uint256 supplyAmount) external;

    function proposePayment(Payment memory payment, string memory paymentDescriptionURI, uint256 votingPeriod)
        external;

    function proposePayments(Payment[] memory payment, string memory paymentDescriptionURI, uint256 votingPeriod)
        external;

    function propose(uint256 votingPeriod, string memory descriptionURI, Call[] memory calls) external;

    function getProposal(uint256 proposalId) external view returns (Proposal memory proposal);

    function cancelProposal(uint256 proposalID) external;

    function castVote(uint256 proposalID, Vote vote) external;

    function castVoteBySig() external;

    function castVoteBySigs() external;

    function voteReciept(uint256 proposalId) external returns (Vote vote);

    function execute(uint256 proposalID) external;

    /// The functions below will only be callable after the governance process

    function relay(address target, uint256 value, bytes calldata data) external payable returns (bool);

    function setURI(string calldata URI) external;

    function addFunctions(address facetAddress, bytes4[] memory functionSelectors) external;

    function removeFunctions(address facetAddress, bytes4[] memory functionSelectors) external;

    function replaceFunctions(address facetAddress, bytes4[] memory functionSelectors) external;
}
