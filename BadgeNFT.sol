// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract BadgeNFT is ERC1155 {
    // Define constants for badge tiers
    uint256 public constant TIER_1 = 1;
    uint256 public constant TIER_2 = 2;
    uint256 public constant TIER_3 = 3;

    struct BadgeMetadata {
        string name;
        string description;
        string image;
    }

    // Mapping from token ID to its metadata
    mapping(uint256 => BadgeMetadata) public badgeMetadata;

    constructor() ERC1155("") {}

    // Function to mint a badge with metadata
    function mintBadge(
        address recipient,
        uint256 tier,
        string memory name,
        string memory description,
        string memory image
    ) public {
        require(tier >= TIER_1 && tier <= TIER_3, "Invalid tier level");

        // Store metadata on-chain
        badgeMetadata[tier] = BadgeMetadata({
            name: name,
            description: description,
            image: image
        });

        // Mint the badge
        _mint(recipient, tier, 1, "");
    }

    // Function to check which badges the owner holds
    function checkBadges(address owner) public view returns (uint256[] memory) {
        // Initialize a dynamic array to store the badge tiers
        uint256 maxTiers = 3;
        uint256[] memory badgeTiers = new uint256[](maxTiers); // possible tiers 1-3
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

    // Function to retrieve all badges owned by an address along with their metadata
    function getBadgesOfOwner(address owner) public view returns (BadgeMetadata[] memory) {
        uint256[] memory ownedTiers = checkBadges(owner); // Call checkBadges to get the badge tiers
        uint256 numBadges = ownedTiers.length;
        
        BadgeMetadata[] memory ownedMetadata = new BadgeMetadata[](numBadges); // Initialize metadata array

        // Loop through the owned tiers and fetch the metadata
        for (uint256 i = 0; i < numBadges; i++) {
            uint256 tier = ownedTiers[i];
            ownedMetadata[i] = badgeMetadata[tier]; // Get metadata for the current tier
        }

        return ownedMetadata;
    }
}
