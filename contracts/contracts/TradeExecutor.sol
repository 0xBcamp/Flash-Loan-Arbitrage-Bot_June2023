// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ITradeExecutor.sol";
import "../interfaces/IVeloRouter.sol";
import "./Whitelisted.sol";

contract TradeExecutor is ITradeExecutor, Whitelisted {
    ISwapRouter private immutable uniswapRouter;
    address private immutable uniswapRouterAddr;

    IVeloRouter private immutable veloRouter;
    address private immutable veloRouterAddr;

    constructor(address _uniswapRouterAddress, address _veloRouterAddr) {
        uniswapRouter = ISwapRouter(_uniswapRouterAddress);
        uniswapRouterAddr = _uniswapRouterAddress;
        veloRouter = IVeloRouter(_veloRouterAddr);
        veloRouterAddr = _veloRouterAddr;
    }

    function executeTrade(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) external payable override onlyWhitelisted returns (uint256) {
        require(
            uniswapRouterAddr == dex || veloRouterAddr == dex,
            "Invalid dex"
        );

        if (dex == uniswapRouterAddr) {
            return swapExactInputSingleV3(amount, tokenFrom, tokenTo);
        } else if (dex == veloRouterAddr) {
            return swapTokensVelo(tokenFrom, tokenTo, amount, 0);
        }
        return 0;
    }

    // UniswapV3
    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn`
    /// worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingleV3(
        uint256 amountIn,
        address tokenFrom,
        address tokenTo
    ) private returns (uint256 amountOut) {
        // msg.sender must approve this contract
        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            tokenFrom,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(tokenFrom, address(uniswapRouter), amountIn);

        // Naively set amountOutMinimum to 0.
        // In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenFrom,
                tokenOut: tokenTo,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = uniswapRouter.exactInputSingle(params);
    }

    function swapTokensVelo(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) public returns (uint256 amountOut) {
        require(
            uint256(IERC20(tokenIn).allowance(msg.sender, address(this))) >=
                amountIn,
            "Not enough allowance"
        );
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(veloRouterAddr, amountIn);

        IVeloRouter.route[] memory routes;
        routes = new IVeloRouter.route[](1);
        routes[0].from = tokenIn;
        routes[0].to = tokenOut;
        routes[0].stable = false;

        uint256[] memory amounts = veloRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            routes,
            address(this),
            block.timestamp
        );
        IERC20(tokenOut).transfer(msg.sender, amounts[1]);
        return amounts[1];
    }
}
