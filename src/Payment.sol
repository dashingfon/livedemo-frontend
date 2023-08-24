// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IPayment} from "./interfaces/IPayment.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

/// @title Payment Contract
/// @author Mfon Stephen Nwa
/// @notice This contract handles payment between any two parties
contract Payments is IPayment {
    using SafeERC20 for IERC20;

    uint8 public feePercent = 3;
    uint8 public constant DENOMINATOR = 100;
    address immutable owner;
    uint256 public currentPaymentId;

    mapping(uint256 => Payment) public payments;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Public Functions

    /// @inheritdoc	IPayment
    function calculateFee(uint256 amount) public view returns (uint256 feeAmount) {
        feeAmount = (amount * feePercent) / DENOMINATOR;
    }

    /// @inheritdoc	IPayment
    function calculateRemovedFee(uint256 amount) public view returns (uint256 feeRemovedAmount) {
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

    function _createPayment(address creator, PaymentRequest memory paymentRequest) private {
        uint256 id = currentPaymentId;
        uint256 totalPaymentAmount = (paymentRequest.numberOfInstallments * paymentRequest.amountPerInstallment);
        uint256 feeAmount = calculateFee(totalPaymentAmount);

        require(paymentRequest.payee != creator, "payer cannot be payee");
        require(paymentRequest.payee != address(0), "payee cannot be zero address");
        require(paymentRequest.currency != address(0), "currency cannot be zero address");
        require(totalPaymentAmount != 0, "total payment amount cannot be zero");

        Payment memory payment = Payment({
            paymentState: PaymentState.Paying,
            payer: creator,
            paymentId: id,
            payee: paymentRequest.payee,
            currency: paymentRequest.currency,
            amountPerInstallment: calculateRemovedFee(paymentRequest.amountPerInstallment),
            numberOfInstallments: paymentRequest.numberOfInstallments,
            secondsBetweenInstallments: paymentRequest.secondsBetweenInstallments,
            nextInstallmentTimestamp: block.timestamp + paymentRequest.secondsDelay
        });

        IERC20(payment.currency).safeTransferFrom(creator, address(this), totalPaymentAmount);
        IERC20(payment.currency).safeTransfer(owner, feeAmount);

        currentPaymentId = id + 1;
        emit PaymentCreated(payment);
        _claimPayment(payment.payee, payment);
    }

    function _cancelPayment(address canceller, Payment memory payment) private {
        uint256 amountDue;
        uint256 installments = payment.numberOfInstallments;
        uint256 totalAmount = payment.amountPerInstallment * payment.numberOfInstallments;

        require(payment.payer == canceller, "only the payer can cancel a payment");

        for (uint256 i; i < installments; ++i) {
            if (block.timestamp < payment.nextInstallmentTimestamp) break;
            amountDue += payment.amountPerInstallment;
            payment.nextInstallmentTimestamp += payment.secondsBetweenInstallments;
            payment.numberOfInstallments -= 1;
        }

        payment.paymentState = PaymentState.Cancelled;
        payments[payment.paymentId] = payment;

        if (amountDue > 0) {
            IERC20(payment.currency).safeTransfer(payment.payee, amountDue);
        }
        IERC20(payment.currency).safeTransfer(payment.payer, totalAmount - amountDue);
        emit PaymentCancelled(payment.paymentId, totalAmount);
    }

    function _claimPayment(address claimer, Payment memory payment) private {
        uint256 amountDue;
        uint256 installments = payment.numberOfInstallments;

        require(payment.payee == claimer, "only payee can claim payment");

        for (uint256 i; i < installments; ++i) {
            if (block.timestamp < payment.nextInstallmentTimestamp) break;
            amountDue += payment.amountPerInstallment;
            payment.nextInstallmentTimestamp += payment.secondsBetweenInstallments;
            payment.numberOfInstallments -= 1;
        }

        if (payment.numberOfInstallments == 0) {
            payment.paymentState = PaymentState.Paid;
        }
        payments[payment.paymentId] = payment;

        if (amountDue > 0) {
            IERC20(payment.currency).safeTransfer(payment.payee, amountDue);
        }
        emit PaymentClaimed(payment.paymentId, amountDue);
    }

    function _validateState(PaymentState paymentState, Payment memory payment) private pure {
        require(payment.paymentState == paymentState, "Invalid payment state");
    }

    // View Functions

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

    // Owner Function

    function setFee(uint8 _feePercent) external onlyOwner {
        feePercent = _feePercent;
    }
}
