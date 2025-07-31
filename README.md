# Pay It Forward (PIF) 🌱

**ETHCluj Hackathon 2025**  
Empowering local communities, schools, and NGOs through transparent blockchain-based fundraising.

---

## 🧠 Project Summary

**Pay It Forward (PIF)** is a decentralized donation platform that allows parents, communities, and donors to fund school and local initiatives using crypto-backed smart contracts. 

Donors receive PIF tokens as a reward and can always trust that funds will be used transparently, via smart contracts.

> “A teacher launches a project to fund 10 new desks for a rural school. Donations flow in via a RON-pegged stablecoin, and each supporter receives PIF tokens as thanks. If the goal isn’t reached in 3 months, everyone gets their money back.”

---

## 💡 Key Features
- 🏗️ **Simple Architecture**
  Focused on ease of use and initiative creation.

- ⏳ **Time & Amount-Limited Initiatives**
  Projects have specific deadlines (max 3 months) and target amounts.

- 💸 **Automatic Refund Mechanism**
  If the goal isn’t met, smart contracts refund all donors without needing any manual action.

- 🪙 **Reward Token: PIF**  
  Every donor earns PIF tokens as recognition for their contribution.
  
- 🔒 **Transparent Smart Contract Logic**  
  All donations are locked in smart contracts until conditions are met (funded or expired).

- 🌊 **Ocean Protocol Integration**  
  Donation metadata is published as decentralized data assets for transparency and public access.

---

## 🔗 Architecture Overview

Each **Project** (school, NGO, etc.) can host multiple **Initiatives**.  

Each initiative includes:
- Goal amount in RON (via stable token)
- Deadline (max 3 months)
- Real-world purpose (e.g., buying 10 school benches)

```mermaid
flowchart TD
    A[Create Initiative]
    B[Publish Metadata on Ocean Protocol]
    C[Receive Donations]
    D[Hold Funds in Smart Contract]
    E{Deadline or Goal Reached?}
    F[Settle & Distribute Rewards]
    G[Refund Donations]
    H[Accept More Donations]

    A --> B --> C --> D --> E
    E -- Goal Met --> F
    E -- Deadline Passed --> G
    E -- Ongoing --> H

```

All logic is handled on-chain through smart contracts written in Solidity using Hardhat.

> *(Planned IPFS support to attach image + description metadata to each initiative)*

---

## 🌊 Data Transparency with Ocean Protocol

To enhance trust, all initiative and donation metadata is published as **data NFTs** on Ocean Protocol.

- 🧾 Each initiative’s metadata is stored immutably (goal, deadline, description)
- 🌍 Donors can view real-time funding data via Ocean’s decentralized marketplace
- 🔐 Future expansion may use **Compute-to-Data** for insights while protecting donor privacy

This creates:
- A transparent, decentralized public record
- Verifiable donation history
- Potential for third-party analysis, funding metrics, and DAO integrations

---

## ⚙️ Tech Stack

- **Smart Contracts**: Solidity + Hardhat
- **Frontend**: [Coming Soon]
- **Tokens**:
  - `PIF`: ERC20 Reward Token
  - `RONToken`: Stablecoin-pegged donation token
- **Data Layer**: Ocean Protocol (data NFTs + metadata publishing)
  
---

## 🔐 Security Considerations

- ✅ All funds are time-locked until either:
  - Target is reached → allows payout
  - Deadline passes without funding → enables refund

- 🚫 No owner withdrawal privileges unless project conditions are fully met  
- ⚠️ Additional validation to prevent early rugpulls (donation lock-in period)

---

## 📽️ Pitch Deck

### 🇬🇧 English  
Check out our project pitch deck here:  
👉 [Pay It Forward – ETHCluj Pitch Deck](https://www.canva.com/design/DAGuupentiY/XolSy_w54JiZujdMBzzNcw/edit)

### 🇷🇴 Romanian  
> *Versiunea în limba română a pitch deck-ului va fi disponibilă în curând.*

---
## 📽️ Product Demo

Coming soon!

A short walkthrough of the donation flow, initiative creation, and reward system. 

📺 **[Placeholder:YouTube link ]**

---

## 🚀 Roadmap

- [x] Smart contract: initiative creation, donation, refund, reward
- [ ] Integrate **Ocean Protocol** to publish donation/project metadata as decentralized data assets
- [ ] Finalize frontend integration  
- [ ] Record & embed product demo  
- [ ] Add initiative metadata to IPFS  
- [ ] Add community voting / upvote system  
- [ ] Add donor reputation scoring (future)  
- [ ] Launch a **Rewards Shop** where PIF tokens can be exchanged for:
  - Merch products  
  - Partner offers  
  - IRL benefits
     
---

## 👥 Team

We’re a team of builders passionate about Web3, transparency, and community-first fundraising.

- **David Nagy-Elek** — Smart Contracts & Protocol Integration  
- **Marian Stana** — Blockchain Enthusiast & Digital Marketing

> We're hacking this together at **ETHCluj 2025**, and open to collaborators or feedback — reach out!

---

## 🛠️ Developer Onboarding

### Requirements

- Node.js ≥ 18.x
- Hardhat ≥ 2.22
- Foundry (optional)
- Git & npm

### Getting Started

#### 1. Clone the Repository
```bash
git clone https://github.com/ttc915/Pay-It-Forward.git
cd Pay-It-Forward
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Configure Environment
Create a `.env` file in the root directory with the following variables:
```env
PRIVATE_KEY=your_wallet_private_key
RPC_URL=your_ethereum_node_url
```

#### 4. Using Remix Web IDE
You can easily interact with the smart contracts using Remix IDE:

#### 4. Using Remix Web IDE with remixd
You can connect your local project to Remix IDE using `remixd` for a seamless development experience:

1. Install `@remix-project/remixd` globally:
   ```bash
   npm install -g @remix-project/remixd
   ```

2. Start `remixd` in the root directory of your project:
   ```bash
   remixd -s . -u https://remix.ethereum.org
   ```

3. Go to [Remix IDE](https://remix.ethereum.org/)
4. In the File Explorer, click the "Open" button
5. Select "Connect to localhost" and ensure your local Hardhat node is running:
   ```bash
   npx hardhat node
   ```
6. Or, to connect directly to the repository:
   - Click on the "Workspaces" dropdown
   - Select "Clone from GitHub"
   - Enter the repository URL: `https://github.com/ttc915/Pay-It-Forward`
   - Press Enter to load the project

7. Compile the contracts:
   - Go to the "Solidity Compiler" tab
   - Select the appropriate compiler version (matching your `hardhat.config.js`)
   - Click "Compile"

8. Deploy and interact with contracts:
   - Go to the "Deploy & Run Transactions" tab
   - Select "Injected Provider" (e.g., MetaMask) or "Hardhat Provider" for local testing
   - Deploy contracts and interact with them using the UI

#### 5. Running Tests
```bash
# Run all tests
npx hardhat test

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Run coverage
npx hardhat coverage
```

#### 6. Local Development Network
Start a local Hardhat network:
```bash
npx hardhat node
```

In a separate terminal, deploy contracts to the local network:
```bash
npx hardhat run --network localhost scripts/deploy.js
```

#### 7. Verifying Contracts
To verify contracts on Etherscan:
```bash
npx hardhat verify --network <network> <contract_address> <constructor_arguments>
```

### Need Help?
If you encounter any issues or have questions, feel free to [open an issue](https://github.com/ttc915/Pay-It-Forward/issues)!
