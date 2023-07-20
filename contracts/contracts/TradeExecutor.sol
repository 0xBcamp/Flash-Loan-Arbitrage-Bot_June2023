// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <=0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ITradeExecutor.sol";
import "./Whitelisted.sol";

contract TradeExecutor is ITradeExecutor, Whitelisted {
    function executeTrade(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) external payable override onlyWhitelisted returns (uint256) {
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
