// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Voting {
    address public ownerContract;

    constructor() {
        ownerContract = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerContract, "Not owner");
        _;
    }

    struct Candidate {
        string name;
        uint votes;
    }

    struct Poll {
        bool exists;
        uint startTime;
        uint endTime;
        Candidate[] candidates;
        mapping(address => bool) hasVoted;
    }

    mapping(uint => Poll) public polls;

    // Create a poll
    function createPoll(uint _pollid, uint _pollLength) public onlyOwner {
        require(!polls[_pollid].exists, "Poll already exists");
        Poll storage newPoll = polls[_pollid];
        newPoll.exists = true;
        newPoll.startTime = block.timestamp;
        newPoll.endTime = block.timestamp + _pollLength;
    }

    // Add candidate to a poll
    function addCandidate(uint _pollid, string memory _name) public onlyOwner {
        require(polls[_pollid].exists, "Poll does not exist");
        require(block.timestamp < polls[_pollid].endTime, "Poll already ended");

        polls[_pollid].candidates.push(Candidate({
            name: _name,
            votes: 0
        }));
    }

    // Cast vote
    function vote(uint _pollid, uint _candidateIndex) public {
        require(polls[_pollid].exists, "Poll does not exist");
        require(block.timestamp <= polls[_pollid].endTime, "Poll has ended");
        require(!polls[_pollid].hasVoted[msg.sender], "Already voted");

        polls[_pollid].candidates[_candidateIndex].votes += 1;
        polls[_pollid].hasVoted[msg.sender] = true;
    }

    // Get winner candidate name
    function getWinner(uint _pollid) public view returns (string memory winnerName, uint winnerVotes) {
        require(polls[_pollid].exists, "Poll does not exist");
        require(block.timestamp > polls[_pollid].endTime, "Poll not ended yet");

        uint highestVotes = 0;
        uint winnerIndex = 0;

        for (uint i = 0; i < polls[_pollid].candidates.length; i++) {
            if (polls[_pollid].candidates[i].votes > highestVotes) {
                highestVotes = polls[_pollid].candidates[i].votes;
                winnerIndex = i;
            }
        }

        winnerName = polls[_pollid].candidates[winnerIndex].name;
        winnerVotes = highestVotes;
    }

}
