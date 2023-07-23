import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import * as crypto from "crypto";

const {
  OPT_GOERLI_ALCHEMY_URL,
  OPT_GOERLI_ACCOUNT_PRIVATE_KEY,
  OPT_MAINNET_ACCOUNT_PRIVATE_KEY,
  OPT_MAINNET_ALCHEMY_URL,
} = process.env;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.10",
      },
      {
        version: "0.8.19",
      },
    ],
  },
  defaultNetwork: "optimismGoerli",
  networks: {
    hardhat: {
      forking: {
        url: `${OPT_MAINNET_ALCHEMY_URL}`,
      },
      accounts: [
        {
          privateKey: `0x${fetchEthAccountPrivateKey(
            OPT_MAINNET_ACCOUNT_PRIVATE_KEY
          )}`,
          balance: "9999999999999999999999999999",
        },
      ],
    },
    optimismGoerli: {
      url: `${OPT_GOERLI_ALCHEMY_URL}`,
      accounts: [
        `0x${fetchEthAccountPrivateKey(OPT_GOERLI_ACCOUNT_PRIVATE_KEY)}`,
      ],
      gasPrice: 110000000,
    },
    optimismMainnet: {
      url: `${OPT_MAINNET_ALCHEMY_URL}`,
      accounts: [
        `0x${fetchEthAccountPrivateKey(OPT_MAINNET_ACCOUNT_PRIVATE_KEY)}`,
      ],
      gasPrice: 100000000,
    },
  },
};

function fetchEthAccountPrivateKey(pvtKeyEnvVar: string | undefined): string {
  console.log(pvtKeyEnvVar);
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
