// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IFlashLoanHandler.sol";
import "./Whitelisted.sol";

contract FlashLoanHandler is IFlashLoanHandler, Whitelisted {
    function initiateFlashLoan(
        address asset,
        uint256 amount
    ) external onlyWhitelisted {}
}
