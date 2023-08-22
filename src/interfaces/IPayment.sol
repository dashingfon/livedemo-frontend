// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title The Payment interface
/// @author Mfon Stephen Nwa
/// @notice This interface containg the functions the Payment contract implements
interface IPayment {

    /// @notice The event that is trigered when a payment is created
    /// @param payer the person making the payment
    /// @param payee the person being paid
    /// @param currency the address of the token the payment is made in
    /// @param paymentId the id of the payment
    /// @param amountPerInstallment the amount to be paid per installment
    /// @param numberOfInstallments the number of installments the payment will be completed in
    /// @param secondsBetweenInstallments the number of seconds between each installment
    /// @param firstInstallmentTimestamp the timestamp when the first installment will be paid in
    event PaymentCreated(
        address payer,
        address payee,
        address currency,
        uint256 paymentId,
        uint256 amountPerInstallment,
        uint256 numberOfInstallments,
        uint256 secondsBetweenInstallments,
        uint256 firstInstallmentTimestamp
    );

    /// @notice The event that is trigered when a payment is cancelled
    /// @param payer the person making the payment
    /// @param payee the person being paid
    /// @param paymentId the id of the payment
    /// @param amountReturned the amount returned to the payer
    event PaymentCancelled(address payer, address payee, uint256 paymentId, uint256 amountReturned);

    enum PaymentState {
        None,
        Paying,
        Cancelled,
        Paid
    }

    struct PaymentRequest {
        address payee;
        address currency;
        uint256 amountPerInstallment;
        uint256 numberOfInstallments;
        uint256 secondsBetweenInstallments;
        uint256 secondsDelay;
    }

    struct Payment {
        PaymentState paymentState;
        address payer;
        address payee;
        address currency;
        uint256 paymentId;
        uint256 amountPerInstallment;
        uint256 numberOfInstallments;
        uint256 secondsBetweenInstallments;
        uint256 nextInstallmentTimestamp;
    }

    /// @notice function to create a payment
    /// @param paymentRequest the PaymentRequest struct
    function createPayment(PaymentRequest memory paymentRequest) external;

    /// @notice function to create multiple payments
    /// @param paymentRequests an array of PaymentRequest structs
    function createPayments(PaymentRequest[] memory paymentRequests) external;

    /// @notice function to cancel a payment
    /// @param paymentId the id of the payment to cancel
    function cancelPayment(uint256 paymentId) external;

    /// @notice function to cancel multiple payments
    /// @param paymentIds the ids of the payments to cancel
    function cancelPayments(uint256[] memory paymentIds) external;

    /// @notice function to claim a payment and transfer the amount due
    /// @param paymentId id of the payment to claim
    function claimPayment(uint256 paymentId) external;

    /// @notice function to claim multiple payments
    /// @param paymentIds a parameter just like in doxygen (must be followed by parameter name)
    function claimPayments(uint256[] memory paymentIds) external;

    /// @notice function to calculate the fee deducted from a payment
    /// @param amount the amount to calculate the fee
    /// @return feeAmount the fee
    function calculateFee(uint256 amount) external pure returns (uint256 feeAmount);

    /// @notice function to calculate the remaining amount after deducting the fee
    /// @param amount the amount to calculate from
    /// @return feeRemovedAmount the remaining amount after deducting the fee
    function calculateRemovedFee(uint256 amount) external pure returns (uint256 feeRemovedAmount);

    /// @notice function to get the payment from an Id
    /// @param paymentId the id of the payment
    /// @return Payment the payment belonging to that Id
    function getPayment(uint256 paymentId) external view returns (Payment memory);

    /// @notice function to get the payments belonging to the ids
    /// @param paymentIds an array of payment Ids
    /// @return _payments an array of Payments
    function getPayments(uint256[] memory paymentIds) external view returns (Payment[] memory _payments);

    /// @notice function to set the fee the Payment contract charges
    /// @dev This function can only be called by the ALLDAO Governor
    /// @param _feePercent the new feePercent to set
    function setFee(uint8 _feePercent) external;
}
