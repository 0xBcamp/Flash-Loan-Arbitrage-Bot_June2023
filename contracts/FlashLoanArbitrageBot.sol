// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IArbitrageEngine.sol";
import "../interfaces/IFlashLoanHandler.sol";
import "../interfaces/ITradeExecutor.sol";
import "../interfaces/IRepaymentHandler.sol";
import "./Whitelisted.sol";

contract FlashLoanArbitrageBot is Whitelisted {
    IArbitrageEngine public arbitrageEngine;
    IFlashLoanHandler public flashLoanHandler;
    ITradeExecutor public tradeExecutor;
    IRepaymentHandler public repaymentHandler;

    constructor(
        address _arbitrageEngine,
        address _flashLoanHandler,
        address _tradeExecutor,
        address _repaymentHandler
    ) {
        arbitrageEngine = IArbitrageEngine(_arbitrageEngine);
        flashLoanHandler = IFlashLoanHandler(_flashLoanHandler);
        tradeExecutor = ITradeExecutor(_tradeExecutor);
        repaymentHandler = IRepaymentHandler(_repaymentHandler);
    }

    function execute(address dex1, address dex2) external onlyWhitelisted {}
}
