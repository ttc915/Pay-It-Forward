// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RONStablecoin is ERC20, Ownable {
    
    constructor() ERC20("RON Stablecoin", "vRON") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        // verify parameters
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");

        // actual mint
        _mint(to, amount);
    }
    
}

