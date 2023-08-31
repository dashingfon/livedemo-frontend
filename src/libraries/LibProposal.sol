// SPDX-Licence-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "./interfaces/IDAO_Governor.sol";

library LibProposal {
    bytes32 constant PROPOSAL_STORAGE_POSITION = keccak256("diamond.storage.proposal.storage");

    struct VoteReciept {}

    function getProposal(uint256) internal view {
        
    }

    function setProposal(Proposal proposal) internal {

    }
}
