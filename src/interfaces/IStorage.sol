// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IStorage {
    event StorageBought(address user, uint256 amount);

    function subscribe(uint256 amount) external;

    function viewSubscription(address user) external view returns (uint256);

    function currency() external;
}
