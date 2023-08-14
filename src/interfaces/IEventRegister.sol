// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IEventRegister {
    function registerPayment(
        address payer,
        address payee,
        address currency,
        uint256 paymentId,
        uint256 amountPerInstallment,
        uint256 numberOfInstallment,
        uint256 paymentInterval
    ) external;

    function registerPaymentClaim(
        uint256 proposalId,
        uint256 claimAmount
    ) external;

    // function registerProposalResult();

    // function registerFunding();

    // function registerProposal();

    // function registerPaymentClaim();

    // function registerUpdatedUserURI();

    // function registerUpdatedGovernanceURI();

    // function registerUpdatedTokenURI();

    // function registerGovnanceTransfer();

    // function registerAddFunction();

    // function registerRemoveFunction();

    // function registerReplaceFunction();

}