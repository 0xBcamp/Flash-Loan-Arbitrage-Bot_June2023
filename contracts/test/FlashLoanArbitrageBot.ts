import { expect } from "chai";
import { ethers, network } from "hardhat";
import { ArbitrageFinder } from "../typechain-types/contracts/ArbitrageFinder"; // Update the path to the generated contract types
import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { networkConfig } from "../helper-hardhat-config";

// describe("Flash Loan Arbitrage Bot", function () {
//   it("Should pass", async function () {

//     const veloRouter = 
//     const sushiswapRouter = 


//     const arbitrageEngineFactory = await ethers.getContractFactory("ArbitrageEngine");
//     const arbitrageEngine = await arbitrageEngineFactory
//       .connect(deployer)
//       .deploy();
//     const tradeExecutorFactory = await ethers.getContractFactory("TradeExecutor");
//     const tradeExecutor = await tradeExecutorFactory
//       .connect(deployer)
//       .deploy();

//     console.log("ArbitrageEngine deployed to:", await arbitrageEngine.getAddress());
//     console.log("TradeExecutor deployed to:", await tradeExecutor.getAddress());
//     console.log(`${chainId} network config: ${networkConfig[chainId]["uniswap_router_v2"]}`);

//     let isOpportunity = await arbitrageEngine.checkArbitrageOpportunity(
//       veloRouter, sushiswapRouter, weth, dai);
//     console.log("isOpportunity: ", isOpportunity);

//     console.log("Getting weth from eth...")
//     const balanceOfWeth = await tradeExecutor.getWethFromEth(weth, { value: ethers.BigNumber.from("1000000000000000000") });
//     console.log("Your balance of weth is: ", balanceOfWeth);

//     // Make arbitrage opportunity 


//     expect(true).to.equal(true);
//   });
// });


const chainId = network.config.chainId;

describe("ArbitrageFinder", () => {
  const uniswapRouterAddress = networkConfig[chainId]["uniswap_router_v3"];; // Replace with the actual address
  const veloRouterAddress = networkConfig[chainId]["velo_router_v2"];; // Replace with the actual address
  const sushiSwapRouterAddress = networkConfig[chainId]["sushiswap_router_v2"];; // Replace with the actual address

  async function beforeIt(): Promise<any> {
    /* Get the signers */
    const [deployer] = await ethers.getSigners();

    // Replace these addresses with actual token addresses you want to test
    const token1 = networkConfig[chainId]["dai"];
    const token2 = networkConfig[chainId]["weth"];

    /* Initialization of addresses independent on the network */
    // Deploy the contracts
    const TradeExecutor = await ethers.getContractFactory("TradeExecutor");
    const ArbitrageFinder = await ethers.getContractFactory("ArbitrageFinder");
    const wethToken = await ethers.getContractAt("IWeth", token2);
    const daiToken = await ethers.getContractAt("IERC20", token1);
    const tradeExecutor = await TradeExecutor
      .connect(deployer)
      .deploy();
    const arbitrageFinder = await ArbitrageFinder
      .connect(deployer)
      .deploy(uniswapRouterAddress, veloRouterAddress);
    return { arbitrageFinder, tradeExecutor, wethToken, daiToken, deployer };
  };

  it("1. should find arbitrage opportunity", async () => {

    const { arbitrageFinder, tradeExecutor, wethToken, daiToken, deployer } = await beforeIt();

    // Call the find function
    await arbitrageFinder.addToWhitelist(deployer.address);
    await tradeExecutor.addToWhitelist(deployer.address);
    await tradeExecutor.getWethFromEth(networkConfig[chainId]["weth"], { value: ethers.parseEther("12") });
    /* Make arbitrage opportunity */
    console.log("Before swap %s", await wethToken.balanceOf(deployer.address));
    console.log("Before swap %s", await daiToken.balanceOf(deployer.address));
    console.log("Swapping function...");
    await wethToken.approve(tradeExecutor.target, ethers.parseEther("10"));
    await tradeExecutor.executeTrade(uniswapRouterAddress, wethToken.target, daiToken.target, ethers.parseEther("10"));
    console.log("After swap %s", await wethToken.balanceOf(deployer.address));
    console.log("After swap %s", await daiToken.balanceOf(deployer.address));

    const [found, opportunity] = await arbitrageFinder.find(daiToken.target, wethToken.target);

    // Assert the result
    expect(found).to.be.true;
    console.log("1. opportunity: ", opportunity);
    console.log("1 .opportunity: ", opportunity[0]);

    // expect(opportunity).to.not.be.undefined;
    // You can add more assertions based on your contract's logic
  });

  it("2. should not find arbitrage opportunity", async () => {
    const { arbitrageFinder, tradeExecutor, wethToken, daiToken, deployer } = await beforeIt();

    // Call the find function
    await arbitrageFinder.addToWhitelist(deployer.address);
    await tradeExecutor.addToWhitelist(deployer.address);
    const [found, opportunity] = await arbitrageFinder.find(daiToken.address, wethToken.address);
    console.log("2. opportunity: ", opportunity);
    // Assert the result
    expect(found).to.be.false;
    //expect(opportunity).to.be.undefined;
    // You can add more assertions based on your contract's logic
  });
});
