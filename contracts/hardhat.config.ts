import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import * as crypto from "crypto";

const {
  LOCALHOST_OWNER_ADDRESS,
  OPT_GOERLI_ALCHEMY_URL,
  OPT_GOERLI_ACCOUNT_PRIVATE_KEY,
  OPT_GOERLI_ACCOUNT_OWNER_ADDRESS,
  GOERLI_ALCHEMY_URL,
  GOERLI_ACCOUNT_PRIVATE_KEY,
  GOERLI_ACCOUNT_OWNER_ADDRESS,
  MAINNET_ALCHEMY_URL,
  MAINNET_OWNER_ADDRESS,
  MAINNET_ACCOUNT_PRIVATE_KEY,
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
      {
        version: "0.6.2",
      },
    ],
  },
  defaultNetwork: "optimismGoerli",
  networks: {
    hardhat: {
      forking: {
        url: MAINNET_ALCHEMY_URL ?? "",
      },
      from: MAINNET_OWNER_ADDRESS,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      from: LOCALHOST_OWNER_ADDRESS,
    },
    optimismGoerli: {
      url: `${OPT_GOERLI_ALCHEMY_URL}`,
      accounts: [
        `0x${fetchEthAccountPrivateKey(OPT_GOERLI_ACCOUNT_PRIVATE_KEY)}`,
      ],
      from: OPT_GOERLI_ACCOUNT_OWNER_ADDRESS,
      gasPrice: 100000000,
    },
    goerli: {
      url: `${GOERLI_ALCHEMY_URL}`,
      accounts: [`0x${fetchEthAccountPrivateKey(GOERLI_ACCOUNT_PRIVATE_KEY)}`],
      from: GOERLI_ACCOUNT_OWNER_ADDRESS,
      gasPrice: 100000000,
    },
    mainnet: {
      url: `${MAINNET_ALCHEMY_URL}`,
      accounts: [`0x${fetchEthAccountPrivateKey(MAINNET_ACCOUNT_PRIVATE_KEY)}`],
      from: MAINNET_OWNER_ADDRESS,
      gasPrice: 2000000000,
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
