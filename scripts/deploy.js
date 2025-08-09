// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  console.log("Starting deployment...");

  // Deploy PayItForward contract which will deploy RONStablecoin and PIFRewards
  console.log("Deploying PayItForward contract...");
  const PayItForward = await hre.ethers.getContractFactory("PayItForward");
  const payItForward = await PayItForward.deploy();
  await payItForward.waitForDeployment();

  const payItForwardAddress = await payItForward.getAddress();
  console.log("PayItForward deployed to:", payItForwardAddress);

  // Get the addresses of the deployed tokens
  const ronTokenAddress = await payItForward.ronToken();
  const rewardTokenAddress = await payItForward.rewardToken();

  console.log("RONStablecoin deployed to:", ronTokenAddress);
  console.log("PIFRewards deployed to:", rewardTokenAddress);

  // Verify the contracts on block explorer (if on a live network)
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying contracts on Etherscan...");

    // Wait for block explorer to index the contract
    console.log("Waiting for block confirmations...");
    await new Promise((resolve) => setTimeout(resolve, 30000));

    try {
      await hre.run("verify:verify", {
        address: payItForwardAddress,
        constructorArguments: [],
      });
      console.log("PayItForward verified on Etherscan");
    } catch (error) {
      console.error("Error verifying PayItForward:", error.message);
    }
  }

  return {
    payItForward: payItForwardAddress,
    ronToken: ronTokenAddress,
    rewardToken: rewardTokenAddress,
  };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
