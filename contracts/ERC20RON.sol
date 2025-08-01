// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20RON is ERC20 {
    constructor() ERC20("RON", "RON") {
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
    
}

