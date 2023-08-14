// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./interfaces/IPayment.sol";
import "./interfaces/IALLDAO_Governor.sol";

contract Payments is IPayment {

    error Payments__PayerCannotBePayee();
    error Payments__PayeeCannotBeZeroAddress();
    error Payments__PaymentCurrencyCannotBeZeroAddress();
    error Payments__TotalPaymentAmountCannotBeZero();
    error Payments__NotThePayer();

    IALLDAO_Governor public immutable governor;
    uint256 public current_payment_id;
    mapping(uint256 => Payment) public payments;
    mapping(uint256 => address) public currencies;
    mapping(address => mapping(address => uint256)) public balances;

    modifier onlyGovernor() {
        require(msg.sender == (address(governor)), "Only governor can call");
        _;
    }
    constructor () {
        governor = IALLDAO_Governor(msg.sender);
    }

    function createPayment(PaymentRequest memory paymentRequest) external {
         _createPayment(paymentRequests[i]);
    }

    function createPaymentBatch(PaymentRequest[] memory paymentRequests) external {
        for (uint256 i; i < paymentRequests.length; ++i) {
            _createPayment(paymentRequests[i])
        }
    }

    function cancelPayment(uint256 paymentId) external {
        _cancelPayment(paymentId);
    }

    function cancelPaymentBatch(uint256[] memory paymentIds) external {
        for (uint256 i; i < paymentIds.length; ++i) {
            _cancelPayment(paymentIds[i]);
        }
    }

    function claimPayment(uint256 paymentId) external {
        _claimPayment(paymentId);
    }

    function claimPaymentBatch(uint256[] memory paymentIds) external {
        for (uint256 i; i < paymentIds.length; ++i) {
            _claimPayment(paymentIds[i]);
        }
    }

    function withdrawBalance(address[] memory tokens) external {

    }

    function _createPayment(PaymentRequest memory paymentRequest) private {
        uint256 id = current_payment_id;
        uint256 total_payment_amount = paymentRequest.numberOfInstallments * paymentRequest.amountPerInstallment;

        if (msg.sender == paymentRequest.payee) {
            revert Payments__PayerCannotBePayee();
        }
        if (paymentRequest.payee == address(0)) {
            revert Payments__PayeeCannotBeZeroAddress();
        }
        if (paymentRequest.currency == address(0)) {
            revert Payments__PaymentCurrencyCannotBeZeroAddress();
        }
        if (total_payment_amount == 0) {
            revert Payments__TotalPaymentAmountCannotBeZero();
        }

        Payment memory payment = Payment({
            payer: msg.sender,
            payee: paymentRequest.payee,
            paymentId: id,
            amountPerInstallment: paymentRequest.amountPerInstallment,
            numberOfInstallments: paymentRequest.numberOfInstallments,
            secondsBetweenInstallments: paymentRequest.secondsBetweenInstallments,
            nextInstallmentTimestamp: block.timestamp + paymentRequest.secondsDelay
        });

        // todo safeTransfer

        payments[id] = payment;
        currencies[id] = paymentRequest.currency
        current_payment_id += 1;
        
        _registerPayment(payment, paymentRequest.currency);
    }

    function _cancelPayment(uint256 paymentId) private {
        Payment memory payment = payments[paymentId]

        if (payment.payer != msg.sender) {
            revert Payments__NotThePayer();
        }

        // todo; pay the payee the valid payment

        delete payments[paymentId]
        delete currencies[paymentid]

    }

    function _sendPayment(address reciever, address token) private {

    }

    function _registerPayment(Payment payment, address currency) private {
        governor.registerPayment(
            payment.payer,
            payment.payee,
            currency,
            payment.paymentId,
            payment.amountPerInstallment,
            payment.numberOfInstallments,
            payment.secondsBetweenInstallments
        );
    }

    function _registerPaymentClaim() private {

    }

}