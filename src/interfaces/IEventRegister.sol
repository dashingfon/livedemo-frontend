// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IEventRegister {
    function registerPayment(
        address payer,
        address payee,
        address currency,
        uint256 amountPerInstallment,
        uint256 paymentId,
        uint256 numberOfInstallment,
        uint256 paymentInterval
    ) external;

    function registerPaymentClaimed(uint256 proposalId, uint256 amountClaimed) external;

    function registerPaymentCancelled(uint256 paymentId, uint256 amountCancelled) external;

    // function registerListing();

    // function registerListingSold();

    // function registerListingCancelled();

    // function registerProposalResult();

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
