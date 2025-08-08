// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PIFRewards} from "./PIFRewards.sol";
import {RONStablecoin} from "./RONStablecoin.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract PayItForward {

    uint64 public constant INITIATIVE_DURATION = 30 days;

    // State variables
    uint32 public projectCount;
    uint32 public initiativeCount;

    PIFRewards public rewardToken;
    IERC20 public erc20Ron;

    using SafeERC20 for IERC20;

    // Structures
    // Project structure
    struct Project {
        address owner;
        uint32 id;
        string name;
        string description;
    }

    // Initiative structure
    struct Initiative {
        uint32 id;
        uint32 projectId;
        bool fulfilled;
        uint256 deadline;
        uint128 goalAmount;
        uint128 collectedAmount;
        string title;
        string description;
        mapping(address => uint128) donations;
    }

    // Mappings
    mapping(uint32 => Project) public projects;
    mapping(uint32 => Initiative) public initiatives;
    mapping(address => uint32[]) public ownerProjects;
    mapping(uint32 => uint32[]) public projectInitiatives;

    constructor() {
        rewardToken = new PIFRewards();
        erc20Ron = IERC20(address(new RONStablecoin()));
    }
    
    // --- Create project ---
    function createProject(string memory name, string memory description) public {

        // input validation
        require(bytes(name).length > 0, "Name is required");
        require(bytes(description).length > 0, "Description is required");

        uint32 newProjectId = projectCount++;
        projects[newProjectId] = Project(msg.sender, newProjectId, name, description);
        
        // Save the project for owner
        ownerProjects[msg.sender].push(newProjectId);
    }

    // --- Create initiative ---
    function createInitiative(uint32 projectId, string memory title, string memory description, uint128 goalAmount) public onlyProjectOwner(projectId) {

        Project memory project = projects[projectId];
        require(project.owner != address(0), "Project does not exist");

        // Input validation
        require(bytes(title).length > 0, "Title is required");
        require(bytes(description).length > 0, "Description is required");
        require(goalAmount > 0, "Goal amount must be greater than 0");

        uint32 newInitiativeId = initiativeCount++;
        uint256 deadline = block.timestamp + INITIATIVE_DURATION;

        // Initialize the new initiative
        Initiative storage newInitiative = initiatives[newInitiativeId];
        newInitiative.id = newInitiativeId;
        newInitiative.projectId = projectId;
        newInitiative.title = title;
        newInitiative.description = description;
        newInitiative.goalAmount = goalAmount;
        // No need to initialize to 0 as it's the default
        // newInitiative.collectedAmount = 0;
        // newInitiative.fulfilled = false;
        newInitiative.deadline = deadline;

        // Add to project's initiatives
        projectInitiatives[projectId].push(newInitiativeId);
    }

    // Modifiers
    modifier onlyProjectOwner(uint32 projectId) {
        require(projects[projectId].owner == msg.sender, "You are not the owner of the project");
        _;
    }

    // --- Donate ---
    function donate(uint32 initiativeId, uint128 amount) public {
        require(initiativeId < initiativeCount, "Initiative not found");
        Initiative storage ini = initiatives[initiativeId];
        require(ini.goalAmount > 0, "Uninitialized initiative");
        require(block.timestamp <= ini.deadline, "Past deadline");
        require(amount > 0, "Zero donation");
        require(!ini.fulfilled, "Already funded");

        // Transfer tokens from donor to contract
        erc20Ron.safeTransferFrom(msg.sender, address(this), amount);

        // Update donor record and totals
        ini.donations[msg.sender] += amount;
        ini.collectedAmount += amount;

        // Mark as fulfilled if goal reached
        if (ini.collectedAmount >= ini.goalAmount) {
            ini.fulfilled = true;
        }

        // Mint reward tokens to donor
        rewardToken.mint(msg.sender, amount);
    }

    // =========================
    // TEST-ONLY helper methods
    // Remove before production
    // =========================
    function testMintRon(address to, uint256 amount) external {
        // This contract is the owner of RONStablecoin, so it can mint
        RONStablecoin(address(erc20Ron)).mint(to, amount);
    }
}
