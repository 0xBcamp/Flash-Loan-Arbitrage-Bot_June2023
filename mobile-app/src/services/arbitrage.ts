import { ethers } from "ethers";
import { arbitrageBotAddress, botAbi } from "src/constants/contract";

export const isAccountWhitelisted = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);

    const contract = new ethers.Contract(
      arbitrageBotAddress,
      botAbi,
      web3Provider
    );

    const address = await web3Provider.getSigner().getAddress();

    console.log(`checking if address: ${address} is whitelisted`);

    const isWhitelisted: boolean = await contract.isWhitelisted(address);
    console.log(`signer is whitelisted: ${isWhitelisted}`);
    return isWhitelisted;
  } catch (error) {
    throw error;
  }
};

export const whitelistAccount = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);

    const contract = new ethers.Contract(
      arbitrageBotAddress,
      botAbi,
      web3Provider
    );

    const address = await web3Provider.getSigner().getAddress();
    console.log(`will whitelist address: ${address}`);

    await contract.addToWhitelist(address);
    return true;
  } catch (error) {
    throw error;
  }
};

export const launchArbitrage = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);

    const contract = new ethers.Contract(
      arbitrageBotAddress,
      botAbi,
      web3Provider
    );
    const wethAddr = "";
    const daiAddr = "";
    console.log(`launching aribtrage bot`);

    await contract.execute(wethAddr, daiAddr);

    return true;
  } catch (error) {
    throw error;
  }
};
