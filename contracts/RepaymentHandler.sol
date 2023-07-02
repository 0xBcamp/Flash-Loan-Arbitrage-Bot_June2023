// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IRepaymentHandler.sol";
import "./Whitelisted.sol";

contract RepaymentHandler is IRepaymentHandler, Whitelisted {
    function repayLoan(
        address asset,
        uint256 amount
    ) external onlyWhitelisted {}
}
