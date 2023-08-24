// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IListing} from "./interfaces/IListing.sol";
import {IERC1155} from "openzeppelin/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "openzeppelin/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract Listing is IListing, ERC1155Holder {
    using SafeERC20 for IERC20;

    uint8 public constant DENOMINATOR = 100;
    address public immutable owner;
    uint256 public currentListingId;
    uint8 public feePercent = 3;

    mapping(uint256 => Listing) public listings;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Public Functions

    /// @inheritdoc	IListing
    function calculateFee(uint256 amount) public view returns (uint256 feeAmount) {
        feeAmount = (amount * feePercent) / DENOMINATOR;
    }

    /// @inheritdoc	IListing
    function calculateRemovedFee(uint256 amount) public view returns (uint256 feeRemovedAmount) {
        feeRemovedAmount = amount - ((amount * feePercent) / DENOMINATOR);
    }

    // External Functions

    /// @inheritdoc IListing
    function createListing(ListingRequest memory listingRequest) external {
        _createListing(msg.sender, listingRequest);
    }

    /// @inheritdoc IListing
    function createListings(ListingRequest[] memory listingRequests) external {
        for (uint256 i; i < listingRequests.length; ++i) {
            _createListing(msg.sender, listingRequests[i]);
        }
    }

    /// @inheritdoc IListing
    function cancelListing(uint256 listingId) external {
        Listing memory listing = listings[listingId];
        _validateState(ListingState.Listed, listing);
        _cancelListing(msg.sender, listing);
    }

    /// @inheritdoc IListing
    function cancelListings(uint256[] memory listingIds) external {
        Listing memory listing;
        for (uint256 i; i < listingIds.length; ++i) {
            listing = listings[listingIds[i]];
            _validateState(ListingState.Listed, listing);
            _cancelListing(msg.sender, listing);
        }
    }

    /// @inheritdoc IListing
    function buyListing(uint256 listingId) external {
        Listing memory listing = listings[listingId];
        _validateState(ListingState.Listed, listing);
        _buyListing(msg.sender, listing);
    }

    /// @inheritdoc IListing
    function buyListings(uint256[] memory listingIds) external {
        Listing memory listing;
        for (uint256 i; i < listingIds.length; ++i) {
            listing = listings[listingIds[i]];
            _validateState(ListingState.Listed, listing);
            _buyListing(msg.sender, listing);
        }
    }

    // Private Functions

    function _createListing(address creator, ListingRequest memory listingRequest) private {
        uint256 id = currentListingId;

        require(listingRequest.buyer != creator, "creator cannot be the buyer");
        require(listingRequest.token != address(0), "token address to be listed cannot be the zero address");
        require(listingRequest.paymentToken != address(0), "payment token address cannot be the zero address");
        require(listingRequest.numberOfTokens > 0, "number of tokens to list must be greater than zero");
        require(listingRequest.price > 0, "price of token must be greater than zero");

        Listing memory listing = Listing({
            state: ListingState.Listed,
            listingId: id,
            creator: creator,
            buyer: listingRequest.buyer,
            token: listingRequest.token,
            tokenId: listingRequest.tokenId,
            paymentToken: listingRequest.paymentToken,
            numberOfTokens: listingRequest.numberOfTokens,
            price: listingRequest.price
        });

        listings[id] = listing;
        currentListingId = id + 1;
        IERC1155(listing.token).safeTransferFrom(creator, address(this), listing.tokenId, listing.numberOfTokens, "");
        emit ListingCreated(listing);
    }

    function _cancelListing(address canceller, Listing memory listing) private {
        require(listing.creator == canceller, "only creator can cancel listing");

        listing.state = ListingState.Cancelled;
        listings[listing.listingId] = listing;
        IERC1155(listing.token).safeTransferFrom(address(this), canceller, listing.tokenId, listing.numberOfTokens, "");
        emit ListingCancelled(listing.listingId);
    }

    function _buyListing(address buyer, Listing memory listing) private {
        require(listing.buyer == address(0) || listing.buyer == buyer, "buyer is not allowed to buy");

        listing.state = ListingState.Sold;
        listings[listing.listingId] = listing;
        IERC20(listing.paymentToken).safeTransferFrom(buyer, address(this), listing.price);
        IERC20(listing.paymentToken).safeTransfer(owner, calculateFee(listing.price));
        IERC20(listing.paymentToken).safeTransfer(listing.creator, calculateRemovedFee(listing.price));
        IERC1155(listing.token).safeTransferFrom(address(this), buyer, listing.tokenId, listing.numberOfTokens, "");
        emit ListingSold(listing.listingId);
    }

    function _validateState(ListingState listingState, Listing memory listing) private pure {
        require(listing.state == listingState, "Invalid state");
    }

    // View Functions

    function getListing(uint256 listingId) external view returns (Listing memory) {
        return listings[listingId];
    }

    function getListings(uint256[] memory listingIds) external view returns (Listing[] memory) {
        Listing[] memory _listings = new Listing[](listingIds.length);
        for (uint256 i; i < listingIds.length; ++i) {
            _listings[i] = listings[listingIds[i]];
        }
        return _listings;
    }

    //// Governor Function

    function setFee(uint8 _feePercent) external onlyOwner {
        feePercent = _feePercent;
    }
}
