// SPDX-Licence-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import {IDAO_Governor} from "../interfaces/IDAO_Governor.sol";

library LibProposal {
    bytes32 constant PROPOSAL_STORAGE_POSITION = keccak256("diamond.storage.proposal.storage");

    error ProposalExists(uint256 proposalId);
    error AlreadyVoted(uint256 proposalId, address user);

    struct Proposals {
        mapping(uint256 => IDAO_Governor.Proposal) proposals;
        mapping(address => mapping(uint256 => IDAO_Governor.Vote)) votes;
    }

    function proposalStorage() internal pure returns (Proposals storage ps) {
        bytes32 position = PROPOSAL_STORAGE_POSITION;
        assembly {
            ps.slot := position
        }
    }

    function getProposal(uint256 proposalId) internal view returns (IDAO_Governor.Proposal storage) {
        Proposals storage ps = proposalStorage();
        return ps.proposals[proposalId];
    }

    function setProposal(uint256 proposalId, IDAO_Governor.Proposal memory proposal) internal {
        Proposals storage ps = proposalStorage();
        if (ps.proposals[proposalId].proposalStatus != IDAO_Governor.ProposalStatus.None) {
            revert ProposalExists(proposalId);
        }
        ps.proposals[proposalId] = proposal;
    }

    function viewVote(address user, uint256 proposalId) internal view returns (IDAO_Governor.Vote) {
        Proposals storage ps = proposalStorage();
        return ps.votes[user][proposalId];
    }

    function castVote(uint256 proposalId, address user, IDAO_Governor.Vote vote, uint256 votingUnit) internal {
        Proposals storage ps = proposalStorage();
        if (ps.votes[user][proposalId] != IDAO_Governor.Vote.Abstain) revert AlreadyVoted(proposalId, user);
        ps.votes[user][proposalId] = vote;

        if (vote == IDAO_Governor.Vote.For) {
            ps.proposals[proposalId].forVotes += votingUnit;
        } else if (vote == IDAO_Governor.Vote.Against) {
            ps.proposals[proposalId].againstVotes += votingUnit;
        }
    }
}
