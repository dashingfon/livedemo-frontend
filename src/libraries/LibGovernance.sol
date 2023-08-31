// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "openzeppelin/utils/structs/DoubleEndedQueue.sol";

/// @title The Library thet helps with handling Governance functions
/// @author Mfon Stephen Nwa
library LibGovernance {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    bytes32 constant GOVERNANCE_STORAGE_POSITION = keccak256("diamond.storage.governance.storage");

    error LibGovernance__NameTooLong();

    modifier enforceGovernance(string name) {
        require(msg.sender == _executor(), "Governor: onlyGovernance");
        if (_executor() != address(this)) {
            bytes32 msgDataHash = keccak256(_msgData());
            // loop until popping the expected operation - throw if deque is empty (operation not authorized)
            while (_governanceCall.popFront() != msgDataHash) {}
        }
        _;
    }

    struct Deployment {
        string name;
        address deploymentAddress;
    }

    struct GovernanceStorage {
        address[] proposers;
        address[] executors;
        address token;
        uint256 votingPeriod;
        uint256 votingDelay;
        uint256 proposalThreshold;
        uint256 quorumFraction;
        Deployment[] deployments;
        DoubleEndedQueue.Bytes32Deque _governanceCall;
        string uri;
    }

    function governanceStorage() internal pure returns (GovernanceStorage storage gs) {
        bytes32 position = GOVERNANCE_STORAGE_POSITION;
        assembly {
            gs.solt := position
        }
    }

    function setURI(string memory uri) internal {
        GovernanceStorage storage gs = governanceStorage();
        gs.uri = uri;
    }

    function uri() internal view returns (string memory _uri) {
        GovernanceStorage storage gs = governanceStorage();
        _uri = gs.uri;
    }

    function token() internal view returns (address tokenAddress) {
        GovernanceStorage storage gs = governanceStorage();
        tokenAddress = gs.token;
    }

    function getShares(address user) internal view returns (uint8) {
        IDAO_Token token = IDAO_Token(token());
        uint256 totalSupply = token.getTotalSupply();
        uint256 owned = token.balanceOf(user, 0);
        if (owned == 0) return 0;
        return (totalSupply / owned) * 100;
    }

    function addDeployment(Deployment[] deployments) internal {
        GovernanceStorage storage gs = governanceStorage();
        for (uint256 i; i < deployments.length; ++i) {
            gs.deployments.push(deployments[i]);
        }
    }

    function getDeployment(string name) internal view returns (address deploymentAddress) {
        GovernanceStorage storage gs = governanceStorage();
        Deployments[] deployments = gs.deployments;
        for (uint256 i; i < deployments.length; ++i) {
            if (deployments[i].name == name) {
                deploymentAddress = deployment[i].deploymentAddress;
                break;
            }
        }
    }

    function isProposer(address user) internal view returns (bool) {}

    function isExecutor(address user) internal view returns (bool) {}

    function isVoter(address user) internal view returns (bool) {}

    functio setProposers() internal;

    functio setExecutors() internal;
}
