// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IEventRegister {
    event ProposalExecuted();

    event Proposed();

    event ProposalCancelled();

    function registerVoteUpdate(
        address dao,
        address sender,
        uint256 senderBalance,
        address reciever,
        uint256 recieverBalance
    ) external;

    function registerUpdatedGovernanceURI() external;

    function registerProposal() external;

    function registerProposalCancelled() external;

    function registerProposalExecuted() external;

    // function registerAddFunction();

    // function registerRemoveFunction();

    // function registerReplaceFunction();
}