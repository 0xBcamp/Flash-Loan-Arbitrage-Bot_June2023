// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFlashLoanHandler {
    function initiateFlashLoan(address asset, uint256 amount) external;
}
