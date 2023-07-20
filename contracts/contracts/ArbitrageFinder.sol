// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <=0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IArbitrageFinder.sol";
import "../lib/Arbitrage.sol";
import "./Whitelisted.sol";

contract ArbitrageFinder is IArbitrageFinder, Whitelisted {
    uint PRICE_TOLERANCE_PERCENT = 2;

    IUniswapV2Router02 private immutable uniswapRouter;
    address private immutable uniswapRouterAddr;

    IUniswapV2Router02 private immutable sushiSwapRouter;
    address private immutable sushiSwapRouterAddr;

    constructor(
        address _uniswapRouterAddress,
        address _sushiSwapRouterAddress
    ) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
        uniswapRouterAddr = _uniswapRouterAddress;
        sushiSwapRouter = IUniswapV2Router02(_sushiSwapRouterAddress);
        sushiSwapRouterAddr = _sushiSwapRouterAddress;
    }

    function find(
        address token1,
        address token2
    )
        external
        view
        override
        onlyWhitelisted
        returns (bool, Arbitrage.Opportunity memory)
    {
        uint256 uniswapPrice = getTokenPrice(uniswapRouterAddr, token1, token2);
        uint256 sushiswapPrice = getTokenPrice(
            sushiSwapRouterAddr,
            token1,
            token2
        );

        if (uniswapPrice > 0 && sushiswapPrice > 0) {
            uint256 effectiveTokenBalance = getEffectiveTokenBalance(
                uniswapRouterAddr,
                token1,
                token2
            );

            uint256 tradeAmount = (effectiveTokenBalance * 10) / 100; // 10% of the effective token balance

            if (uniswapPrice > sushiswapPrice) {
                if (
                    isArbitrageEligible(
                        uniswapPrice,
                        sushiswapPrice,
                        tradeAmount
                    )
                ) {
                    Arbitrage.Opportunity memory arbitrage = Arbitrage
                        .Opportunity(
                            Arbitrage.Transaction(
                                token1,
                                token2,
                                sushiSwapRouterAddr,
                                tradeAmount
                            ),
                            Arbitrage.Transaction(
                                token2,
                                token1,
                                uniswapRouterAddr,
                                0
                            )
                        );
                    return (true, arbitrage);
                }
            } else {
                if (
                    isArbitrageEligible(
                        sushiswapPrice,
                        uniswapPrice,
                        tradeAmount
                    )
                ) {
                    Arbitrage.Opportunity memory arbitrage = Arbitrage
                        .Opportunity(
                            Arbitrage.Transaction(
                                token1,
                                token2,
                                uniswapRouterAddr,
                                tradeAmount
                            ),
                            Arbitrage.Transaction(
                                token2,
                                token1,
                                sushiSwapRouterAddr,
                                0
                            )
                        );
                    return (true, arbitrage);
                }
            }
        }

        return (
            false,
            Arbitrage.Opportunity(
                Arbitrage.Transaction(address(0), address(0), address(0), 0),
                Arbitrage.Transaction(address(0), address(0), address(0), 0)
            )
        );
    }

    function getTokenPrice(
        address routerAddress,
        address token1,
        address token2
    ) private view returns (uint256) {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        try router.getAmountsOut(1e18, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[amounts.length - 1];
        } catch {
            return 0;
        }
    }

    function getEffectiveTokenBalance(
        address routerAddress,
        address token1,
        address token2
    ) private view returns (uint256) {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        IERC20 token = IERC20(token1);

        uint256 balance1 = token.balanceOf(address(router));
        uint256 balance2 = token.balanceOf(token2);

        return balance1 < balance2 ? balance1 : balance2;
    }

    function isArbitrageEligible(
        uint256 higherPrice,
        uint256 lowerPrice,
        uint256 tradeAmount
    ) private view returns (bool) {
        uint256 priceDifference = ((higherPrice - lowerPrice) * 10000) /
            lowerPrice; // Calculate the price difference as a percentage
        if (
            priceDifference >= PRICE_TOLERANCE_PERCENT * 100 && tradeAmount > 0
        ) {
            return true;
        }
        return false;
    }
}
