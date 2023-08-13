pragma solidity 0.8.19;

interface IDAO_Governor {
    event Proposed (
        address proposer,
        uint256 proposalID,
        Proposal proposal,
        string type
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
    )
    event ProposalUpdated (
        ProposalStatus status,
        uint256 proposalID,
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
        Relay relayType,
        address target,
        uint256 value,
        bytes calldata data
    );
    event UpdatedURI (
        string oldURI
        string newURI
    );

    enum Vote {
        For,
        Against,
        Abstain
    };
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
    };
    struct Call {
        address targetAddress
        bytes targetCalldata 
    };
    struct Proposal {
        uint256 votingPeriod,
        string descriptionURI
        Call[] calls,
    };
    struct Payment {
        address paymentAddress,
        uint256 paymentAmount
        uint256 numberOfInstallments
    };

    struct Results {
        uint256 forVotes,
        uint256 againstVotes,
        uint256 abstainVotes,
        ProposalStatus proposalStatus
    };

    function governorURI() external view returns (string memory);

    function isMember(address user) external view return (bool);

    function setUserProfile(string memory userURI) external;

    function proposeFunding(
        uint256 supplyAmount,
        uint256 recieveAmount,
        uint256 votingPeriod,
        string memory fundingDescriptionURI,
    ) external;

    function proposePayment(
        Payment payment, string memory paymentDescriptionURI, uint256 votingPeriod
    ) external;

    function proposeMultiplePayment(
        Payment[] payment, string memory paymentDescriptionURI, uint256 votingPeriod
    ) external;

    function propose(uint256 votingPeriod, string descriptionURI, Call[] calls) external;

    function getFullProposalDetails(uint256 proposalId) external view returns (
        Proposal proposal, Result proposalResult, string GovernorURI
    );

    function cancelProposal(uint256 proposalID) external;

    function castVote(uint256 proposalID, Vote vote) external;

    function getVoteCast(uint256 proposalId) external returns (Vote vote);

    function getVoteResult(uint256 proposalId) external returns (Results);

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

    function facets() external view returns (Facet[] memory facets_);

    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    function facetAddresses() external view returns (address[] memory facetAddresses_);

    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);

}
