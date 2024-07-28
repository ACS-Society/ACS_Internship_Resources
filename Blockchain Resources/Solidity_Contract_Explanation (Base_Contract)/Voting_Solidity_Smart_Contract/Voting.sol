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
