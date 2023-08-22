// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IPayment} from "./interfaces/IPayment.sol";
import {IALLDAO_Governor} from "./interfaces/IALLDAO_Governor.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

/// @title Payment Contract
/// @author Mfon Stephen Nwa
/// @notice This is the contract that handles payment between any two parties
contract Payments is IPayment {
    using SafeERC20 for IERC20;

    error Payments__PayerCannotBePayee();
    error Payments__PayeeCannotBeZeroAddress();
    error Payments__PaymentCurrencyCannotBeZeroAddress();
    error Payments__TotalPaymentAmountCannotBeZero();
    error Payments__InvalidState(PaymentState, uint256);
    error Payments__NotThePayer();
    error Payments__NotThePayee();

    IALLDAO_Governor public immutable governor;
    uint256 public currentPaymentId;
    uint8 public feePercent = 3;
    uint8 public constant DENOMINATOR = 100;

    mapping(uint256 => Payment) public payments;

    modifier onlyGovernor() {
        require(msg.sender == (address(governor)), "Only governor can call");
        _;
    }

    constructor() {
        governor = IALLDAO_Governor(msg.sender);
    }

    // Public Functions

    /// @inheritdoc	IPayment
    function calculateFee(uint256 amount) public pure returns (uint256 feeAmount) {
        feeAmount = (amount * feePercent) / DENOMINATOR;
    }

    /// @inheritdoc	IPayment
    function calculateRemovedFee(uint256 amount) public pure returns (uint256 feeRemovedAmount) {
        feeRemovedAmount = amount - ((amount * feePercent) / DENOMINATOR);
    }

    // External Functions

    /// @inheritdoc	IPayment
    function createPayment(PaymentRequest memory paymentRequest) external {
        _createPayment(msg.sender, paymentRequest);
    }

    /// @inheritdoc	IPayment
    function createPayments(PaymentRequest[] memory paymentRequests) external {
        for (uint256 i; i < paymentRequests.length; ++i) {
            _createPayment(msg.sender, paymentRequests[i]);
        }
    }

    /// @inheritdoc	IPayment
    function cancelPayment(uint256 paymentId) external {
        Payment memory payment = payments[paymentId];
        _validateState(PaymentState.Paying, payment);
        _cancelPayment(msg.sender, payment);
    }

    /// @inheritdoc IPayment
    function cancelPayments(uint256[] memory paymentIds) external {
        Payment memory payment;
        for (uint256 i; i < paymentIds.length; ++i) {
            payment = payments[paymentIds[i]];
            _validateState(PaymentState.Paying, payment);
            _cancelPayment(msg.sender, payment);
        }
    }

    /// @inheritdoc	IPayment
    function claimPayment(uint256 paymentId) external {
        Payment memory payment = payments[paymentId];
        _validateState(PaymentState.Paying, payment);
        _claimPayment(msg.sender, payment);
    }

    /// @inheritdoc	IPayment
    function claimPayments(uint256[] memory paymentIds) external {
        Payment memory payment;
        for (uint256 i; i < paymentIds.length; ++i) {
            payment = payments[paymentIds[i]];
            _validateState(PaymentState.Paying, payment);
            _claimPayment(msg.sender, payment);
        }
    }

    // Private Functions

    function _createPayment(address sender, PaymentRequest memory paymentRequest) private {
        uint256 id = currentPaymentId;
        uint256 totalPaymentAmount = (paymentRequest.numberOfInstallments * paymentRequest.amountPerInstallment);
        uint256 feeAmount = calculateFee(totalPaymentAmount);

        if (paymentRequest.payee == sender) {
            revert Payments__PayerCannotBePayee();
        }
        if (paymentRequest.payee == address(0)) {
            revert Payments__PayeeCannotBeZeroAddress();
        }
        if (paymentRequest.currency == address(0)) {
            revert Payments__PaymentCurrencyCannotBeZeroAddress();
        }
        if (totalPaymentAmount == 0) {
            revert Payments__TotalPaymentAmountCannotBeZero();
        }

        Payment memory payment = Payment({
            paymentState: PaymentState.Paying,
            payer: sender,
            paymentId: id,
            payee: paymentRequest.payee,
            currency: paymentRequest.currency,
            amountPerInstallment: calculateRemovedFee(paymentRequest.amountPerInstallment),
            numberOfInstallments: paymentRequest.numberOfInstallments,
            secondsBetweenInstallments: paymentRequest.secondsBetweenInstallments,
            nextInstallmentTimestamp: block.timestamp + paymentRequest.secondsDelay
        });

        IERC20(payment.currency).safeTransferFrom(sender, address(this), totalPaymentAmount);
        IERC20(payment.currency).safeTransfer(address(governor), feeAmount);

        currentPaymentId += 1;
        _claimPayment(payment.payee, payment);
        _registerPayment(payment);
    }

    function _cancelPayment(address canceller, Payment memory payment) private {
        uint256 amountDue;
        uint256 installments = payment.numberOfInstallments;
        uint256 totalAmount = payment.amountPerInstallment * payment.numberOfInstallments;

        if (payment.payer != canceller) {
            revert Payments__NotThePayer();
        }

        for (uint256 i; i < installments; ++i) {
            if (block.timestamp < payment.nextInstallmentTimestamp) break;
            amountDue += payment.amountPerInstallment;
            payment.nextInstallmentTimestamp += payment.secondsBetweenInstallments;
            payment.numberOfInstallments -= 1;
        }
        IERC20 token = IERC20(payment.currency);
        if (amountDue > 0) {
            token.safeTransfer(payment.payee, amountDue);
        }
        token.safeTransfer(payment.payer, totalAmount - amountDue);
        payment.paymentState = PaymentState.Cancelled;
        payments[payment.paymentId] = payment;
        _registerPaymentCancelled(payment.paymentId, totalAmount);
    }

    function _claimPayment(address claimer, Payment memory payment) private {
        uint256 amountDue;
        uint256 installments = payment.numberOfInstallments;

        if (payment.payee != claimer) {
            revert Payments__NotThePayee();
        }

        for (uint256 i; i < installments; ++i) {
            if (block.timestamp < payment.nextInstallmentTimestamp) break;
            amountDue += payment.amountPerInstallment;
            payment.nextInstallmentTimestamp += payment.secondsBetweenInstallments;
            payment.numberOfInstallments -= 1;
        }
        if (amountDue > 0) {
            IERC20(payment.currency).safeTransfer(payment.payee, amountDue);
        }
        if (payment.numberOfInstallments == 0) {
            payment.paymentState = PaymentState.Paid;
        }
        payments[payment.paymentId] = payment;
        _registerPaymentClaimed(payment.paymentId, amountDue);
    }

    function _registerPayment(Payment memory payment) private {
        governor.registerPayment(
            payment.payer,
            payment.payee,
            payment.currency,
            payment.amountPerInstallment,
            payment.paymentId,
            payment.numberOfInstallments,
            payment.secondsBetweenInstallments
        );
    }

    function _registerPaymentCancelled(uint256 paymentId, uint256 amountCancelled) private {
        governor.registerPaymentCancelled(paymentId, amountCancelled);
    }

    function _registerPaymentClaimed(uint256 paymentId, uint256 amountClaimed) private {
        governor.registerPaymentClaimed(paymentId, amountClaimed);
    }

    function _validateState(PaymentState paymentState, Payment memory payment) private {
        if (payment.paymentState != paymentState) revert Payments__InvalidState(paymentState, payment.paymentId);
    }

    //// View Functions

    function getPayment(uint256 paymentId) external view returns (Payment memory) {
        return payments[paymentId];
    }

    function getPayments(uint256[] memory paymentIds) external view returns (Payment[] memory) {
        Payment[] memory _payments = new Payment[](paymentIds.length);
        for (uint256 i; i < paymentIds.length; ++i) {
            _payments[i] = payments[paymentIds[i]];
        }
        return _payments;
    }

    //// Governor Function

    function setFee(uint8 _feePercent) external onlyGovernor {
        feePercent = _feePercent;
    }
}
