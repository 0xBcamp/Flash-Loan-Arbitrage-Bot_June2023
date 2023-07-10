// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IArbitrageEngine {
    function checkArbitrageOpportunity(
        address dex1,
        address dex2,
        address token1,
        address token2
    ) external returns (bool);
}
