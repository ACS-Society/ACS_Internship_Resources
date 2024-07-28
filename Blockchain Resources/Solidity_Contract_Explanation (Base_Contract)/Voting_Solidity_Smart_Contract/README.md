# VotingSystem Smart Contract

## Introduction to the Contract

The `VotingSystem` smart contract enables the creation and voting on proposals. It tracks the proposals, votes, and ensures that each address can vote only once per proposal. This contract provides a decentralized way to manage and execute voting processes on the Ethereum blockchain.

## Core Function Explanation

### Proposal Struct

- **`id`**: Unique identifier for the proposal.
- **`description`**: Brief description of the proposal.
- **`voteCount`**: Number of votes the proposal has received.

### State Variables

- **`proposalCount`**: Total number of proposals created.
- **`totalVotes`**: Total number of votes cast.
- 
## Contract Explanation

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.26;

contract VotingSystem {

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public votes;
    
    uint256 public proposalCount;
    uint256 public totalVotes;
    
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);

    function createProposal(string memory description) external {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            voteCount: 0
        });

        emit ProposalCreated(proposalCount, description);
    }

    function vote(uint256 proposalId) external {
        require(proposals[proposalId].id != 0, "Proposal does not exist");
        require(!hasVoted[msg.sender], "You have already voted");
        require(!votes[proposalId][msg.sender], "You have already voted for this proposal");
        proposals[proposalId].voteCount++;
        hasVoted[msg.sender] = true;
        votes[proposalId][msg.sender] = true;
        totalVotes++;

        emit Voted(proposalId, msg.sender);
    }

    function getProposal(uint256 proposalId) external view returns (
        uint256 id,
        string memory description,
        uint256 voteCount
    ) {
        Proposal memory proposal = proposals[proposalId];
        return (proposal.id, proposal.description, proposal.voteCount);
    }

    function getTotalVotes() external view returns (uint256) {
        return totalVotes;
    }
}
```

### Function `createProposal(string memory description)`

This function allows any user to create a new proposal by providing a description. Upon creation, the `proposalCount` is incremented, and a new `Proposal` struct is added to the `proposals` mapping. An event `ProposalCreated` is emitted with the proposal ID and description.

### Function `vote(uint256 proposalId)`

This function allows users to vote for a specific proposal by its ID. It ensures that:
- The proposal exists.
- The user has not already voted on any proposal.
- The user has not already voted on the specified proposal.

If the vote is valid, the proposal's `voteCount` is incremented, and the voter's address is marked as having voted both globally and for the specific proposal. The `totalVotes` is also incremented, and an event `Voted` is emitted with the proposal ID and voter's address.

### Function `getProposal(uint256 proposalId)`

This function allows users to retrieve details of a specific proposal by its ID. It returns the proposal's ID, description, and vote count.

### Function `getTotalVotes()`

This function returns the total number of votes cast across all proposals.

## Steps to Interaction

1. **Deploy the Contract**: Deploy the `VotingSystem` contract to the Ethereum blockchain.

2. **Create a Proposal**:
    - Call the `createProposal` function with a description of the proposal.
    - The contract will emit a `ProposalCreated` event with the proposal ID and description.

3. **Vote for a Proposal**:
    - Call the `vote` function with the ID of the proposal you wish to vote for.
    - Ensure you haven't already voted on any proposal or the specific proposal.
    - The contract will emit a `Voted` event with the proposal ID and your address.

4. **Retrieve Proposal Details**:
    - Call the `getProposal` function with the ID of the proposal.
    - The contract will return the proposal's ID, description, and vote count.

5. **Get Total Votes**:
    - Call the `getTotalVotes` function to retrieve the total number of votes cast across all proposals.
