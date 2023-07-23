import { ethers } from "ethers";
import { BotAddress } from "src/constants/contract";
import { botAbi } from "src/constants/abi";
import { USDC, WETH } from "src/constants/currency";

export const isAccountWhitelisted = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);

    const contract = new ethers.Contract(BotAddress, botAbi, web3Provider);

    const address = await web3Provider.getSigner().getAddress();

    console.log(`checking if address: ${address} is whitelisted`);

    const isWhitelisted: boolean = await contract.isWhitelisted(address);
    console.log(`signer is whitelisted: ${isWhitelisted}`);
    return isWhitelisted;
  } catch (error) {
    console.log(error);
    return false;
  }
};

export const whitelistAccount = async (provider: any): Promise<void> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);
    const signer = web3Provider.getSigner();

    const contract = new ethers.Contract(BotAddress, botAbi, signer);

    const address = await signer.getAddress();
    console.log(`will whitelist address: ${address}`);

    await contract.addToWhitelist(address);

    console.log(`address: ${address} was whitelisted`);
  } catch (error) {
    console.log(error);
  }
};

export const removeAccountFromWhitelist = async (
  provider: any
): Promise<void> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);
    const signer = web3Provider.getSigner();

    const contract = new ethers.Contract(BotAddress, botAbi, signer);

    const address = await signer.getAddress();
    console.log(`will remove from whitelist address: ${address}`);

    await contract.removeFromWhitelist(address);

    console.log(`address: ${address} from removed form whitelist`);
  } catch (error) {
    console.log(error);
  }
};

export const launchArbitrage = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);
    const signer = await web3Provider.getSigner();

    const contract = new ethers.Contract(BotAddress, botAbi, signer);

    console.log(`launching arbitrage bot`);
    var isFound: boolean = false;

    await contract.execute(WETH, USDC);
    await contract.on("ArbitrageOpportunity", (found: boolean) => {
      console.log(found);
      isFound = found;
      return;
    });

    return isFound;
  } catch (error) {
    console.log(error);
    throw error;
  }
};
