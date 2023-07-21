// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <=0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ITradeExecutor.sol";
import "./Whitelisted.sol";
import "../interfaces/IWeth.sol";
import "../interfaces/IVeloRouter.sol";

contract TradeExecutor is ITradeExecutor, Whitelisted {
    address VELO_ROUTER = 0x9c12939390052919aF3155f41Bf4160Fd3666A6f;
    address UNISWAP_V3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    /** Function to get WETH from ETH
     * @param wethAddress - address of WETH contract (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 for mainnet)
     */
    function getWethFromEth(
        address wethAddress
    ) external payable returns (uint256) {
        IWeth wEth = IWeth(wethAddress);
        wEth.deposit{value: msg.value}();
        wEth.transferFrom(
            address(this),
            msg.sender,
            wEth.balanceOf(address(this))
        );
        return wEth.balanceOf(msg.sender);
    }

    /** Function for trade execution
     */
    function executeTrade(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) external payable override onlyWhitelisted returns (uint256) {
        require(UNISWAP_V3 == dex || VELO_ROUTER == dex, "Invalid dex");

        if (dex == UNISWAP_V3) {
            return swapExactInputSingleV3(amount, tokenFrom, tokenTo);
        } else if (dex == VELO_ROUTER) {
            return swapTokensVelo(tokenFrom, tokenTo, amount, 0);
        } else {
            /* Not possible for now */
            return swapTokensV2(dex, tokenFrom, tokenTo, amount);
        }
    }

    // UniswapV3
    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingleV3(
        uint256 amountIn,
        address tokenFrom,
        address tokenTo
    ) public returns (uint256 amountOut) {
        // msg.sender must approve this contract
        ISwapRouter swapRouter = ISwapRouter(UNISWAP_V3);
        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            tokenFrom,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(tokenFrom, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
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
        amountOut = swapRouter.exactInputSingle(params);
    }

    /// @notice Swapping an Exact Token for an Enough Token on the vault
    function swapTokensVelo(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) public returns (uint256 amountOut) {
        IVeloRouter veloRouter = IVeloRouter(VELO_ROUTER);

        require(
            uint256(IERC20(tokenIn).allowance(msg.sender, address(this))) >=
                amountIn,
            "Not enough allowance"
        );
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(VELO_ROUTER, amountIn);

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
        // /// Refund tokenIn when the expected minimum out is not met
        // if (amountOutMin > amounts[2]) {
        //     IERC20(tokenIn).transfer(msg.sender, amounts[0]);
        // }

        return amounts[1];
    }

    /** Function for swap using router v2
     * @param dex - address of dex to trade on (0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F for mainnet)
     * @param tokenFrom - address of token to sell (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (WETH) for mainnet)
     * @param tokenTo - address of token to buy (0x6B175474E89094C44Da98b954EedeAC495271d0F (DAI) for mainnet)
     * @param amount - amount of token to sell
     */
    function swapTokensV2(
        address dex,
        address tokenFrom,
        address tokenTo,
        uint256 amount
    ) public payable onlyWhitelisted returns (uint256) {
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
