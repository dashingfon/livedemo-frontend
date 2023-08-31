// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./IDAO_Governor.sol";
import "./IEventRegister.sol";

interface IALLDAO_Governor is IDAO_Governor {
    event DAO_Created(uint256 id, address DAO, string DAO_Name);

    struct Shares {
        address shareholder;
        uint8 shares;
    }

    function createDAO(string memory daoName, Shares[] memory shares) external;

    function isChildDao(address) external view returns (bool);
}
