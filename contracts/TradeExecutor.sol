// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ITradeExecutor.sol";
import "./Whitelisted.sol";

contract TradeExecutor is ITradeExecutor, Whitelisted {
    function executeTrade(
        address dex,
        address token,
        uint256 amount
    ) external onlyWhitelisted {}
}
