// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Auction {
    
    address payable public owner;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturns;
    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime) {
        owner = payable(msg.sender);
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(
            block.timestamp <= auctionEndTime,
            "Auction already ended."
        );
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(msg.sender == owner, "You are not the auction owner.");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        owner.transfer(highestBid);
    }
}
