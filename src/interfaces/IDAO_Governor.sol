// SPDX-Licence-Identifier: Unlicenced

pragma solidity 0.8.19;

import "./IDiamondLoupe.sol";
import "./IDiamondCut.sol";
import "./IEventRegister.sol";

interface IDAO_Governor is IDiamondLoupe, IEventRegister, IDiamondCut {
    event Proposed (
        address proposer,
        uint256 proposalID,
        string,
        Proposal proposal
    );
    event ProposalCancelled (
        address canceller,
        uint256 proposalID,
        Proposal proposal
    );
    event ProposalExecuted (
        address executor,
        uint256 proposalID,
        Proposal proposal
    );
    event ProposalUpdated (
        uint256 proposalID,
        ProposalStatus status,
        Proposal proposal
    );
    event ProposalWon (
        uint256 proposalID,
        Proposal proposal,
        Result results
    );

    event ProposalLost (
        uint256 proposalID,
        Proposal proposal,
        Result results
    );
    event Voted (
        address voter,
        uint256 proposalID,
        Proposal proposal,
        Vote vote
    );
    event RelayedCall (
        address target,
        uint256 value,
        bytes,
        Relay relayType
    );
    event UpdatedURI (
        string oldURI,
        string newURI
    );

    enum Vote {
        For,
        Against,
        Abstain
    }
    enum Relay {
        CallRelay,
        DelegatecallRelay
    }
    enum ProposalStatus {
        Delay,
        Cancelled,
        Active,
        Passed,
        Failed,
        Pending,
        Executed
    }
    struct Call {
        address targetAddress;
        bytes targetCalldata;
    }
    struct Proposal {
        uint256 votingPeriod;
        string descriptionURI;
        Call[] calls;
    }
    struct Payment {
        address paymentAddress;
        uint256 paymentAmount;
        uint256 numberOfInstallments;
    }
    struct Result {
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        ProposalStatus proposalStatus;
    }

    function governorURI() external view returns (string memory);

    function isMember(address user) external view returns (bool);

    function getShare() external view returns (uint8);

    function setUserProfile(string memory userURI) external;

    function proposeFunding(
        uint256 supplyAmount,
        uint256 recieveAmount,
        uint256 votingPeriod,
        string memory fundingDescriptionURI
    ) external;

    function proposePayment(
        Payment memory payment, string memory paymentDescriptionURI, uint256 votingPeriod
    ) external;

    function proposeMultiplePayment(
        Payment[] memory payment, string memory paymentDescriptionURI, uint256 votingPeriod
    ) external;

    function propose(uint256 votingPeriod, string memory descriptionURI, Call[] memory calls) external;

    function getFullProposalDetails(uint256 proposalId) external view returns (
        Proposal memory proposal, Result memory proposalResult, string memory GovernorURI
    );

    function cancelProposal(uint256 proposalID) external;

    function castVote(uint256 proposalID, Vote vote) external;

    function getVoteCast(uint256 proposalId) external returns (Vote vote);

    function getVoteResult(uint256 proposalId) external returns (Result memory);

    function execute(uint256 proposalID) external;

    function updateProposal(uint256 proposalID) external;

    /// The functions below will only be callable after the governance process

    function relay(
        address target, uint256 value, bytes calldata data
    ) external payable returns (bool);

    function delegateRelay(
        address target, uint256 value, bytes calldata data
    ) external payable returns (bool);

    function setGovernorURI(string calldata URI) external;

    function addFunctions(
        address facetAddress, bytes4[] memory functionSelectors
    ) external;

    function removeFunctions(
        address facetAddress, bytes4[] memory functionSelectors
    ) external;

    function replaceFunctions(
        address facetAddress, bytes4[] memory functionSelectors
    ) external;
}
