// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITradeExecutor {
    function executeTrade(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) external payable returns (uint256);
}
