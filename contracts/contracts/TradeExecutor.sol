// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/ITradeExecutor.sol";
import "./Whitelisted.sol";

contract TradeExecutor is ITradeExecutor, Whitelisted {
    /** Function for trade execution
     * @param dex - address of dex to trade on (0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F for mainnet)
     * @param tokenFrom - address of token to sell (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (WETH) for mainnet)
     * @param tokenTo - address of token to buy (0x6B175474E89094C44Da98b954EedeAC495271d0F (DAI) for mainnet)
     * @param amount - amount of token to sell
     */
    function executeTrade(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) external payable onlyWhitelisted returns (uint256) {
        // Approve the dex to spend the token
        IERC20(tokenFrom).approve(dex, amount);
        address[] memory path;

        // Establish path for swapping
        path = new address[](2);
        path[0] = tokenFrom;
        path[1] = tokenTo;

        // Establish deadline for executing swap
        uint256 deadline = block.timestamp + 120;
        IUniswapV2Router02 routerContract = IUniswapV2Router02(dex);

        require(
            uint256(IERC20(tokenFrom).allowance(address(this), dex)) >= amount,
            "Not enough allowance"
        );
        require(
            IERC20(tokenFrom).balanceOf(address(this)) >= amount,
            "Not enough tokens"
        );

        /* Main swap function */
        uint256[] memory tokenBought = routerContract.swapExactTokensForTokens(
            amount, // amount of tokens to swap
            0, // accept any amount of tokens
            path, // path of token from -> token
            address(this), // recipient -> can be changed to EOA address
            deadline // deadline for swap
        );
        return tokenBought[0];
    }
}
