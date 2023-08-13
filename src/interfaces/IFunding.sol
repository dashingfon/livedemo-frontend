pragma solidity 0.8.19

interface IFunding {
    event FundingCreated (
        address creator,
        address buyer,
        address token,
        uint256 tokenId,
        uint256 fundingId,
        uint256 amount,
        uint256 price
    );

    event FundingCancelled (
        address canceller,
        address token,
        uint256 tokenId,
        uint256 fundingId
    );

    event FundingSold (
        address token,
        uint256 tokenId,
        uint256 fundingId
    );

    struct Funding {
        address creator,
        address buyer,
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    }

    function createFunding(
        address token, uint256 tokenId, address buyer, uint256 amount, uint256 price) external;

    function cancelFunding(uint256 fundingId) external;

    function buyFunding(uint256 fundingId) external;

    function getFunding(uint256 fundingId) external view returns(Funding);

    function getBatchFunding(uint256[] fundingIds) external view returns(Funding[]);

    /// Governance Controlled

    function remitFees() external;

    function setCurrency(address currency) external;

}