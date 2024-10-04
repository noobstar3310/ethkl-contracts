// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RestaurantReview {
    // Struct to store a reviews
    struct Review {
        address reviewer; // The address of the reviewer
        string reviewText; // The actual reviews text
        int256 votes; // Net votes (upvotes - downvotes)
        mapping(address => bool) voters; // Track if a user has voted on this reviews
    }

    // Struct to store Restaurant details
    struct Restaurant {
        uint256 id;
        string name;
        mapping(address => bool) hasReviewed; // Tracks if an address has reviewed this restaurant
        Review[] reviews; // Array of reviews for this restaurant
    }

    // Fixed list of restaurants
    Restaurant[4] public restaurants;

    // Constructor to initialize four restaurants with fixed names
    constructor() {
        restaurants[0].id = 0;
        restaurants[0].name = "Bistro Delight";

        restaurants[1].id = 1;
        restaurants[1].name = "Ocean View Dining";

        restaurants[2].id = 2;
        restaurants[2].name = "Mountain Grill";

        restaurants[3].id = 3;
        restaurants[3].name = "Urban Tastes";
    }

    // Modifier to check if the user has already reviewed a restaurant
    modifier hasNotReviewed(uint256 restaurantId) {
        require(
            !restaurants[restaurantId].hasReviewed[msg.sender],
            "You have already reviewed this restaurant."
        );
        _;
    }

    // Modifier to check if the user is not the review owner
    modifier isNotReviewOwner(address reviewer) {
        require(msg.sender != reviewer, "You cannot vote on your own review.");
        _;
    }

    // Function for a user to add a reviews to a restaurant
    function addReview(
        uint256 restaurantId,
        string memory reviewText
    ) external hasNotReviewed(restaurantId) {
        require(restaurantId < 4, "Invalid restaurant ID.");

        // Create a new reviews instance
        Review storage newReview = restaurants[restaurantId].reviews.push();
        newReview.reviewer = msg.sender;
        newReview.reviewText = reviewText;
        newReview.votes = 0;

        // Mark that the user has reviewed this restaurant
        restaurants[restaurantId].hasReviewed[msg.sender] = true;
    }

    // Function for a user to upvote or downvote a reviews
    function voteOnReview(
        uint256 restaurantId,
        uint256 reviewIndex,
        bool upvote
    ) external {
        require(restaurantId < 4, "Invalid restaurant ID.");
        require(
            reviewIndex < restaurants[restaurantId].reviews.length,
            "Invalid review index."
        );

        Review storage review = restaurants[restaurantId].reviews[reviewIndex];

        // Ensure the voter is not the reviews owner
        require(
            msg.sender != review.reviewer,
            "You cannot vote on your own review."
        );

        // Ensure the user hasn't voted before
        require(
            !review.voters[msg.sender],
            "You have already voted on this review."
        );

        // Record the user's vote
        review.voters[msg.sender] = true;

        // Update the vote count
        if (upvote) {
            review.votes += 1;
        } else {
            review.votes -= 1;
        }
    }

    // Function to get all reviews for a restaurant
    function getReviews(
        uint256 restaurantId
    )
        external
        view
        returns (string[] memory, address[] memory, int256[] memory)
    {
        require(restaurantId < 4, "Invalid restaurant ID.");
        uint256 reviewCount = restaurants[restaurantId].reviews.length;

        // Arrays to store review data
        string[] memory reviewTexts = new string[](reviewCount);
        address[] memory reviewers = new address[](reviewCount);
        int256[] memory voteCounts = new int256[](reviewCount);

        // Populate the arrays with the review data
        for (uint256 i = 0; i < reviewCount; i++) {
            Review storage review = restaurants[restaurantId].reviews[i];
            reviewTexts[i] = review.reviewText;
            reviewers[i] = review.reviewer;
            voteCounts[i] = review.votes;
        }

        return (reviewTexts, reviewers, voteCounts);
    }

    // Function to get restaurant details by ID
    function getRestaurant(
        uint256 restaurantId
    ) external view returns (string memory name, uint256 reviewCount) {
        require(restaurantId < 4, "Invalid restaurant ID.");
        Restaurant storage restaurant = restaurants[restaurantId];
        return (restaurant.name, restaurant.reviews.length);
    }
}
