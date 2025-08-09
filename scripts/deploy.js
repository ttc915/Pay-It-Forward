// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  console.log("Deploying PayItForward contract...");

  // Deploy PIFRewards token first
  console.log("Deploying PIFRewards token...");
  const PIFRewards = await hre.ethers.getContractFactory("PIFRewards");
  const pifRewards = await PIFRewards.deploy();
  await pifRewards.waitForDeployment();
  console.log("PIFRewards deployed to:", await pifRewards.getAddress());

  // Deploy RONStablecoin token
  console.log("Deploying RONStablecoin token...");
  const RONStablecoin = await hre.ethers.getContractFactory("RONStablecoin");
  const ronStablecoin = await RONStablecoin.deploy();
  await ronStablecoin.waitForDeployment();
  console.log("RONStablecoin deployed to:", await ronStablecoin.getAddress());

  // Deploy PayItForward with token addresses
  console.log("Deploying PayItForward...");
  const PayItForward = await hre.ethers.getContractFactory("PayItForward");
  const payItForward = await PayItForward.deploy();
  await payItForward.waitForDeployment();

  console.log("PayItForward deployed to:", await payItForward.getAddress());

  // Verify token addresses in PayItForward
  const deployedRewardToken = await payItForward.rewardToken();
  const deployedStablecoin = await payItForward.erc20Ron();

  console.log("PIFRewards address in PayItForward:", deployedRewardToken);
  console.log("RONStablecoin address in PayItForward:", deployedStablecoin);

  // Verify the contracts on block explorer (if on a live network)
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Waiting for block confirmations...");
    await new Promise((resolve) => setTimeout(resolve, 60000)); // Wait for 1 minute

    console.log("Verifying contracts...");
    await hre.run("verify:verify", {
      address: await pifRewards.getAddress(),
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
      address: await ronStablecoin.getAddress(),
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
      address: await payItForward.getAddress(),
      constructorArguments: [],
    });
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
