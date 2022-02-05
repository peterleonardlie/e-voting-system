// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./math/SafeMath.sol";

/** 
 * @title VoteSystem
 * @dev Implements voting process
 */
contract VoteSystem {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    bool private _voteFinished = false;

    struct Voter {
        bool voted; // if true, that person already voted
        uint256 vote; // index of the voted proposal
    }

    struct Proposal {
        string name;   // proposal name
        uint256 voteCount; // number of accumulated votes
        // address[] voters; // address of the voters
    }

    address public owner;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;
    string[] private _names;
    address[] private _countedVoters;
    address[] private _votersForWinningProposal;

    /**
     * Event for crowdsale extending
     * @param newClosingTime new closing time
     * @param prevClosingTime old closing time
     */
    event VotingExtended(uint256 prevClosingTime, uint256 newClosingTime);

    /**
     * @dev Reverts if not in voting period time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "Vote System is not open.");
        _;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "only owner of this contract can call this function.");
        _;
    }
    

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    constructor(uint256 openingTimestamp, uint256 closingTimestamp, string[] memory proposalNames) payable {
        require(msg.value == 0.01 ether, "Need to deposit 0.1 ether to winner");
        owner = msg.sender;

        _openingTime = openingTimestamp;
        _closingTime = closingTimestamp;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            Proposal memory temp;
            temp.name = proposalNames[i];
            temp.voteCount = 0;

            proposals.push(temp);

            _names.push(proposalNames[i]);
        }
    }

    function createProposal(string memory proposalName) public onlyOwner {
        Proposal memory temp;
        temp.name = proposalName;
        temp.voteCount = 0;

        proposals.push(temp);

        _names.push(proposalName);
    }
    
    /**
     * @return the opening time.
     */
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return the closing time.
     */
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    /**
     * @return true if the vote system is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the vote system is open has already elapsed.
     * @return Whether voting period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _closingTime;
    }

    /**
     * @dev Extend voting period.
     * @param newClosingTime voting period closing time
     */
    function extendClosingTime(uint256 newClosingTime) public onlyOwner {
        require(!hasClosed(), "Vote System already closed.");
        // solhint-disable-next-line max-line-length
        require(newClosingTime > _closingTime, "New closing time is before current closing time");

        emit VotingExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }

    function getProposalNames() public view returns (string[] memory) {
        return _names;
    }

    /**
     * @dev Give your vote to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public onlyWhileOpen {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += 1;
        // proposals[proposal].voters.push(msg.sender);
        _countedVoters.push(msg.sender);
    }

    function getVoteCount(uint proposal) public view virtual returns(uint256) {
        return proposals[proposal].voteCount;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function getWinningProposal() public view
            returns (uint winningProposal_)
    {
        // require(hasClosed(), "Voting is still open.");

        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function random(uint numOfVoters) private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % numOfVoters);
    }

    function finalize() public onlyOwner {
        require(hasClosed(), "Voting period has not closed.");
        require(!_voteFinished, "Vote System has concluded, reward has been given.");

        // get winning proposals
        uint winningProposal = getWinningProposal();

        // get votersForWinningProposal
        populateVotersForWinningProposal(winningProposal);

        // call random function to get a random index from the list of voters in the winning proposal
        uint numOfVoters = _votersForWinningProposal.length;

        uint index = random(numOfVoters);

        // give the voter the promised eth.
        address winner = _votersForWinningProposal[index];

        (bool success, ) = payable(winner).call{
            value: 0.01 ether
        }("");

        require(success);

        // set vote finished to true
        _voteFinished = true;
    }

    function populateVotersForWinningProposal(uint winningProposal) private onlyOwner {
        for (uint i = 0; i < _countedVoters.length; i++) {
            address voterAddress = _countedVoters[i];
            Voter storage voter = voters[voterAddress];
            if (voter.vote == winningProposal) {
                _votersForWinningProposal.push(voterAddress);
            }
        }
    }
}