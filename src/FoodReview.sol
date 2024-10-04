// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./VoucherNFT.sol"; // Import the ERC721 contract
import "./BadgeNFT.sol"; // Import the ERC1155 contract

contract FoodReview {
    address public owner;
    VoucherNFT public voucherContract;
    BadgeNFT public badgeContract;

    struct Restaurant {
        string name;
        string description;
        string location;
        string foodCategory;
        string image; // Field for storing the image URL
        uint256 expLevel;
        uint256 totalVotes;
        bool isLevelUp;
    }

    struct User {
        string username;
        bool hasVoted;
    }

    mapping(address => User) public users;
    mapping(uint256 => Restaurant) public restaurants;
    mapping(uint256 => string[]) public restaurantReviews;
    uint256 public restaurantCount;

    event Voted(address indexed user, uint256 indexed restaurantId);
    event RestaurantLeveledUp(uint256 indexed restaurantId, uint256 newLevel);
    event ReviewSubmitted(uint256 indexed restaurantId, string review);

    constructor(address _voucherAddress, address _badgeAddress) {
        owner = msg.sender;
        voucherContract = VoucherNFT(_voucherAddress); // ERC721 instance
        badgeContract = BadgeNFT(_badgeAddress); // ERC1155 instance
    }

    // Create a new restaurant with image
    function createRestaurant(
        string memory _name,
        string memory _description,
        string memory _location,
        string memory _foodCategory,
        string memory _image // Parameter for the image URL
    ) public {
        restaurantCount++;
        restaurants[restaurantCount] = Restaurant({
            name: _name,
            description: _description,
            location: _location,
            foodCategory: _foodCategory,
            image: _image, // Store the image URL on-chain
            expLevel: 1,
            totalVotes: 0,
            isLevelUp: false
        });
    }

    // Vote for a restaurant
    function voteRestaurant(uint256 _restaurantId) public {
        require(!users[msg.sender].hasVoted, "You have already voted");

        Restaurant storage restaurant = restaurants[_restaurantId];
        restaurant.totalVotes++;

        users[msg.sender].hasVoted = true;
        emit Voted(msg.sender, _restaurantId);

        // Level up the restaurant and mint badge if it reaches vote threshold
        if (restaurant.totalVotes == 3) {
            restaurant.expLevel++;
            restaurant.isLevelUp = true;
            badgeContract.mintBadge(msg.sender, 1); // Mint tier 1 badge
            emit RestaurantLeveledUp(_restaurantId, restaurant.expLevel);
        }
    }

    // Review a restaurant
    function reviewRestaurant(
        uint256 _restaurantId,
        string memory _review
    ) public {
        restaurantReviews[_restaurantId].push(_review);
        emit ReviewSubmitted(_restaurantId, _review);
    }

    // Mint voucher for users
    function rewardUserWithVoucher(
        address _user,
        string memory _voucherURI
    ) public {
        voucherContract.mintVoucher(_user, _voucherURI); // Mint voucher
    }

    // Retrieve restaurant details
    function getRestaurant(
        uint256 _restaurantId
    ) public view returns (Restaurant memory) {
        return restaurants[_restaurantId];
    }
}
