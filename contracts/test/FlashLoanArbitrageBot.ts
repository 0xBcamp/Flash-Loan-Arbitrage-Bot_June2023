import { expect } from "chai";
import { ethers, network } from "hardhat";
import { deployContracts, Contracts } from "../scripts/deploy";

const USDC = "0x7f5c764cbc14f9669b88837ca1490cca17c31607";
const WETH = "0x4200000000000000000000000000000000000006";

describe("Flash Loan Arbitrage Bot", function () {
  async function bootstrap(): Promise<Contracts> {
    const [signer] = await ethers.getSigners();
    const provider = ethers.provider;
    const signerBalance = await provider.getBalance(signer.address);

    console.log(
      `starting the deployment script, will deploy multiple contracts to the network: '${network.name}', 
     with owner set to: '${signer.address}', balance: '${signerBalance}'`
    );

    const contracts = await deployContracts();
    return contracts;
  }

  it("Should pass", async function () {
    const { bot } = await bootstrap();
    const [signer] = await ethers.getSigners();
    const addr = await signer.getAddress();

    await bot.addToWhitelist(addr);
    console.log("signer is whitelisted: ", await bot.isWhitelisted(addr));

    await bot.execute(WETH, USDC);

    await bot.on(bot.getEvent("ArbitrageOpportunity"), async (isFound) => {
      expect(isFound).to.equal(false);
    });
  });
});
