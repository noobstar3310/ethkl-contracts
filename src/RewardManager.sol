// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./RestaurantReview.sol";
import "./BadgeNFT.sol";
import "./VoucherNFT.sol";

contract RewardManager {
    RestaurantReview public restaurantReview;
    BadgeNFT public badgeNFT;
    VoucherNFT public voucherNFT;

    constructor(
        address _restaurantReviewAddress,
        address _badgeNFTAddress,
        address _voucherNFTAddress
    ) {
        restaurantReview = RestaurantReview(_restaurantReviewAddress);
        badgeNFT = BadgeNFT(_badgeNFTAddress);
        voucherNFT = VoucherNFT(_voucherNFTAddress);
    }

    // Function to mint a badge based on user's tier level
    function mintBadge(uint256 tier) public {
        // Fetch user's level from RestaurantReview contract
        (uint256 userLevel, ) = restaurantReview.getUser(msg.sender);

        // Check if user meets level requirement for each badge tier
        if (tier == badgeNFT.TIER_1()) {
            require(
                userLevel >= 2,
                "Must be level 2 or higher to mint Tier 1 badge"
            );
        } else if (tier == badgeNFT.TIER_2()) {
            require(
                userLevel >= 3,
                "Must be level 3 or higher to mint Tier 2 badge"
            );
        } else if (tier == badgeNFT.TIER_3()) {
            require(
                userLevel >= 4,
                "Must be level 4 or higher to mint Tier 3 badge"
            );
        } else {
            revert("Invalid badge tier");
        }

        // Mint the badge
        badgeNFT.mintBadge(msg.sender, tier);
    }

    // Function to mint a voucher (ERC721) only if user has a Tier 1 badge
    function mintVoucher() public {
        // Check if the user holds a Tier 1 badge
        require(
            badgeNFT.balanceOf(msg.sender, badgeNFT.TIER_1()) > 0,
            "Too low level, can't mint voucher"
        );

        // Mint the voucher
        voucherNFT.mintVoucher(msg.sender);
    }

    function burnVoucher(uint256 voucherId) public {
        // Ensure the user owns the voucher before transferring
        require(
            voucherNFT.ownerOf(voucherId) == msg.sender,
            "Only voucher owner can burn this voucher"
        );

        // Transfer the voucher to the burn address (0x0)
        voucherNFT.transferFrom(msg.sender, address(0), voucherId);
    }
}
