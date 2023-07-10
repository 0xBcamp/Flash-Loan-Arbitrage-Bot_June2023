// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IArbitrageEngine.sol";
import "../interfaces/uniswap/IFactory.sol";
import "../interfaces/uniswap/IUniswapV2Router02.sol";
import "./Whitelisted.sol";

contract ArbitrageEngine is IArbitrageEngine, Whitelisted {
    uint TOLERANCE = 2; // 2%

    event ArbitrageOpportunity(
        address indexed dexToBuy,
        address indexed tokenToBuy,
        address indexed dexToSell
    );

    /**
     * This function can be periodicaly called using chainlink keepers
     * @param dex1 - address of sushiswap (0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F for mainnet)
     * @param dex2 - address of uniswap (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D for mainnet)
     * @param token1 - address of token1 (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (WETH) for mainnet)
     * @param token2 - address of token2 (0x6B175474E89094C44Da98b954EedeAC495271d0F (DAI) for mainnet)
     */
    function checkArbitrageOpportunity(
        address dex1,
        address dex2,
        address token1,
        address token2
    ) external onlyWhitelisted returns (bool) {
        uint256 priceTolerance = 0;
        //Check if pair exists on both dexes and get pair addresses
        IFactory factory1 = IFactory(IUniswapV2Router02(dex1).factory());
        IFactory factory2 = IFactory(IUniswapV2Router02(dex2).factory());
        address pairDex1 = factory1.getPair(token1, token2);
        address pairDex2 = factory2.getPair(token1, token2);
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;
        require(pairDex1 != address(0) && pairDex2 != address(0), "No pair");
        // From pair can be retrieved also reserves - how deep is the liquidity

        //Get price from both dexes
        uint256 priceDex1 = IUniswapV2Router02(dex1).getAmountsOut(1, path)[1];
        uint256 priceDex2 = IUniswapV2Router02(dex2).getAmountsOut(1, path)[1];

        //Establish price tolerance average
        priceTolerance =
            (((priceDex1 * TOLERANCE) / 100) +
                ((priceDex2 * TOLERANCE) / 100)) /
            2;
        if (priceDex1 > priceDex2) {
            // Apply histereis
            if ((priceDex1 - priceDex2) < priceTolerance) return false;
            // buy token1 on dex1, sell token1 on dex2 (buy token2 on dex2)
            emit ArbitrageOpportunity(dex1, token1, dex2);
            return true;
        } else {
            // Apply histereis
            if ((priceDex2 - priceDex1) < priceTolerance) return false;
            // buy token1 on dex2, sell token1 on dex1 (buy token2 on dex1)
            emit ArbitrageOpportunity(dex2, token1, dex1);
            return true;
        }
    }
}
