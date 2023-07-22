// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <=0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IArbitrageFinder.sol";
import "../lib/Arbitrage.sol";
import "./Whitelisted.sol";
import "../interfaces/IVeloRouter.sol";

contract ArbitrageFinder is IArbitrageFinder, Whitelisted {
    uint PRICE_TOLERANCE_PERCENT = 2;
    address VELO_ROUTER = 0x9c12939390052919aF3155f41Bf4160Fd3666A6f;
    address UNISWAP_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

    IQuoter private immutable uniswapRouter;
    address private immutable uniswapRouterAddr;

    IVeloRouter private immutable veloSwapRouter;
    address private immutable veloSwapRouterAddr;

    uint256 latestUniswapPrice;

    constructor(address _uniswapRouterAddress, address _veloSwapRouterAddress) {
        uniswapRouter = IQuoter(_uniswapRouterAddress);
        uniswapRouterAddr = _uniswapRouterAddress;
        veloSwapRouter = IVeloRouter(_veloSwapRouterAddress);
        veloSwapRouterAddr = _veloSwapRouterAddress;
    }

    function find(
        address token1,
        address token2,
        uint256 uniswapPrice,
        uint256 veloswapPrice
    )
        external
        view
        onlyWhitelisted
        returns (bool, Arbitrage.Opportunity memory)
    {
        Arbitrage.Opportunity memory arbitrage;

        if (uniswapPrice > 0 && veloswapPrice > 0) {
            if (uniswapPrice > veloswapPrice) {
                if (isArbitrageEligible(uniswapPrice, veloswapPrice, 10)) {
                    arbitrage = Arbitrage.Opportunity(
                        Arbitrage.Transaction(
                            token1,
                            token2,
                            veloSwapRouterAddr,
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
                if (isArbitrageEligible(veloswapPrice, uniswapPrice, 0)) {
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
                            veloSwapRouterAddr,
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

    function establishUniswapPrice(
        address tokenIn,
        address tokenOut
    ) public returns (uint256) {
        IQuoter uniswapQuoter = IQuoter(UNISWAP_V3_QUOTER);

        uint256 amountOut = uniswapQuoter.quoteExactInputSingle(
            tokenIn,
            tokenOut,
            3000,
            1e18,
            0
        );
        latestUniswapPrice = amountOut;
        return amountOut;
    }

    function getUniswapPrice() public view returns (uint256) {
        return latestUniswapPrice;
    }

    function getVeloSwapPrice(
        address tokenIn,
        address tokenOut
    ) public view returns (uint256) {
        IVeloRouter veloRouter = IVeloRouter(VELO_ROUTER);
        //IVeloRouter.route[] memory routes;
        // routes = new IVeloRouter.route[](1);
        // routes[0].from = tokenIn;
        // routes[0].to = tokenOut;
        // routes[0].stable = false;

        // uint256[] memory amounts = veloRouter.getAmountsOut(1e18, routes);
        (uint reserveA, uint reserveB) = veloRouter.getReserves(
            tokenIn,
            tokenOut,
            false
        );
        uint256 amounts = (reserveB * 10 ** 18) / reserveA;
        return amounts;
    }
}
