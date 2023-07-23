// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IArbitrageFinder.sol";
import "../lib/Arbitrage.sol";
import "./Whitelisted.sol";
import "../interfaces/IVeloRouter.sol";

contract ArbitrageFinder is IArbitrageFinder, Whitelisted {
    uint PRICE_TOLERANCE_PERCENT = 2;

    IQuoter private immutable uniswapQuoter;
    address private immutable uniswapQuoterAddr;
    address private immutable uniswapRouterAddr;

    IVeloRouter private immutable veloRouter;
    address private immutable veloRouterAddr;

    constructor(
        address _uniswapQuoterAddress,
        address _uniswapRouterAddress,
        address _veloRouterAddr
    ) {
        uniswapQuoter = IQuoter(_uniswapQuoterAddress);
        uniswapQuoterAddr = _uniswapQuoterAddress;
        uniswapRouterAddr = _uniswapRouterAddress;
        veloRouter = IVeloRouter(_veloRouterAddr);
        veloRouterAddr = _veloRouterAddr;
    }

    function find(
        address token1,
        address token2
    )
        external
        override
        onlyWhitelisted
        returns (bool, Arbitrage.Opportunity memory)
    {
        uint256 uniswapPrice = getUniswapPrice(token1, token2);
        uint256 voleswapPrice = getVeloSwapPrice(token1, token2);

        if (uniswapPrice > 0 && voleswapPrice > 0) {
            if (uniswapPrice > voleswapPrice) {
                if (isArbitrageEligible(uniswapPrice, voleswapPrice, 10)) {
                    Arbitrage.Opportunity memory arbitrage = Arbitrage
                        .Opportunity(
                            Arbitrage.Transaction(
                                token1,
                                token2,
                                veloRouterAddr,
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
                if (isArbitrageEligible(voleswapPrice, uniswapPrice, 10)) {
                    Arbitrage.Opportunity memory arbitrage = Arbitrage
                        .Opportunity(
                            Arbitrage.Transaction(
                                token1,
                                token2,
                                uniswapRouterAddr,
                                10
                            ),
                            Arbitrage.Transaction(
                                token2,
                                token1,
                                veloRouterAddr,
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

    function getVeloSwapPrice(
        address tokenIn,
        address tokenOut
    ) private view returns (uint256) {
        (uint reserveA, uint reserveB) = veloRouter.getReserves(
            tokenIn,
            tokenOut,
            false
        );
        uint256 amounts = (reserveB * 10 ** 18) / reserveA;
        return amounts;
    }

    function getUniswapPrice(
        address tokenIn,
        address tokenOut
    ) private returns (uint256) {
        uint256 amountOut = uniswapQuoter.quoteExactInputSingle(
            tokenIn,
            tokenOut,
            3000,
            1e18,
            0
        );
        return amountOut;
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
