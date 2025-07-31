// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {RewardToken} from "./RewardToken.sol";
import {ERC20RON} from "./ERC20RON.sol";

contract PayItForward{

    uint public projectCount;
    uint public initiativeCount;

    // mapping: owner => (index => projectId)
    mapping(address => mapping(uint => uint)) public ownerProjects;
    mapping(address => uint) public ownerProjectCount;

    // mapping: projectId => (index => initiativeId)
    mapping(uint => mapping(uint => uint)) public projectInitiatives;
    mapping(uint => uint) public projectInitiativeCount;

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

    mapping(uint => Project) public projects;
    mapping(uint => Initiative) public initiatives;

    RewardToken public rewardToken;
    ERC20RON public erc20Ron;

    constructor() {
        rewardToken = new RewardToken();
        erc20Ron = new ERC20RON();
    }

    // --- Withdraw donation ---
    function withdrawDonation(uint initiativeId) public {
        Initiative storage ini = initiatives[initiativeId];
        require(ini.donations[msg.sender] > 0, "You don't have a donation for this initiative");
        uint amount = ini.donations[msg.sender];
        ini.donations[msg.sender] = 0;
        erc20Ron.transfer(msg.sender, amount);
    }

    // --- Create project ---
    function createProject(string memory name, string memory type_, string memory description) public {
        projectCount++;
        projects[projectCount] = Project(projectCount, msg.sender, name, description);

        // Save the project for owner
        uint idx = ownerProjectCount[msg.sender];
        ownerProjects[msg.sender][idx] = projectCount;
        ownerProjectCount[msg.sender]++;
    }

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

    // --- Donate ---
    function donate(uint initiativeId, uint amount) external {
        Initiative storage ini = initiatives[initiativeId];
        require(!ini.fulfilled, "Already funded");
        require(amount > 0, "Zero donation");

        ini.collectedAmount += amount;
        if (ini.collectedAmount >= ini.goalAmount) {
            ini.fulfilled = true;
        }

        erc20Ron.transferFrom(msg.sender, address(this), amount);

        rewardToken.mint(msg.sender, amount);
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

    function claimonation(uint initiativeId) public {
        Initiative storage ini = initiatives[initiativeId];
        require(ini.fulfilled, "Initiative is not funded");
        ini.donations[msg.sender] = 0;
        erc20Ron.transfer(msg.sender, ini.donations[msg.sender]);
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
}
