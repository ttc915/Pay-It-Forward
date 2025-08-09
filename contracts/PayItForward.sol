// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PIFRewards} from "./PIFRewards.sol";
import {RONStablecoin} from "./RONStablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PayItForward {
    using SafeERC20 for IERC20;

    // State variables
    RONStablecoin public immutable ronToken;
    PIFRewards public immutable rewardToken;

    // Project and initiative tracking
    uint32 public projectCount;
    uint32 public initiativeCount;

    // Constants
    uint64 public constant DEFAULT_FUNDING_PERIOD = 30 days;
    uint128 public constant TOKEN_REWARD_RATE = 100; // 1 RON = 100 PIF tokens

    // Structures
    struct Project {
        address owner;
        uint32 id;
        string title;
        string description;
    }

    struct Initiative {
        uint32 id;
        uint32 projectId;
        bool isFulfilled;
        uint256 endTime;
        uint128 fundingTarget;
        uint128 totalRaised;
        string title;
        string description;
        mapping(address => uint128) donationsByAddress;
    }

    // Mappings
    mapping(uint32 => Project) public projects;
    mapping(uint32 => Initiative) public initiatives;
    mapping(address => uint32[]) public ownerProjects;
    mapping(uint32 => uint32[]) public projectInitiatives;

    // Events
    event ProjectCreated(uint32 indexed projectId, address indexed owner, string title);
    event InitiativeCreated(uint32 indexed initiativeId, uint32 indexed projectId, string title, uint128 fundingTarget);
    event DonationReceived(uint32 indexed initiativeId, address indexed donor, uint128 amount);
    event FundsClaimed(uint32 indexed initiativeId, address indexed recipient, uint128 amount);

    constructor() {
        // Deploy tokens
        ronToken = new RONStablecoin();
        rewardToken = new PIFRewards();

        // Set rewarder to this contract
        rewardToken.setRewarder(address(this));
    }

    // --- Project Management ---
    function createProject(string calldata title, string calldata description) external {
        require(bytes(title).length > 0, "Title required");
        require(bytes(description).length > 0, "Description required");

        uint32 newProjectId = projectCount++;
        projects[newProjectId] = Project({owner: msg.sender, id: newProjectId, title: title, description: description});

        ownerProjects[msg.sender].push(newProjectId);
        emit ProjectCreated(newProjectId, msg.sender, title);
    }

    // --- Initiative Management ---
    function createInitiative(
        uint32 projectId,
        string calldata title,
        string calldata description,
        uint128 fundingTarget
    ) external onlyProjectOwner(projectId) {
        require(bytes(title).length > 0, "Title required");
        require(bytes(description).length > 0, "Description required");
        require(fundingTarget > 0, "Funding target must be > 0");
        require(projects[projectId].owner != address(0), "Project not found");

        uint32 newInitiativeId = initiativeCount++;

        Initiative storage newInitiative = initiatives[newInitiativeId];
        newInitiative.id = newInitiativeId;
        newInitiative.projectId = projectId;
        newInitiative.title = title;
        newInitiative.description = description;
        newInitiative.fundingTarget = fundingTarget;
        newInitiative.endTime = block.timestamp + DEFAULT_FUNDING_PERIOD;

        projectInitiatives[projectId].push(newInitiativeId);
        emit InitiativeCreated(newInitiativeId, projectId, title, fundingTarget);
    }

    // --- Donation ---
    function donate(uint32 initiativeId, uint128 amount) external {
        Initiative storage initiative = initiatives[initiativeId];
        require(initiative.id == initiativeId, "Initiative not found");
        require(block.timestamp <= initiative.endTime, "Initiative expired");
        require(!initiative.isFulfilled, "Goal already reached");
        require(amount > 0, "Amount must be > 0");

        // Transfer RON tokens from donor to this contract
        IERC20(address(ronToken)).safeTransferFrom(msg.sender, address(this), amount);

        // Update donation tracking
        initiative.donationsByAddress[msg.sender] += amount;
        initiative.totalRaised += amount;

        // Mint PIF rewards (1 RON = 100 PIF tokens)
        uint256 rewardAmount = amount * TOKEN_REWARD_RATE;
        rewardToken.reward(msg.sender, rewardAmount);

        // Check if goal is reached
        if (initiative.totalRaised >= initiative.fundingTarget) {
            initiative.isFulfilled = true;
        }

        emit DonationReceived(initiativeId, msg.sender, amount);
    }

    // --- Fund Withdrawal ---
    function claimFunds(uint32 initiativeId) external {
        Initiative storage initiative = initiatives[initiativeId];
        require(initiative.id == initiativeId, "Initiative not found");
        require(initiative.isFulfilled, "Goal not reached");

        Project memory project = projects[initiative.projectId];
        require(msg.sender == project.owner, "Not project owner");

        uint128 amount = initiative.totalRaised;
        initiative.totalRaised = 0;

        // Transfer RON tokens to project owner
        IERC20(address(ronToken)).safeTransfer(project.owner, amount);

        emit FundsClaimed(initiativeId, project.owner, amount);
    }

    // --- View Functions ---
    function getInitiative(
        uint32 initiativeId
    )
        external
        view
        returns (
            uint32 id,
            uint32 projectId,
            bool isFulfilled,
            uint256 endTime,
            uint128 fundingTarget,
            uint128 totalRaised,
            string memory title,
            string memory description
        )
    {
        Initiative storage initiative = initiatives[initiativeId];
        return (
            initiative.id,
            initiative.projectId,
            initiative.isFulfilled,
            initiative.endTime,
            initiative.fundingTarget,
            initiative.totalRaised,
            initiative.title,
            initiative.description
        );
    }

    function getDonorContribution(uint32 initiativeId, address donor) external view returns (uint128) {
        return initiatives[initiativeId].donationsByAddress[donor];
    }

    // --- Modifiers ---
    modifier onlyProjectOwner(uint32 projectId) {
        require(projects[projectId].owner == msg.sender, "Not project owner");
        _;
    }
}
