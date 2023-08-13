// SPDX-Licence-Identifier: Unlicenced

pragma solidity 0.8.19;

interface IProfile {
    event ProfileUpdated (
        address user,
        address DAO,
        string oldProfileURI,
        string newProfileURI
    );

    event DAO_Added (
        address DAO,
        string name
    );

    /// can only be called by a DAO under ALLDAO
    function updateProfile(address user, string memory URI) external;

    function getProfile(address user) external view returns (string memory);

    /// can only be called by ALLDAO
    function addDAO(address DAO, string memory name) external;

    function getDAO(string memory DAO_name) external view returns(address);

}