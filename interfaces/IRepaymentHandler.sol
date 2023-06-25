// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRepaymentHandler {
    function repayLoan(address asset, uint256 amount) external;
}
