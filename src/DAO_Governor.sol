// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// External Library

import "openzeppelin/utils/Address.sol";
import {ERC1155Holder} from "openzeppelin/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "openzeppelin/token/ERC721/utils/ERC721Holder.sol";

/// Interfaces

import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "./interfaces/IDiamondLoupe.sol";
import {IDAO_Governor, IListing, IPayment} from "./interfaces/IDAO_Governor.sol";
import {IDAO_Token} from "./interfaces/IDAO_Token.sol";
import {IEventRegister} from "./interfaces/IEventRegister.sol";

/// Libraries

import {LibDiamond} from "./libraries/LibDiamond.sol";
import {LibGovernance} from "./libraries/LibGovernance.sol";
import {LibProposal} from "./libraries/LibProposal.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
abstract contract DAO_Governor is IDAO_Governor, ERC1155Holder, ERC721Holder {
    error ProposalIdExists(uint256);
    error ContractNotDeployed(string);
    error NotAMember(address);
    error VotingNotStarted(uint256 proposalId);
    error InvalidProposal(uint256 proposalId);
    error InvalidState();
    error NotTheProposer(address caller, uint256 proposalId);
    error NoVotingRights(address caller, uint256 proposalId);
    error FunctionNotFound(bytes4 _functionSelector);

    address immutable DEPLOYER;

    modifier onlyGovernance() {
        _;
    }

    // modifier onlyGovernance() {
    //     require(_msgSender() == _executor(), "Governor: onlyGovernance");
    //     if (_executor() != address(this)) {
    //         bytes32 msgDataHash = keccak256(_msgData());
    //         // loop until popping the expected operation - throw if deque is empty (operation not authorized)
    //         while (_governanceCall.popFront() != msgDataHash) {}
    //     }
    //     _;
    // }

    constructor(string memory _uri, address _init, bytes memory _calldata) {
        DEPLOYER = msg.sender;
        LibGovernance.setURI(_uri);
        LibDiamond.setContractOwner(address(this));
        // set the gorvenance settings from the _calldata
        // add the msg.sender to the deployments
        // LibDiamond.diamondCut(_diamondCut, _args.init, _args.initCalldata);
    }

    /// Public and External Functions

    function uri() external view returns (string memory) {
        return LibGovernance.uri();
    }

    function isMember(address user) external view returns (bool) {
        IDAO_Token token = IDAO_Token(LibGovernance.token());
        return token.balanceOf(user, 0) > 0;
    }

    /// @notice gets the user shares in percent
    /// @dev shares is (token total supply / user balance) * 100
    /// @param user the user to get the shares
    /// @return `uint8` the user shares
    function getShares(address user) external view returns (uint256) {
        IDAO_Token token = IDAO_Token(LibGovernance.token());
        uint256 totalSupply = token.getTotalSupply();
        uint256 owned = token.balanceOf(user, 0);
        if (owned == 0) return 0;
        return (totalSupply / owned) * 100;
    }

    function proposeListing(string memory _descriptionURI, IListing.ListingRequest memory listingRequest) external {
        address listingContract = _getDeployment("Listing");
        bytes memory data = abi.encodeWithSignature("createListing(ListingRequest)", listingRequest);
        IDAO_Governor.Call[] memory call;
        call[0] = IDAO_Governor.Call({targetAddress: listingContract, targetCalldata: data});
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposeListings(string memory _descriptionURI, IListing.ListingRequest[] memory listingRequests)
        external
    {
        address listingContract = _getDeployment("Listing");
        bytes memory data = abi.encodeWithSignature("createListings(ListingRequest[])", listingRequests);
        IDAO_Governor.Call[] memory call;
        call[0] = IDAO_Governor.Call({targetAddress: listingContract, targetCalldata: data});
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposePayment(string memory _descriptionURI, IPayment.PaymentRequest memory paymentRequest) external {
        address paymentContract = _getDeployment("Payment");
        bytes memory data = abi.encodeWithSignature("createPayment(PaymentRequest)", paymentRequest);
        IDAO_Governor.Call[] memory call;
        call[0] = IDAO_Governor.Call({targetAddress: paymentContract, targetCalldata: data});
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposePayments(string memory _descriptionURI, IPayment.PaymentRequest[] memory paymentRequests)
        external
    {
        address paymentContract = _getDeployment("Payment");
        bytes memory data = abi.encodeWithSignature("createPayments(PaymentRequest[])", paymentRequests);
        IDAO_Governor.Call[] memory call;
        call[0] = IDAO_Governor.Call({targetAddress: paymentContract, targetCalldata: data});
        _propose(msg.sender, _descriptionURI, call);
    }

    function propose(string memory _descriptionURI, IDAO_Governor.Call[] memory _calls) external returns (uint256) {
        _propose(msg.sender, _descriptionURI, _calls);
    }

    function getProposal(uint256 proposalId) external view returns (Proposal memory proposal) {
        proposal = LibProposal.getProposal(proposalId);
    }

    function cancelProposal(uint256 proposalId) external {
        Proposal memory proposal = LibProposal.getProposal(proposalId);
        if (proposal.proposer != msg.sender) revert NotTheProposer(msg.sender, proposalId);
        proposal.proposalStatus = ProposalStatus.Cancelled;
    }

    function castVote(uint256 proposalId, Vote vote) external {
        _castVote(msg.sender, proposalId, vote);
    }

    function castVoteBySig() external {}

    function castVoteBySigs() external {}

    function voteReciept(uint256 proposalId) external returns (Vote vote) {
        vote = LibProposal.viewVote(msg.sender, proposalId);
    }

    function execute(uint256 proposalId) external {}

    /// Private and Internal Functions

    function _castVote(address user, uint256 proposalId, Vote vote) private {
        Proposal storage proposal = LibProposal.getProposal(proposalId);
        uint256 voteStartTimestamp = proposal.voteStartTimestamp;
        address token = LibGovernance.token();
        uint256 userVotingRight = IDAO_Token(token).getPastVotes(msg.sender, voteStartTimestamp);
        ProposalStatus status = proposal.proposalStatus;

        if (voteStartTimestamp <= 0) revert InvalidProposal(proposalId);
        if (status != ProposalStatus.Active || status != ProposalStatus.Delay) {
            revert InvalidState();
        }
        if (block.timestamp > voteStartTimestamp) revert VotingNotStarted(proposalId);
        if (userVotingRight <= 0) revert NoVotingRights(msg.sender, proposalId);

        proposal.proposalStatus = ProposalStatus.Active;
        LibProposal.castVote(proposalId, user, vote, userVotingRight);
    }

    function _hashProposal(string memory description, IDAO_Governor.Call[] memory calls)
        private
        pure
        returns (uint256 proposalId)
    {
        proposalId = uint256(keccak256(abi.encode(description, calls)));
    }

    function _propose(address proposer, string memory _descriptionURI, IDAO_Governor.Call[] memory _calls)
        private
        returns (uint256)
    {
        uint256 id = _hashProposal(_descriptionURI, _calls);
        LibGovernance.ensureIsProposer(msg.sender);
        LibGovernance.GovernanceStorage storage govStorage = LibGovernance.governanceStorage();
        LibGovernance.GovernanceSetting memory govSetting = govStorage.governorSetting;

        uint256 votingDelay = govSetting.votingDelay;
        uint256 votingPeriod = govSetting.votingPeriod;
        uint256 executionDelay = govSetting.executionDelay;

        Proposal memory proposal = Proposal({
            proposalId: id,
            forVotes: 0,
            againstVotes: 0,
            proposalCreationTimestamp: block.timestamp,
            voteStartTimestamp: votingDelay + block.timestamp,
            voteEndTimestamp: votingPeriod + votingDelay + block.timestamp,
            executionTimestamp: executionDelay + votingPeriod + votingDelay + block.timestamp,
            proposalStatus: ProposalStatus.Delay,
            proposer: msg.sender,
            descriptionURI: _descriptionURI,
            calls: _calls
        });
        LibProposal.setProposal(id, proposal);
        IEventRegister(DEPLOYER).registerProposal(address(this), proposer, _descriptionURI, _calls, block.timestamp);
    }

    function _getDeployment(string memory deploymentName) private view returns (address deployment) {
        deployment = LibGovernance.getDeployment(deploymentName);
        if (deployment == address(0)) revert ContractNotDeployed(deploymentName);
    }

    /// Governance Functions

    function relay(address target, uint256 value, bytes calldata data) external payable onlyGovernance {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        Address.verifyCallResult(success, returndata, "Governor: relay reverted without message");
    }

    function setURI(string calldata URI) external onlyGovernance {}

    function addFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {}

    function removeFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {}

    function replaceFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {}

    /// @notice fallback function
    /// @dev Find facet for function that is called and execute the
    /// @dev function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.facetAddressAndSelectorPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
