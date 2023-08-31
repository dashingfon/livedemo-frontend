// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "openzeppelin/utils/Address.sol";
import {IListing} from "./interfaces/IListing.sol";
import {IPayment} from "./interfaces/IPayment.sol";
import {LibDiamond} from "./libraries/LibDiamond.sol";
import {LibGovernance} from "./libraries/LibGovernance.sol";
import {LibProposal} from "./libraries/LibProposal.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "./interfaces/IDiamondLoupe.sol";
import {IDAO_Governor} from "./interfaces/IDAO_Governor.sol";
import {IDAO_Token} from "./interfaces/IDAO_Token.sol";
import {ERC1155Holder} from "openzeppelin/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "openzeppelin/token/ERC721/utils/ERC721Holder.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
abstract contract DAO_Governor is IDAO_Governor, ERC1155Holder, ERC721Holder{
    error FunctionNotFound(bytes4 _functionSelector);
    error ProposalIdExists(uint256);
    error ContractNotDeployed(string);
    error NotAnExecutor(address);

    modifier onlyGovernance() {}

    modifier isMember(address user) {}

    constructor(string memory uri, address _init, bytes _calldata) {
        LibGovernance.setURI(uri);
        LibDiamond.setContractOwner(address(this));
        // set the gorvenance settings
        // LibDiamond.diamondCut(_diamondCut, _args.init, _args.initCalldata);
    }

    function uri() external view returns (string memory) {
        return LibGovernance.uri();
    }

    function isMember(address user) external view returns (bool) {
        IDAO_Token token = IDAO_Token(LibGovernance.token);
        return token.balanceOf(user, 0) > 0;
    }

    /// @notice gets the user shares in percent
    /// @dev shares is (token total supply / user balance) * 100
    /// @param user the user to get the shares
    /// @return `uint8` the user shares
    function getShares(address user) external view returns (uint8) {
        return LibGovernance.getShares(user);
    }

    function proposeListing(string memory _descriptionURI, ListingRequest memory listingRequest) external {
        address listingContract = LibGovernance.getDeployment("Listing");
        if (listingContract == address(0)) revert ContractNotDeployed("Listing");
        bytes data = abi.encodeWithSignature("createListing(ListingRequest)", listingRequest);
        Call call = Call({targetAddress: listingContract, targetCalldata: data})
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposeListings(string memory _descriptionURI, ListingRequest[] memory listingRequests) external {
        address listingContract = LibGovernance.getDeployment("Listing");
        if (listingContract == address(0)) revert ContractNotDeployed("Listing");
        bytes data = abi.encodeWithSignature("createListings(ListingRequest[])", listingRequests);
        Call call = Call({targetAddress: listingContract, targetCalldata: data})
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposePayment(string memory _descriptionURI, PaymentRequest memory paymentRequest) external {
        address paymentContract = LibGovernance.getDeployment("Payment");
        if (paymentContract == address(0)) revert ContractNotDeployed("Payment");
        bytes data = abi.encodeWithSignature("createPayment(PaymentRequest)", paymentRequest);
        Call call = Call({targetAddress: paymentContract, targetCalldata: data})
        _propose(msg.sender, _descriptionURI, call);
    }

    function proposePayments(string memory _descriptionURI, PaymentRequest[] memory paymentRequests) external {
        address paymentContract = LibGovernance.getDeployment("Payment");
        if (paymentContract == address(0)) revert ContractNotDeployed("Payment");
        bytes data = abi.encodeWithSignature("createPayments(PaymentRequest[])", paymentRequests);
        Call call = Call({targetAddress: paymentContract, targetCalldata: data})
        _propose(msg.sender, _descriptionURI, call);
    }

    function propose(string memory _descriptionURI, Call[] memory _calls) external returns (uint256){
        _propose(msg.sender, _descriptionURI, _calls);
    }

    function _propose(address proposer, string memory _descriptionURI, Call[] memory _calls) external returns (uint256) {
        uint256 id = _hashProposal(_descriptionURI, _calls);
        Proposal proposal = Proposal({
            proposalId: id,
            forVotes: 0,
            againstVotes: 0,
            proposalCreationTimestamp: block.timestamp,
            voteStartTimestamp:
            voteEndTimestamp:
            executionTimestamp:
             proposalStatus: ProposalStatus.Delay,
            proposer: msg.sender,
            descriptionURI: _descriptionURI,
            calls: _calls
        })
    }

    function _hashProposal(string description, Call[] calls) external pure returns (uint256 proposalId) {
        proposalId = uint256(keccak256(abi.encode(description, calls)));
    }

    function getProposal(uint256 proposalId) external view returns (Proposal memory proposal);

    function cancelProposal(uint256 proposalID) external;

    function castVote(uint256 proposalID, Vote vote) external;

    function castVoteBySig() external;

    function castVoteBySigs() external;

    function voteReciept(uint256 proposalId) external returns (Vote vote);

    function execute(uint256 proposalID) external {

    }

    /// The functions below will only be callable after the governance process

    function relay(address target, uint256 value, bytes calldata data) external payable onlyGovernance {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        Address.verifyCallResult(success, returndata, "Governor: relay reverted without message");
    }

    function setURI(string calldata URI) external;

    function addFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {

    }

    function removeFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {

    }

    function replaceFunctions(address facetAddress, bytes4[] memory functionSelectors) external onlyGovernance {

    }

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
