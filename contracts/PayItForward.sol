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

    // --- View initiatives for a project ---
    function getInitiativesOfProject(uint32 projectId) public view returns (uint32[] memory) {
        uint n = projectInitiatives[projectId].length;
        uint32[] memory ids = new uint32[](n);
        for (uint i = 0; i < n; i++) {
            ids[i] = projectInitiatives[projectId][i];
        }
        return ids;
    }

    // --- View projects for an owner ---
    function getProjectsOfOwner(address owner) public view returns (uint32[] memory) {
        uint32[] memory ids = new uint32[](ownerProjects[owner].length);
        for (uint i = 0; i < ownerProjects[owner].length; i++) {
            ids[i] = ownerProjects[owner][i];
        }
        return ids;
    }

    // Modifiers
    modifier onlyProjectOwner(uint32 projectId) {
        require(projects[projectId].owner == msg.sender, "You are not the owner of the project");
        _;
    }

    // --- Donate ---
    function donate(uint32 initiativeId, uint128 amount) external payable {
        Initiative storage ini = initiatives[initiativeId];
        require(!ini.fulfilled, "Already funded");
        require(amount > 0, "Zero donation");

        ini.donations[msg.sender] += amount;
        ini.collectedAmount += amount;
        if (ini.collectedAmount >= ini.goalAmount) {
            ini.fulfilled = true;
        }

        erc20Ron.safeTransferFrom(msg.sender, address(this), amount);
        rewardToken.mint(msg.sender, amount);
    }

    // --- Withdraw donation when initiative is not fulfilled by the donor ---
    function withdrawDonation(uint32 initiativeId) public payable {
        Initiative storage initiative = initiatives[initiativeId];
        uint128 amount = initiative.donations[msg.sender];
        require(amount > 0, "No donation found for this initiative");
        require(!initiative.fulfilled, "Initiative already fulfilled, use claim instead");
        
        initiative.donations[msg.sender] = 0;
        initiative.collectedAmount -= amount;
        erc20Ron.safeTransfer(msg.sender, amount);
    }

    // --- Claim donation when initiative is fulfilled by the project owner ---
    function claimDonation(uint32 initiativeId) public payable {
        Initiative storage initiative = initiatives[initiativeId];
        Project storage project = projects[initiative.projectId];
        
        require(msg.sender == project.owner, "Only project owner can claim donations");
        require(initiative.fulfilled, "Initiative is not yet fulfilled");
        
        uint amount = initiative.collectedAmount;
        require(amount > 0, "No funds to claim");
        
        initiative.collectedAmount = 0;
        erc20Ron.safeTransfer(msg.sender, amount);
    }
}
