// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PIFRewards
 * @dev ERC20 token contract for the Pay It Forward reward system.
 * This token is used to reward users who participate in the donation ecosystem.
 * Features:
 * - Mintable by authorized rewarder address
 * - Transferable like any standard ERC20 token
 * - Admin-controlled rewarder management
 */
contract PIFRewards is ERC20, Ownable {
    address public rewarder;

    event RewardMinted(address indexed to, uint256 amount);

    constructor() ERC20("Pay it Forward Rewards", "PIF") Ownable(msg.sender) {
        rewarder = msg.sender;
    }

    /**
     * @notice Mints reward tokens to a donor's address
     * @param to The donor's address that will receive the reward tokens
     * @param amount The amount of reward tokens to mint
     */
    function reward(address to, uint256 amount) external {
        require(msg.sender == rewarder, "PIF: Not authorized");
        require(to != address(0), "PIF: Invalid address");
        require(amount > 0, "PIF: Invalid amount");

        _mint(to, amount);
        emit RewardMinted(to, amount);
    }

    /**
     * @notice Updates the rewarder address
     * @param _rewarder The new rewarder address
     */
    function setRewarder(address _rewarder) external onlyOwner {
        require(_rewarder != address(0), "PIF: Invalid address");
        rewarder = _rewarder;
    }
}
