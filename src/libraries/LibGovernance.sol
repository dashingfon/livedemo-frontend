// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {DoubleEndedQueue} from "openzeppelin/utils/structs/DoubleEndedQueue.sol";

/// @title The Library thet helps with handling Governance functions
/// @author Mfon Stephen Nwa
library LibGovernance {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    bytes32 constant GOVERNANCE_STORAGE_POSITION = keccak256("diamond.storage.governance.storage");

    error IsNotProposer(address);
    error IsNotExecutor(address);

    struct Deployment {
        string name;
        address deploymentAddress;
    }

    struct GovernanceSetting {
        uint256 votingPeriod;
        uint256 votingDelay;
        uint256 executionDelay;
        uint256 proposalThreshold;
        uint256 quorumFraction;
    }

    struct GovernanceStorage {
        address[] proposers;
        address[] executors;
        address token;
        GovernanceSetting governorSetting;
        Deployment[] deployments;
        DoubleEndedQueue.Bytes32Deque _governanceCall;
        string uri;
    }

    function governanceStorage() internal view returns (GovernanceStorage storage gs) {
        bytes32 position = GOVERNANCE_STORAGE_POSITION;
        assembly {
            gs.solt := position
        }
    }

    function setURI(string memory _uri) internal {
        GovernanceStorage storage gs = governanceStorage();
        gs.uri = _uri;
    }

    function uri() internal view returns (string memory _uri) {
        GovernanceStorage storage gs = governanceStorage();
        _uri = gs.uri;
    }

    function token() internal view returns (address tokenAddress) {
        GovernanceStorage storage gs = governanceStorage();
        tokenAddress = gs.token;
    }

    function addDeployment(Deployment[] memory deployments) internal {
        GovernanceStorage storage gs = governanceStorage();
        for (uint256 i; i < deployments.length; ++i) {
            gs.deployments.push(deployments[i]);
        }
    }

    function getDeployment(string memory name) internal view returns (address deploymentAddress) {
        GovernanceStorage storage gs = governanceStorage();
        Deployment[] memory deployments = gs.deployments;
        bytes32 nameBytes = keccak256(abi.encodePacked(name));
        for (uint256 i; i < deployments.length; ++i) {
            if (keccak256(abi.encodePacked(deployments[i].name)) == nameBytes) {
                deploymentAddress = deployments[i].deploymentAddress;
                break;
            }
        }
    }

    function viewDeployments(string memory name) internal view returns (Deployment[] memory deployments) {
        GovernanceStorage storage gs = governanceStorage();
        deployments = gs.deployments;
    }

    function ensureIsProposer(address user) internal view {
        GovernanceStorage storage gs = governanceStorage();
        address[] memory proposers = gs.proposers;
        if (proposers.length == 0) return;
        bool isProposer;
        for (uint256 i; i < proposers.length; ++i) {
            if (user == proposers[i]) {
                isProposer = true;
                break;
            }
        }
        if (!isProposer) revert IsNotProposer(user);
    }

    function ensureIsExecutor(address user) internal view {
        GovernanceStorage storage gs = governanceStorage();
        address[] memory executors = gs.executors;
        if (executors.length == 0) return;
        bool isExecutor;
        for (uint256 i; i < executors.length; ++i) {
            if (user == executors[i]) {
                isExecutor = true;
                break;
            }
        }
        if (!isExecutor) revert IsNotProposer(user);
    }

    function setProposers(address[] memory proposers) internal {
        GovernanceStorage storage gs = governanceStorage();
        gs.proposers = proposers;
    }

    function setExecutors(address[] memory executors) internal {
        GovernanceStorage storage gs = governanceStorage();
        gs.executors = executors;
    }
}
