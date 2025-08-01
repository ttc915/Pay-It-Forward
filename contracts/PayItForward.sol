// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PIFRewards} from "./PIFRewards.sol";
import {RONStablecoin} from "./RONStablecoin.sol";

contract PayItForward{

    // State variables
    uint public projectCount;
    uint public initiativeCount;

    PIFRewards public rewardToken;
    RONStablecoin public erc20Ron;

    // Structures
    struct Project {
        uint id;
        address owner;
        string name;
        string description;
    }

    struct Initiative {
        uint id;
        uint projectId;
        string title;
        string description;
        uint goalAmount;
        uint collectedAmount;
        bool fulfilled;
        uint256 deadline;
        mapping(address => uint) donations;
    }


    // Mappings
    mapping(uint256 => Project) public projects;
    mapping(uint256 => Initiative) public initiatives;
    mapping(address => uint) public ownerProjectCount;
    mapping(uint256 => uint) public projectInitiativeCount;
    mapping(uint => mapping(address => uint)) public initiativeDonations;
    mapping(address => uint256[]) public ownerProjects;
    mapping(uint256 => uint256[]) public projectInitiatives;


    constructor() {
        rewardToken = new PIFRewards();
        erc20Ron = new RONStablecoin();
    }
    
    // --- Create project ---
    function createProject(string memory name, string memory description) public {
        projectCount++;
        projects[projectCount] = Project(projectCount, msg.sender, name, description);

        // Save the project for owner
        uint idx = ownerProjectCount[msg.sender];
        ownerProjects[msg.sender][idx] = projectCount;
        ownerProjectCount[msg.sender]++;
    }

    // --- Create initiative ---
    function createInitiative(uint projectId, string memory title, string memory description, uint goalAmount) public {
        require(projects[projectId].owner == msg.sender, "You are not the owner of the project");

        initiativeCount++;
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

        // --- Donate ---
    function donate(uint initiativeId, uint amount) external {
        Initiative storage ini = initiatives[initiativeId];
        require(!ini.fulfilled, "Already funded");
        require(amount > 0, "Zero donation");

        ini.collectedAmount += amount;
        if (ini.collectedAmount >= ini.goalAmount) {
            ini.fulfilled = true;
        }

        bool transferSuccess = erc20Ron.transferFrom(msg.sender, address(this), amount);
        require(transferSuccess, "Token transfer failed");

        rewardToken.mint(msg.sender, amount);
    }

    // --- Withdraw donation ---
    function withdrawDonation(uint initiativeId) public {
        Initiative storage ini = initiatives[initiativeId];
        require(initiativeDonations[initiativeId][msg.sender] > 0, "You don't have a donation for this initiative");
        uint amount = initiativeDonations[initiativeId][msg.sender];
        initiativeDonations[initiativeId][msg.sender] = 0;
        bool transferSuccess = erc20Ron.transfer(msg.sender, amount);
        require(transferSuccess, "Token transfer failed");
    }

    function claimDonation(uint initiativeId) public {
        Initiative storage ini = initiatives[initiativeId];
        require(ini.fulfilled, "Initiative is not funded");
        uint amount = initiativeDonations[initiativeId][msg.sender];
        
        initiativeDonations[initiativeId][msg.sender] = 0;
        bool transferSuccess = erc20Ron.transfer(msg.sender, amount);
        require(transferSuccess, "Token transfer failed");
    }


}
