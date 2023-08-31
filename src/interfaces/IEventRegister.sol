// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IDAO_Governor} from "./IDAO_Governor.sol";

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

    function registerUpdatedGovernanceURI(address dao, string memory newURI) external;

    function registerProposal(
        address dao,
        address proposer,
        string memory proposalURI,
        IDAO_Governor.Call[] memory calls,
        uint256 timestampCreated
    ) external;

    function registerProposalCancelled(uint256 proposalId) external;

    function registerProposalExecuted(uint256 proposalId) external;

    function registerAddFunction(bytes4[] memory selector, address facet) external;

    function registerRemoveFunction(bytes4[] memory selector, address facet) external;

    function registerReplaceFunction(bytes4[] memory selector, address facet) external;
}
