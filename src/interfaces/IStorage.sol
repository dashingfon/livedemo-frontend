// SPDX-Licence-Identifier: Unlicenced

pragma solidity 0.8.19;

interface IStorage {
    event StorageBought(
        address user,
        uint256 amount
    );

    function buyStorage(uint256 amount) external;

    function getStorage(address user) external view returns(uint256);

    /// Governance Controlled

    function remitFees() external;

    function setCurrency(address currency) external;
}