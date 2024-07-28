# Auction Smart Contract

## Introduction to the Contract

This smart contract is an implementation of a simple auction system on the Ethereum blockchain. It allows users to bid on an item within a specified bidding time. The contract keeps track of the highest bid and bidder, enables users to withdraw their bids if they are outbid, and allows the owner to end the auction and collect the highest bid amount.

## Core Function Explanation

### Variables

- `owner`: The address of the person who deployed the contract and owns the auction.
- `auctionEndTime`: The timestamp indicating when the auction ends.
- `highestBidder`: The address of the current highest bidder.
- `highestBid`: The highest bid amount in the auction.
- `pendingReturns`: A mapping of addresses to amounts that need to be refunded to bidders who were outbid.
- `ended`: A boolean flag indicating if the auction has ended.
### Functions

- `bid()`: Allows users to place bids. Ensures the auction is still running and the bid is higher than the current highest bid. Refunds the previous highest bidder.
- `withdraw()`: Allows users to withdraw their funds if they were outbid.
- `auctionEnd()`: Allows the owner to end the auction, marking it as ended and transferring the highest bid amount to the owner's address.

## Contract Explanation

```solidity
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
```

### Constructor

The constructor takes a single parameter `_biddingTime`, which sets the duration of the auction. It initializes the `owner` to the address that deploys the contract and calculates the `auctionEndTime` by adding `_biddingTime` to the current block timestamp.

### `bid` Function

The `bid` function allows users to place bids on the auction item. It has the following requirements:
- The current timestamp must be less than or equal to `auctionEndTime`.
- The bid amount must be higher than the current highest bid.

If the bid is valid, the function updates the `highestBid` and `highestBidder`, and refunds the previous highest bidder by adding their bid amount to `pendingReturns`.

### `withdraw` Function

The `withdraw` function allows users to withdraw their bids if they were outbid. It checks if the user has a pending return, resets their pending return to zero, and sends the amount back to the user. If the transfer fails, it reverts the pending return.

### `auctionEnd` Function

The `auctionEnd` function can only be called by the owner of the contract. It has the following requirements:
- The current timestamp must be greater than or equal to `auctionEndTime`.
- The auction must not have ended already.

When called, it marks the auction as ended, emits the `AuctionEnded` event, and transfers the highest bid amount to the owner's address.

## Steps to Interaction

1. **Deploy the Contract**
   - Deploy the contract with a specified bidding time (in seconds).

2. **Place Bids**
   - Users can place bids by calling the `bid()` function and sending an amount greater than the current highest bid.

3. **Withdraw Bids**
   - If a user is outbid, they can call the `withdraw()` function to retrieve their funds.

4. **End the Auction**
   - The owner can end the auction by calling the `auctionEnd()` function once the auction time has elapsed.

5. **Collect Funds**
   - After ending the auction, the highest bid amount is transferred to the owner's address.

---

This README provides a comprehensive overview of the auction smart contract, including its purpose, core functions, and interaction steps. Feel free to modify it further based on your specific requirements!
