// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRepaymentHandler {
    function repayLoan(address asset, uint256 amount) external;
}
