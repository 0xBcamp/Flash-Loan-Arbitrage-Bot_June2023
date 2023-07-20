import { ethers, network } from "hardhat";

const standaloneContracts: string[] = ["TradeExecutor"];

const ownerAddress = network.config.from;

const {
  MAINNET_POOL_ADDRESS_PROVIDER,
  MAINNET_UNISWAP_ROUTER_ADDRESS,
  MAINNET_SUSHISWAP_ROUTER_ADDRESS,
} = process.env;

async function main() {
  if (ownerAddress === undefined) {
    throw new Error("owner address must be set in configuration");
  }

  const owner = await ethers.getSigner(ownerAddress);

  console.log(
    `starting the deployment script, will deploy multiple contracts to the network: '${network.name}', 
     with owner set to: '${owner.address}'`
  );

  deployContracts();
}

async function deployContracts() {
  const contractNameAddr = await deployStandaloneContracts();
  const tradeExecutorAddr = await deployArbitrageExecutor(
    contractNameAddr.get("TradeExecutor")!
  );
  const arbitrageFinderAddr = await deployArbitrageFinder();

  const botContractName = "ArbitrageBot";
  console.log(`deploying ${botContractName} contract`);

  const contractFactory = await ethers.getContractFactory(botContractName);

  var contract = await contractFactory.deploy(
    arbitrageFinderAddr,
    tradeExecutorAddr
  );

  contract = await contract.waitForDeployment();

  console.log(
    `contract with name ${botContractName} was deployed to address: ${await contract.getAddress()}`
  );
}

async function deployStandaloneContracts(): Promise<Map<string, string>> {
  const contractNameAddr = new Map<string, string>();

  for (const contractName of standaloneContracts) {
    console.log(`deploying contract: '${contractName}'`);
    const contractFactory = await ethers.getContractFactory(contractName);

    var contract = await contractFactory.deploy();
    contract = await contract.waitForDeployment();

    const addr: string = await contract.getAddress();
    console.log(
      `contract with name ${contractName} was deployed to address: ${addr}`
    );
    contractNameAddr.set(contractName, addr);
  }

  return contractNameAddr;
}

async function deployArbitrageExecutor(
  tradeExecutorAddr: string
): Promise<string> {
  const contractName = "ArbitrageExecutor";
  console.log(`deploying ${contractName} contract`);

  const contractFactory = await ethers.getContractFactory(contractName);

  var contract = await contractFactory.deploy(
    MAINNET_POOL_ADDRESS_PROVIDER!,
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

  var contract = await contractFactory.deploy(
    MAINNET_UNISWAP_ROUTER_ADDRESS!,
    MAINNET_SUSHISWAP_ROUTER_ADDRESS!
  );

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
