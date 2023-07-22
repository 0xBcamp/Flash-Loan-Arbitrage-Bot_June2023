// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/Arbitrage.sol";

interface IArbitrageFinder {
    function find(
        address token1,
        address token2
    ) external returns (bool, Arbitrage.Opportunity memory);
}
