// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.19;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ITradeExecutor.sol";
import "../interfaces/IArbitrageExecutor.sol";
import "./Whitelisted.sol";
import "../lib/Arbitrage.sol";

contract ArbitrageExecutor is
    FlashLoanSimpleReceiverBase,
    Whitelisted,
    IArbitrageExecutor
{
    address payable owner;
    ITradeExecutor private immutable tradeExecutor;

    constructor(
        address _addressProvider,
        address executorAddress
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        tradeExecutor = ITradeExecutor(executorAddress);
    }

    function execute(Arbitrage.Opportunity memory arbitrage) external {
        address receiverAddress = address(this);
        uint16 referralCode = 0;

        bytes memory params = abi.encode(
            arbitrage.firstTransaction,
            arbitrage.secondTransaction
        );

        POOL.flashLoanSimple(
            receiverAddress,
            arbitrage.firstTransaction.tokenFrom,
            arbitrage.firstTransaction.amount,
            params,
            referralCode
        );
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        (
            Arbitrage.Transaction memory firstTransaction,
            Arbitrage.Transaction memory secondTransation
        ) = abi.decode(params, (Arbitrage.Transaction, Arbitrage.Transaction));

        uint256 amountPurchased = tradeExecutor.executeTrade(
            firstTransaction.exchange,
            firstTransaction.tokenFrom,
            firstTransaction.tokenTo,
            firstTransaction.amount
        );

        tradeExecutor.executeTrade(
            secondTransation.exchange,
            secondTransation.tokenFrom,
            secondTransation.tokenTo,
            amountPurchased
        );

        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    receive() external payable {}
}
