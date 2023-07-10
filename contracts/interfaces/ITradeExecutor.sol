// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITradeExecutor {
    function executeTrade(address dex, address token, uint256 amount) external;
}
