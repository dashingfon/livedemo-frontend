pragma solidity 0.8.19

interface IPayment {
    event PaymentCreated (
        address payer,
        address payee,
        uint256 paymentId
        uint256 amountPerInstallment,
        uint256 numberOfInstallments,
        uint256 intervalBetweenInstallments
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
        uint256 paymentId
        uint256 amount
    );

    struct PaymentRequest{
        address payee,
        uint256 amountPerInstallment,
        uint256 numberOfInstallments,
        uint256 intervalBetweenInstallments,
        uint256 delay
    };

    struct Payment{
        address payer,
        address payee,
        uint256 paymentId
        uint256 amountPerInstallment,
        uint256 numberOfInstallments,
        uint256 intervalBetweenInstallments
        uint256 nextInstallment
    };

    function createPayment(PaymentRequest) external;

    function createPaymentBatch(PaymentRequest[] payments) external;

    function cancelPayment(uint256 paymentId) external;

    function cancelPaymentBatch(uint256[] paymentIds) external;

    function claimPayment(uint256 paymentId) external;

    function claimPaymentBatch(uint256[] paymentIds) external;

    function withdrawBalance() external;

    function getPayment(uint256 paymentId) external view returns(Payment);

    function getBatchPayment(uint256[] paymentIds) external view returns(Payment[]);

    /// Governance Controlled

    function remitFees() external;

    function setCurrency(address currency) external;
}