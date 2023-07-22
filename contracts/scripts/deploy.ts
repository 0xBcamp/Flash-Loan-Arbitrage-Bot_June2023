import { ethers, network } from "hardhat";

const {
  AAVE_POOL_ADDRESS_PROVIDER,
  UNISWAP_V3_QUOTER,
  UNISWAP_V3_SWAP_ROUTER,
  VELO_ROUTER,
} = process.env;

async function main() {
  const [signer] = await ethers.getSigners();
  const provider = ethers.provider;
  const signerBalance = await provider.getBalance(signer.address);

  console.log(
    `starting the deployment script, will deploy multiple contracts to the network: '${network.name}', 
     with owner set to: '${signer.address}', balance: '${signerBalance}'`
  );

  deployContracts();
}

async function deployContracts() {
  const tradeExecutorAddr = await deployTradeExecutor();
  const arbitrageExecutorAddr = await deployArbitrageExecutor(
    tradeExecutorAddr
  );
  const arbitrageFinderAddr = await deployArbitrageFinder();

  const botContractName = "ArbitrageBot";
  console.log(`deploying ${botContractName} contract`);

  const contractFactory = await ethers.getContractFactory(botContractName);

  var contract = await contractFactory.deploy(
    arbitrageFinderAddr,
    arbitrageExecutorAddr
  );

  contract = await contract.waitForDeployment();

  console.log(
    `contract with name ${botContractName} was deployed to address: ${await contract.getAddress()}`
  );
}

async function deployTradeExecutor(): Promise<string> {
  const contractName = "TradeExecutor";
  console.log(`deploying ${contractName} contract`);

  const contractFactory = await ethers.getContractFactory(contractName);

  var contract = await contractFactory.deploy(
    UNISWAP_V3_SWAP_ROUTER!,
    VELO_ROUTER!
  );

  contract = await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log(
    `contract with name ${contractName} was deployed to address: ${address}`
  );

  return address;
}

async function deployArbitrageExecutor(
  tradeExecutorAddr: string
): Promise<string> {
  const contractName = "ArbitrageExecutor";
  console.log(`deploying ${contractName} contract`);

  const contractFactory = await ethers.getContractFactory(contractName);

  var contract = await contractFactory.deploy(
    AAVE_POOL_ADDRESS_PROVIDER!,
    tradeExecutorAddr
  );

  contract = await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log(
    `contract with name ${contractName} was deployed to address: ${address}`
  );

  return address;
}

async function deployArbitrageFinder(): Promise<string> {
  const contractName = "ArbitrageFinder";
  console.log(`deploying ${contractName} contract`);

  const contractFactory = await ethers.getContractFactory(contractName);

  var contract = await contractFactory.deploy(UNISWAP_V3_QUOTER!, VELO_ROUTER!);

  contract = await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log(
    `contract with name ${contractName} was deployed to address: ${address}`
  );

  return address;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
