import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import * as crypto from "crypto";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    optimismGoerli: {
      url: `${process.env.ALCHEMY_GOERLI_URL}`,
      accounts: [`0x${fetchEthAccountPrivateKey()}`],
    },
  },
};

function fetchEthAccountPrivateKey(): string {
  if (process.env.GOERLI_PRIVATE_KEY) {
    console.log("private key was set as environment variable");
    return process.env.GOERLI_PRIVATE_KEY;
  }
  console.log(
    "private key was not set as environment variable. Generating mocked private key"
  );
  var mockPvtKey = crypto.randomBytes(32).toString("hex");
  return mockPvtKey;
}

export default config;
