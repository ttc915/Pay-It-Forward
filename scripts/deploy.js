// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  console.log("Deploying PayItForward contract...");
  
  // Get the contract factory
  const PayItForward = await hre.ethers.getContractFactory("PayItForward");
  
  // Deploy the contract
  const payItForward = await PayItForward.deploy();
  
  // Wait for deployment to complete
  await payItForward.waitForDeployment();
  
  console.log("PayItForward deployed to:", await payItForward.getAddress());
  
  // Get the addresses of the deployed tokens
  const rewardTokenAddress = await payItForward.rewardToken();
  const erc20RonAddress = await payItForward.erc20Ron();
  
  console.log("RewardToken deployed to:", rewardTokenAddress);
  console.log("ERC20RON deployed to:", erc20RonAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
