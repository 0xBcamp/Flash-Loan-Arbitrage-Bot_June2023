// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IArbitrageEngine.sol";

contract ArbitrageEngine is IArbitrageEngine {
    function updatePrice(address dex, uint256 price) external {}

    function checkArbitrageOpportunity(address dex1, address dex2) external {}
}
