// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title RONStablecoin
 * @dev A virtual stablecoin for testing purposes
 * - 18 decimal places (standard for most tokens)
 * - Public minting for testing (remove in production)
 * - Basic burn functionality
 * - No access control - for testing only
 */
contract RONStablecoin is ERC20 {
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20("Virtual RON Stablecoin", "vRON") {
        // No initial supply - tokens must be minted explicitly
    }

    /**
     * @notice Mints new tokens to the specified address
     * @dev Public for testing purposes - add access control in production
     * @param to The address that will receive the tokens
     * @param amount The amount of tokens to mint (in wei)
     */
    function mint(address to, uint256 amount) external {
        require(to != address(0), "vRON: Cannot mint to zero address");
        require(amount > 0, "vRON: Amount must be greater than zero");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @notice Burns tokens from the sender's balance
     * @param amount The amount of tokens to burn (in wei)
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}
