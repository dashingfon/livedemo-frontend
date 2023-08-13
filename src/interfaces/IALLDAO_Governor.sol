pragma solidity 0.8.19

import "./IDAO_Governor.sol";

interface IALLDAO_Governor is IDAO_Governor {
    event DAO_Created(
        uint256 id,
        address DAO,
        string DAO_Name
    );
    struct Shares {
        address shareholder,
        uint8 shares
    };
    function createDAO(string daoName, Shares[] shares) external;

    function isChildDao(address contract) external view returns (bool);

    function currency() exxternal view returns(address);

    function getFees(address contract) external;


    // functions callable only by a child dao

    function registerProposal();

    function registerProposalResult();

    function registerFunding();

    function registerPayment();

    function registerUpdatedUserURI();

    function registerUpdatedGovernanceURI();

    function registerUpdatedTokenURI();

    function registerGovnanceTransfer();

    function registerAddFunction();

    function registerRemoveFunction();

    function registerReplaceFunction();
}