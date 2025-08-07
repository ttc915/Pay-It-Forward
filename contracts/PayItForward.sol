// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PIFRewards} from "./PIFRewards.sol";
import {RONStablecoin} from "./RONStablecoin.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PayItForward {

    // State variables
    uint256 public projectCount;
    uint256 public initiativeCount;

    PIFRewards public rewardToken;
    IERC20 public erc20Ron;

    using SafeERC20 for IERC20;

    // Structures
    // Project structure
    struct Project {
        uint256 id;
        address owner;
        string name;
        string description;
    }

    // Initiative structure
    struct Initiative {
        uint256 id;
        uint256 projectId;
        string title;
        string description;
        uint256 goalAmount;
        uint256 collectedAmount;
        bool fulfilled;
        uint256 deadline;
        mapping(address => uint) donations;
    }


    // Mappings
    mapping(uint256 => Project) public projects;
    mapping(uint256 => Initiative) public initiatives;
    mapping(address => uint) public ownerProjectCount;
    mapping(uint256 => uint) public projectInitiativeCount;
    mapping(address => uint256[]) public ownerProjects;
    mapping(uint256 => uint256[]) public projectInitiatives;


    constructor() {
        rewardToken = new PIFRewards();
        erc20Ron = IERC20(address(new RONStablecoin()));
    }
    
    // --- Create project ---
    function createProject(string memory name, string memory description) public {

        // input validation
        require(bytes(name).length > 0, "Name is required");
        require(bytes(description).length > 0, "Description is required");

        uint256 newProjectId = projectCount++;
        projects[newProjectId] = Project(newProjectId, msg.sender, name, description);
        
        // Save the project for owner
        ownerProjects[msg.sender].push(newProjectId);
        ownerProjectCount[msg.sender]++;
    }

    // --- Create initiative ---
    function createInitiative(uint projectId, string memory title, string memory description, uint goalAmount) public onlyProjectOwner(projectId) {
        uint deadline = block.timestamp + 30 days;

        // Initialize the new initiative by setting each field individually
        Initiative storage newInitiative = initiatives[initiativeCount];
        newInitiative.id = initiativeCount;
        newInitiative.projectId = projectId;
        newInitiative.title = title;
        newInitiative.description = description;
        newInitiative.goalAmount = goalAmount;
        newInitiative.collectedAmount = 0;
        newInitiative.fulfilled = false;
        newInitiative.deadline = deadline;

        // Save the initiative for the project
        uint idx = projectInitiativeCount[projectId];
        initiativeCount++;
        projectInitiatives[projectId][idx] = initiativeCount;
        projectInitiativeCount[projectId]++;
    }

    // --- View initiatives for a project ---
    function getInitiativesOfProject(uint projectId) public view returns (uint[] memory) {
        uint n = projectInitiativeCount[projectId];
        uint[] memory ids = new uint[](n);
        for (uint i = 0; i < n; i++) {
            ids[i] = projectInitiatives[projectId][i];
        }
        return ids;
    }

    // --- View projects for an owner ---
    function getProjectsOfOwner(address owner) public view returns (uint[] memory) {
        uint n = ownerProjectCount[owner];
        uint[] memory ids = new uint[](n);
        for (uint i = 0; i < n; i++) {
            ids[i] = ownerProjects[owner][i];
        }
        return ids;
    }

    // Modifiers
    modifier onlyProjectOwner(uint projectId) {
        require(projects[projectId].owner == msg.sender, "You are not the owner of the project");
        _;
    }

    // --- Donate ---
    function donate(uint initiativeId, uint amount) external payable {
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
    function withdrawDonation(uint initiativeId) public payable {
        Initiative storage initiative = initiatives[initiativeId];
        uint amount = initiative.donations[msg.sender];
        require(amount > 0, "No donation found for this initiative");
        require(!initiative.fulfilled, "Initiative already fulfilled, use claim instead");
        
        initiative.donations[msg.sender] = 0;
        initiative.collectedAmount -= amount;
        erc20Ron.safeTransfer(msg.sender, amount);
    }

    // --- Claim donation when initiative is fulfilled by the project owner ---
    function claimDonation(uint initiativeId) public payable {
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
