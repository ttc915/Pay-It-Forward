# PayItForward Contract Testing with Remix IDE

This guide explains how to test the PayItForward contract using Remix IDE with local file synchronization via remixd.

## Prerequisites

1. Install [Git](https://git-scm.com/downloads)
2. Install [Node.js](https://nodejs.org/) (LTS version recommended)
3. Install [MetaMask](https://metamask.io/) browser extension
4. Get Sepolia test ETH from a faucet

## 1. Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ttc915/Pay-It-Forward.git
   cd Pay-It-Forward
   ```
2. Install project dependencies:
   ```bash
   npm install
   ```

## 2. Remix IDE Setup

1. Install remixd globally:
   ```bash
   npm install -g @remix-project/remixd
   ```
2. Start the remixd daemon in your project directory:
   ```bash
   remixd -s ./ --remix-ide https://remix.ethereum.org
   ```
3. Open [Remix IDE](https://remix.ethereum.org/)
4. In the file explorer, click on the "Connect to localhost" button
5. Confirm the connection in your browser if prompted
6. You should now see your local project files in Remix

## 3. Compile Contracts

1. In Remix, open the "Solidity Compiler" tab
2. Select compiler version 0.8.26
3. Click "Compile PayItForward.sol"
4. Check for any compilation errors

## 4. Deploy to Sepolia Testnet

1. In Remix, go to "Deploy & Run Transactions" tab
2. Select "Injected Provider - MetaMask" as the environment
3. Make sure you're connected to the Sepolia Testnet in MetaMask
   - If Sepolia is not visible:
     1. Click on the network dropdown in MetaMask
     2. Select "Show/hide test networks"
     3. Toggle "Show test networks" to ON
     4. Select "Sepolia" from the network list
4. Select "PayItForward" contract
5. Click "Deploy"
6. Confirm the transaction in MetaMask
7. Save the deployed contract address for later use

## 5. Testing Workflow

### 5.1 Get RONStablecoin for Testing

1. In Remix, go to the "Deployed Contracts" section
2. Find your PayItForward contract and click on it
3. Click on the `ronToken()` function to get the RONStablecoin address
4. In the "Deploy & Run Transactions" tab:
   - Select "RONStablecoin" from the contract dropdown
   - Paste the RONStablecoin address in the "At Address" field next to the "Deploy" button
5. Click "At Address" to load the RONStablecoin contract interface
6. Mint tokens to your test account:
   - In the RONStablecoin contract interface, find the `mint` function
   - Enter these values:
     - `to`: Your wallet address
     - `amount`: The amount in wei (e.g., 100 \* 10^18 for 100 vRON)
   - Click "transact" and confirm in MetaMask
   - Verify your balance using the `balanceOf` function with your wallet address

### 5.2 Create Project and Initiative

#### 5.2.1 Create a Project

1. In Remix, with the PayItForward contract interface open:
   - Find the `createProject` function
   - Enter the project details:
     - `title`: Your project title (e.g., "Community Fund")
     - `description`: A brief description of the project
   - Click "transact" and confirm in MetaMask
   - Note: The transaction will return a project ID (starts from 0)

2. Verify project creation:
   - Find the `getProject` function
   - Enter the project ID (start with 0)
   - Click "call" to view the project details

#### 5.2.2 Create an Initiative

1. In the PayItForward contract interface:
   - Find the `createInitiative` function
   - Enter the initiative details:
     - `projectId`: The ID of the project this initiative belongs to (start with 0)
     - `title`: Initiative title (e.g., "Food Drive 2023")
     - `description`: A brief description of the initiative
     - `fundingTarget`: The funding target in wei (e.g., 50 \* 10^18 for 50 vRON)
   - Click "transact" and confirm in MetaMask
   - Note: The transaction will return an initiative ID (starts from 0)

2. Verify initiative creation:
   - Find the `getInitiative` function
   - Enter the initiative ID (start with 0)
   - Click "call" to view the initiative details

### 5.3 Make a Donation

1. Approve token spending (one-time per account):
   - In the RONStablecoin contract interface
   - Find the `approve` function
   - Enter:
     - `spender`: The PayItForward contract address
     - `amount`: The amount to approve (e.g., 100 \* 10^18 for 100 vRON)
   - Click "transact" and confirm in MetaMask

2. Make a donation:
   - In the PayItForward contract interface
   - Find the `donate` function
   - Enter:
     - `initiativeId`: The ID of the initiative to donate to
     - `amount`: The amount in wei (e.g., 10 \* 10^18 for 10 vRON)
   - Click "transact" and confirm in MetaMask
   - This will trigger the `DonationReceived` event

3. Verify the donation:
   - Find the `getDonorContribution` function
   - Enter the initiative ID and donor address
   - Click "call" to view the donation amount

### 5.4 Claim Funds (Project Owner)

1. Once an initiative's funding target is reached, the project owner can claim the funds:
   - In the PayItForward contract interface, find the `claimFunds` function
   - Enter the `initiativeId`
   - Click "transact" and confirm in MetaMask
   - This will trigger the `FundsClaimed` event

2. Verify the funds were transferred:
   - Check the project owner's RON token balance using the `balanceOf` function
   - The initiative's `isFulfilled` status should be `true`
   - The `totalRaised` should be reset to 0

## 6. Set Up Test Accounts

### 6.1 (Optional) Set Up Multiple Test Accounts

1. In MetaMask, create additional test accounts
2. Get test ETH for each account from the faucet
3. Use the `mint` function to send vRON tokens to each test account

## Troubleshooting

### If you get "Insufficient balance" errors:

1. Make sure you've minted vRON tokens to your account
2. Check that you've approved the PayItForward contract to spend your vRON
3. Verify the token amounts are in wei (add 18 decimals)

### If you get "Transaction reverted" errors:

1. Check the error message in the Remix console
2. Common issues:
   - Not enough ETH for gas
   - Initiative not found or expired
   - Goal already reached
   - Invalid amount (must be > 0)

## 7. Save Contract ABIs (Optional)

To interact with the contracts later:

1. In Remix, go to the "Solidity Compiler" tab
2. Click on the ABI copy button for each contract
3. Save them as JSON files in your project (e.g., `PayItForward.abi.json`)

## Next Steps

1. Write automated tests using Hardhat or Truffle
2. Create a frontend using web3.js or ethers.js
3. Consider adding more test cases for edge conditions

## Cleanup

When done testing, follow these steps to properly clean up:

1. Stop the remixd process (Ctrl+C in terminal)
2. Disconnect Remix IDE from localhost
3. Consider revoking token approvals if needed
