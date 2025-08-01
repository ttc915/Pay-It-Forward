require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify"); 
require("hardhat-gas-reporter");
require("solidity-coverage");
require("dotenv").config({ path: __dirname + '/.env' });

// Ensure we have the required environment variables
const { ETHERSCAN_API_KEY, COINMARKETCAP_API_KEY } = process.env;

// List of supported networks with their configurations
const NETWORKS = {
  hardhat: {
    chainId: 31337,
    allowUnlimitedContractSize: true, 
  },
  localhost: {
    chainId: 31337,
    url: "http://127.0.0.1:8545",
  },
  // Example configuration for testnet/mainnet (uncomment and configure as needed)
  /*
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "",
    chainId: 11155111,
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  },
  mainnet: {
    url: process.env.MAINNET_RPC_URL || "",
    chainId: 1,
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  },
  */
};

// Solidity compiler configuration
const SOLIDITY_SETTINGS = {
  version: "0.8.19",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
      details: {
        yul: true,
      },
    },
    viaIR: true, 
  },
};

module.exports = {
  solidity: SOLIDITY_SETTINGS,
  
  // Network configurations
  networks: NETWORKS,
  
  // Etherscan verification
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY,
      sepolia: ETHERSCAN_API_KEY,
      // Add other networks as needed
    },
  },
  
  // Gas reporter configuration (for gas optimization)
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true",
    currency: "USD",
    coinmarketcap: COINMARKETCAP_API_KEY,
    token: "ETH", 
    gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
  },
  
  // Configuration for contract verification
  sourcify: {
    enabled: true, 
  },
  
  // Path configuration
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  
  // Typechain configuration
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
  
  // For local development
  mocha: {
    timeout: 40000, 
  },
};