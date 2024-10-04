// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract RestaurantReview {
    struct Restaurant {
        uint256 id;
        string name;
        mapping(address => bool) hasReviewed;
        Review[] reviews;
    }

    Restaurant[4] public restaurants;

    struct Review {
        address reviewer;
        string reviewText;
        string imageLink;
        int256 voteCount; // Can be negative, hence int256 is used
        uint256 timestamp;
    }

    struct User {
        uint256 level; // Level 1, 2, or 3
        uint256 exp;
    }

    mapping(address => User) public users;

    event ReviewSubmitted(
        uint256 indexed restaurantId,
        address indexed reviewer,
        string reviewText,
        string imageLink
    );
    event ReviewVoted(
        uint256 indexed restaurantId,
        uint256 indexed reviewIndex,
        address indexed voter,
        int256 newVoteCount
    );

    event UserLeveledUp(address indexed user, uint256 newLevel);

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

    // Function to submit a reviews for a restaurant
    function submitReview(
        uint256 _restaurantId,
        string memory _reviewText,
        string memory _imageLink
    ) public {
        require(
            _restaurantId >= 0 && _restaurantId <= 2,
            "Invalid restaurant ID"
        );
        Restaurant storage restaurant = restaurants[_restaurantId];

        // Check if user has reviewed before and if 5 minutes have passed
        for (uint256 i = 0; i < restaurant.reviews.length; i++) {
            if (restaurant.reviews[i].reviewer == msg.sender) {
                require(
                    block.timestamp >=
                        restaurant.reviews[i].timestamp + 5 minutes,
                    "You can only review again after 5 minutes"
                );
            }
        }

        // Create new review
        restaurant.reviews.push(
            Review({
                reviewer: msg.sender,
                reviewText: _reviewText,
                imageLink: _imageLink,
                voteCount: 0,
                timestamp: block.timestamp
            })
        );

        restaurant.hasReviewed[msg.sender] = true;

        emit ReviewSubmitted(
            _restaurantId,
            msg.sender,
            _reviewText,
            _imageLink
        );
    }

    // Function to vote on a review and update user's level and EXP
    function voteReview(
        uint256 _restaurantId,
        uint256 _reviewIndex,
        bool _isUpvote
    ) public {
        require(
            _restaurantId >= 0 && _restaurantId <= 3,
            "Invalid restaurant ID"
        );
        Restaurant storage restaurant = restaurants[_restaurantId];
        require(
            _reviewIndex < restaurant.reviews.length,
            "Invalid review index"
        );

        Review storage review = restaurant.reviews[_reviewIndex];
        require(
            review.reviewer != msg.sender,
            "Review owner cannot vote on their own review"
        );

        // Determine user influence level
        uint256 userLevel = users[msg.sender].level;

        // Default level to 1 if the user is not yet registered or has no level set
        if (userLevel == 0) {
            userLevel = 1;
        }

        // Calculate vote value based on user level
        int256 voteValue = int256(userLevel); // Level 1 = 1 point, Level 2 = 2 points, Level 3 = 3 points
        if (!_isUpvote) {
            voteValue = -voteValue;
        }

        // Update the review's vote count
        review.voteCount += voteValue;

        // Vote logic: update reviewer's experience points
        if (_isUpvote) {
            // Upvote logic: Increase experience points
            users[review.reviewer].exp += 1;
        } else {
            // Downvote logic: Decrease experience points
            require(review.voteCount >= 0, "Vote count cannot go below zero"); // Ensure vote count doesn't go below zero
            if (users[review.reviewer].exp > 0) {
                users[review.reviewer].exp -= 1;
            }

            // Check if the user is above level 1 before decreasing EXP
            if (
                users[review.reviewer].level > 1 &&
                users[review.reviewer].exp > 0
            ) {
                users[review.reviewer].exp -= 1; // Lose 1 more EXP for the reviewer on downvote
            }
        }

        // Check for level up for the reviewer after upvote/downvote
        if (users[review.reviewer].exp >= 10) {
            users[review.reviewer].level += 1; // Level up
            users[review.reviewer].exp = 0; // Reset EXP after leveling up
            emit UserLeveledUp(review.reviewer, users[review.reviewer].level);
        }

        // Emit the vote event with updated information
        emit ReviewVoted(
            _restaurantId,
            _reviewIndex,
            msg.sender,
            review.voteCount
        );
    }

    // Function to get restaurant reviews
    function getRestaurantReviews(
        uint256 _restaurantId
    ) public view returns (Review[] memory) {
        require(
            _restaurantId >= 0 && _restaurantId <= 2,
            "Invalid restaurant ID"
        );
        return restaurants[_restaurantId].reviews;
    }

    // Function to get all reviews for a restaurant including net votes
    function getAllReviewsForRestaurant(
        uint256 _restaurantId
    )
        public
        view
        returns (
            address[] memory reviewers,
            string[] memory reviewTexts,
            string[] memory imageLinks,
            int256[] memory voteCounts,
            uint256[] memory timestamps
        )
    {
        require(
            _restaurantId >= 0 && _restaurantId <= 3,
            "Invalid restaurant ID"
        );

        Restaurant storage restaurant = restaurants[_restaurantId];
        uint256 reviewCount = restaurant.reviews.length;

        // Initialize arrays to store data
        reviewers = new address[](reviewCount);
        reviewTexts = new string[](reviewCount);
        imageLinks = new string[](reviewCount);
        voteCounts = new int256[](reviewCount);
        timestamps = new uint256[](reviewCount);

        // Loop through all reviews and populate the arrays
        for (uint256 i = 0; i < reviewCount; i++) {
            Review storage review = restaurant.reviews[i];
            reviewers[i] = review.reviewer;
            reviewTexts[i] = review.reviewText;
            imageLinks[i] = review.imageLink;
            voteCounts[i] = review.voteCount;
            timestamps[i] = review.timestamp;
        }
    }

    // Function to set user level (for testing purpose, normally this should be restricted)
    function setUserLevel(address _user, uint256 _level) public {
        require(_level >= 1 && _level <= 3, "Level must be between 1 and 3");
        users[_user].level = _level;
    }

    // Retrieve user details
    function getUser(
        address _user
    ) public view returns (uint256 level, uint256 exp) {
        User storage user = users[_user];
        return (user.level, user.exp);
    }

    // Register a new user
    function registerUser() public {
        require(users[msg.sender].level == 0, "User already registered"); // Check if user is already registered

        users[msg.sender] = User({
            level: 1, // Start at level 1
            exp: 0 // Start with 0 EXP
        });
    }
}
