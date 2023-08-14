// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

interface IPayment {
    event PaymentCreated (
        address payer,
        address payee,
        uint256 paymentId,
        uint256 amountPerInstallment,
        uint256 numberOfInstallments,
        uint256 secondsBetweenInstallments,
        uint256 start
    );

    event PaymentCancelled (
        address payer,
        address payee,
        uint256 paymentId
    );

    event PaymentClaimed (
        address payer,
        address payee,
        uint256 paymentId,
        uint256 amount
    );

    struct PaymentRequest{
        address payee;
        address currency;
        uint256 amountPerInstallment;
        uint256 numberOfInstallments;
        uint256 secondsBetweenInstallments;
        uint256 secondsDelay;
    }

    struct Payment{
        address payer;
        address payee;
        uint256 paymentId;
        uint256 amountPerInstallment;
        uint256 numberOfInstallments;
        uint256 secondsBetweenInstallments;
        uint256 nextInstallmentTimestamp;
    }

    function createPayment(PaymentRequest memory) external;

    function createPaymentBatch(PaymentRequest[] memory payments) external;

    function cancelPayment(uint256 paymentId) external;

    function cancelPaymentBatch(uint256[] memory paymentIds) external;

    function claimPayment(uint256 paymentId) external;

    function claimPaymentBatch(uint256[] memory paymentIds) external;

    function withdrawBalance() external;

    function getPayment(uint256 paymentId) external view returns(Payment memory);

    function getBatchPayment(uint256[] memory paymentIds) external view returns(Payment[] memory);

    /// Governance Controlled

    function remitFees() external;

    function setCurrency(address currency) external;
}