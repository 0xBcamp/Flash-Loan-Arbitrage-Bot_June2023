import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import * as crypto from "crypto";

const {
  LOCALHOST_OWNER_ADDRESS,
  GOERLI_ALCHEMY_URL,
  GOERLI_ALCHEMY_PRIVATE_KEY,
  GOERLI_ALCHEMY_OWNER_ADDRESS,
} = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      from: LOCALHOST_OWNER_ADDRESS,
    },
    optimismGoerli: {
      url: `${GOERLI_ALCHEMY_URL}`,
      accounts: [`0x${fetchEthAccountPrivateKey(GOERLI_ALCHEMY_PRIVATE_KEY)}`],
      from: GOERLI_ALCHEMY_OWNER_ADDRESS,
      gasPrice: 100000000,
    },
  },
};

function fetchEthAccountPrivateKey(pvtKeyEnvVar: string | undefined): string {
  if (pvtKeyEnvVar) {
    console.log("private key was set as environment variable");
    return pvtKeyEnvVar;
  }
  console.log(
    "private key was not set as environment variable. Generating mocked private key"
  );
  return generateMockedPvtKey();
}

function generateMockedPvtKey(): string {
  return crypto.randomBytes(32).toString("hex");
}

export default config;
