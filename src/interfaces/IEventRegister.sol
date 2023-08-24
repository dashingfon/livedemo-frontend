// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IEventRegister {
    function registerVoteUpdate(address sender, uint256 senderBalance, address reciever, uint256 recieverBalance)
        external;

    function registerUpdatedGovernanceURI() external;

    function registerProposal() external;

    // function registerAddFunction();

    // function registerRemoveFunction();

    // function registerReplaceFunction();
}
