// SPDX-Licence-Identifier: Unlicenced

pragma solidity 0.8.19;

import "./interfaces/IPayment.sol";
import "./interfaces/IALLDAO_Governor.sol";

contract Payments is IPayment {
    error Payments__PayerCannotBePayee();
    error Payments__PayeeCannotBeZeroAddress();
    error Payments__TotalPaymentAmountCannotBeZero();

    IALLDAO_Governor governor;
    uint256 current_payment_id;
    mapping(uint256 => Payment) payments;

    modifier onlyGovernor() {
        require(msg.sender == (address(governor)), "Only governor can call");
        _;
    }
    constructor () {
        governor = IALLDAO_Governor(msg.sender);
    }

    function createPayment(PaymentRequest memory paymentRequest) external {
        uint256 id = current_payment_id;
        uint256 total_payment_amount = paymentRequest.numberOfInstallments * paymentRequest.amountPerInstallment;

        if (msg.sender == paymentRequest.payee) {
            revert Payments__PayerCannotBePayee();
        }
        if (paymentRequest.payee == address(0)) {
            revert Payments__PayeeCannotBeZeroAddress();
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
            intervalBetweenInstallments: paymentRequest.intervalBetweenInstallments,
            nextInstallment: block.timestamp + paymentRequest.delay
        });
        payments[id] = payment;
        governor.registerPayment(payment);
        current_payment_id += 1;
    }

}