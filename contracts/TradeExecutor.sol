// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ITradeExecutor.sol";

contract TradeExecutor is ITradeExecutor {
    function executeTrade(
        address dex,
        address token,
        uint256 amount
    ) external {}
}
