import { ethers, network } from "hardhat";

const standaloneContracts: string[] = [
  "ArbitrageEngine",
  "FlashLoanHandler",
  "TradeExecutor",
  "RepaymentHandler",
];

const ownerAddress = network.config.from;

async function main() {
  if (ownerAddress === undefined) {
    throw new Error("owner address must be set in configuration");
  }

  const owner = await ethers.getSigner(ownerAddress);

  console.log(
    `starting the deployment script, will deploy multiple contracts to the network: '${network.name}, 
     with owner set to: '${owner.address}'`
  );

  deployContracts();
}

async function deployContracts() {
  const contractNameAddr = await deployStandaloneContracts();
  
  const botContractName = "FlashLoanArbitrageBot";
  console.log(`deploying ${botContractName} contract`);

  const contractFactory = await ethers.getContractFactory(botContractName);

  var contract = await contractFactory.deploy(
    contractNameAddr.get("ArbitrageEngine")!,
    contractNameAddr.get("FlashLoanHandler")!,
    contractNameAddr.get("TradeExecutor")!,
    contractNameAddr.get("RepaymentHandler")!
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

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
