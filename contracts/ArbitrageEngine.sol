// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IArbitrageEngine.sol";
import "./Whitelisted.sol";

contract ArbitrageEngine is IArbitrageEngine, Whitelisted {
    function updatePrice(address dex, uint256 price) external onlyWhitelisted {}

    function checkArbitrageOpportunity(
        address dex1,
        address dex2
    ) external onlyWhitelisted {}
}
