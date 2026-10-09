// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {
    address public owner;
    string public itemName;
    uint256 public minimumBid;
    uint256 public auctionEndTime;

    bool public ended;
    bool public cancelled;

    address public highestBidder;
    uint256 public highestBid;

    address public winner;
    uint256 public winningBid;
    uint256 public ownerBalance;

    address[] private bidders;
    mapping(address => bool) private isBidder;
    mapping(address => uint256) public bids;
    mapping(address => uint256) public refunds;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event AuctionCancelled();
    event RefundWithdrawn(address indexed bidder, uint256 amount);
    event OwnerWithdrawal(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier auctionIsActive() {
        require(!ended, "Auction already ended");
        require(!cancelled, "Auction was cancelled");
        require(block.timestamp < auctionEndTime, "Auction time is over");
        _;
    }

    constructor(
        string memory _itemName,
        uint256 _minimumBid,
        uint256 _durationInSeconds
    ) {
        require(bytes(_itemName).length > 0, "Item name cannot be empty");
        require(_minimumBid > 0, "Minimum bid must be greater than zero");
        require(_durationInSeconds > 0, "Duration must be greater than zero");

        owner = msg.sender;
        itemName = _itemName;
        minimumBid = _minimumBid;
        auctionEndTime = block.timestamp + _durationInSeconds;
    }

    function bid() external payable auctionIsActive {
        require(msg.sender != owner, "Owner cannot bid");
        require(msg.value > 0, "Bid value must be greater than zero");

        uint256 totalBid = bids[msg.sender] + msg.value;

        require(totalBid >= minimumBid, "Bid is lower than minimum bid");
        require(totalBid > highestBid, "Bid must be higher than current highest bid");

        if (!isBidder[msg.sender]) {
            bidders.push(msg.sender);
            isBidder[msg.sender] = true;
        }

        bids[msg.sender] = totalBid;
        highestBidder = msg.sender;
        highestBid = totalBid;

        emit NewBid(msg.sender, totalBid);
    }

    function endAuction() external {
        require(!ended, "Auction already ended");
        require(!cancelled, "Auction was cancelled");
        require(
            msg.sender == owner || block.timestamp >= auctionEndTime,
            "Only owner can end auction before time"
        );

        ended = true;
        winner = highestBidder;
        winningBid = highestBid;

        for (uint256 i = 0; i < bidders.length; i++) {
            address bidderAddress = bidders[i];
            uint256 bidderBid = bids[bidderAddress];

            if (bidderBid == 0) {
                continue;
            }

            bids[bidderAddress] = 0;

            if (bidderAddress == winner) {
                ownerBalance += bidderBid;
            } else {
                refunds[bidderAddress] += bidderBid;
            }
        }

        emit AuctionEnded(winner, winningBid);
    }

    function cancelAuction() external onlyOwner {
        require(!ended, "Auction already ended");
        require(!cancelled, "Auction already cancelled");
        require(block.timestamp < auctionEndTime, "Auction time is over");

        cancelled = true;

        for (uint256 i = 0; i < bidders.length; i++) {
            address bidderAddress = bidders[i];
            uint256 bidderBid = bids[bidderAddress];

            if (bidderBid == 0) {
                continue;
            }

            bids[bidderAddress] = 0;
            refunds[bidderAddress] += bidderBid;
        }

        emit AuctionCancelled();
    }

    function withdrawRefund() external {
        uint256 amount = refunds[msg.sender];
        require(amount > 0, "No refund available");

        refunds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund transfer failed");

        emit RefundWithdrawn(msg.sender, amount);
    }

    function withdrawOwnerBalance() external onlyOwner {
        require(ended, "Auction is not ended");
        require(!cancelled, "Auction was cancelled");
        require(ownerBalance > 0, "No owner balance available");

        uint256 amount = ownerBalance;
        ownerBalance = 0;

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Owner transfer failed");

        emit OwnerWithdrawal(owner, amount);
    }

    function getBiddersCount() external view returns (uint256) {
        return bidders.length;
    }

    function getAuctionInfo()
        external
        view
        returns (
            string memory name,
            uint256 minBid,
            uint256 endTime,
            bool isEnded,
            bool isCancelled,
            address currentHighestBidder,
            uint256 currentHighestBid,
            address auctionWinner,
            uint256 auctionWinningBid
        )
    {
        return (
            itemName,
            minimumBid,
            auctionEndTime,
            ended,
            cancelled,
            highestBidder,
            highestBid,
            winner,
            winningBid
        );
    }
}
