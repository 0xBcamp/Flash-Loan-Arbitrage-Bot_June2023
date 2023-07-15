// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <=0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
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
        Arbitrage.Opportunity memory arbitrage;
        uint256 uniswapPrice = getUniswapPrice(token1, token2);
        uint256 sushiswapPrice = getSushiSwapPrice(token1, token2);

        if (uniswapPrice > 0 && sushiswapPrice > 0) {
            if (uniswapPrice > sushiswapPrice) {
                if (isArbitrageEligable(uniswapPrice, sushiswapPrice)) {
                    arbitrage = Arbitrage.Opportunity(
                        Arbitrage.Transaction(
                            token1,
                            token2,
                            sushiSwapRouterAddr,
                            10
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
                if (isArbitrageEligable(sushiswapPrice, uniswapPrice)) {
                    arbitrage = Arbitrage.Opportunity(
                        Arbitrage.Transaction(
                            token1,
                            token2,
                            uniswapRouterAddr,
                            10
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

        return (false, arbitrage);
    }

    function isArbitrageEligable(
        uint256 higherPrice,
        uint256 lowerPrice
    ) private view returns (bool) {
        uint256 priceDifference = ((higherPrice - lowerPrice) * 10000) /
            lowerPrice; // Calculate the price difference as a percentage
        if (priceDifference >= PRICE_TOLERANCE_PERCENT * 100) {
            return true;
        }
        return false;
    }

    function getUniswapPrice(
        address token1,
        address token2
    ) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        try uniswapRouter.getAmountsOut(1e18, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[amounts.length - 1];
        } catch {
            return 0;
        }
    }

    function getSushiSwapPrice(
        address token1,
        address token2
    ) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        try sushiSwapRouter.getAmountsOut(1e18, path) returns (
            uint256[] memory amounts
        ) {
            return amounts[amounts.length - 1];
        } catch {
            return 0;
        }
    }
}