// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract BadgeNFT is ERC1155 {
    // Define constants for badge tiers
    uint256 public constant TIER_1 = 1;
    uint256 public constant TIER_2 = 2;
    uint256 public constant TIER_3 = 3;

    constructor() ERC1155("https://api.example.com/metadata/%7Bid%7D.json") {}

    // Function to mint a badge based on user's tier level
    function mintBadge(address recipient, uint256 tier) public {
        require(tier >= TIER_1 && tier <= TIER_3, "Invalid tier level");
        _mint(recipient, tier, 1, "");
    }

    // Function to check which badges the owner holds
    function checkBadges(address owner) public view returns (uint256[] memory) {
        // Initialize a dynamic array to store the badge tiers
        uint256 maxTiers = 3;
        uint256[] memory badgeTiers = new uint256[](maxTiers); // here must initialize badgeTiers array and possible tier is 1-3
        uint256 index = 0;

        // Check each tier and add to the result if the owner holds it
        if (balanceOf(owner, TIER_1) > 0) {
            badgeTiers[index] = TIER_1;
            index++;
        }
        if (balanceOf(owner, TIER_2) > 0) {
            badgeTiers[index] = TIER_2;
            index++;
        }
        if (balanceOf(owner, TIER_3) > 0) {
            badgeTiers[index] = TIER_3;
            index++;
        }

        // Create a new array with the exact size of held badges
        uint256[] memory heldBadges = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            heldBadges[i] = badgeTiers[i];
        }

        return heldBadges;
    }
}
