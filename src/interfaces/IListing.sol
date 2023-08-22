// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IListing {
    event ListingCreated(
        address creator, address buyer, address token, uint256 tokenId, uint256 listingId, uint256 amount, uint256 price
    );

    event ListingCancelled(address canceller, address token, uint256 tokenId, uint256 listingId);

    event ListingSold(address token, uint256 tokenId, uint256 listingId);

    enum ListingState {
        Unlisted,
        Listed,
        Sold
    }

    struct Listing {
        address creator;
        address buyer;
        address token;
        address paymentToken;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
    }

    function createListing(address token, uint256 tokenId, address buyer, uint256 amount, uint256 price) external;

    function cancelListing(uint256 listingId) external;

    function buyListing(uint256 listingId) external;

    function getListing(uint256 listingId) external view returns (Listing memory);

    function getBatchListing(uint256[] memory listingIds) external view returns (Listing[] memory);
}
