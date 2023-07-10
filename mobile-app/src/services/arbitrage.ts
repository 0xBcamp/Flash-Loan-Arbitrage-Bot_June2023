import { ethers } from "ethers";
import { contractAddress, engineAbi } from "src/constants/contract";

export const signerIsWhitelisted = async (provider: any): Promise<boolean> => {
  try {
    const web3Provider = new ethers.providers.Web3Provider(provider);

    const contract = new ethers.Contract(
      contractAddress,
      engineAbi,
      web3Provider
    );

    const signer = await web3Provider.getSigner();

    const isWhitelisted: boolean = await contract.isWhitelisted(
      await signer.getAddress()
    );
    console.log(`signer is whitelisted: ${isWhitelisted}`);
    return isWhitelisted;
  } catch (error) {
    throw error;
  }
};
