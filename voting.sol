pragma solidity ^0.5.0;
contract Voting {
    enum Candidates {ALPHA, BETA, THETA}
    uint[] candidateVotes;
    bool public isOpen;
    /**
     * @dev Define Token Price (a criteria used in qualifying voters)
    */
    uint tokenPrice;
    /**
     * @dev Define minimum tokens (stake) required for voting
    */
    uint minTokenForVoting;
    /**
     * @dev Define VoterStatus using enum
    */
    enum VoterStatus {unverified, verified}
    /**
     * @dev Let's use struct to define our voter (address, name, and age)
    */
    struct Voter{
        address vAddress;   
        string fName;
        string lName;
        uint age;
        uint tokens;
        VoterStatus status;
    }
    /**
     * @dev Map address to Voter
    */
    mapping(address => Voter) voters;
    /**
     * @dev Use "mapping" to store multiple owners as checking for the existence
     * of an address in "mapping" is more efficient as compared to iterating
     * thru array
    */
    mapping(address => bool) owners;
    /** flag that allows to know if voting is still available**/ 
    /**
     * @dev Initialize the contract
    */
    constructor(address[] memory _addresses,uint _tokenPrice,uint _minToken) public{
        /**
         * @dev Set the token price
        */ 
        tokenPrice = _tokenPrice;
        /**
         * @dev Set minimum tokens required to be eligible for voting
        */
        minTokenForVoting = _minToken;
        /**
         * @dev Add the contract creator to the mapping
        */
        owners[msg.sender] = true;
        isOpen = true;
        /**
         * @dev Now add all the other addresses, "contract creator" wants to add
         * as co-owners
        */
         for(uint i=0; i< _addresses.length; i++){
            owners[_addresses[i]] = true;
         }
        /**
         * @dev As there are only 3 choices to vote, let's use fix length array 
         * to initialize the voting tracker
        */
        candidateVotes = new uint[](3);
    }
    /**
     * @dev Create a modifier to restrict access to the register voter function
     * as voters can be added only by super users
    */
    modifier onlyOwner{
        require(owners[msg.sender]);
        _;
    }    
    /**
     * @dev Only verified voters can vote
    */
    modifier onlyVerifiedVoters {
        Voter storage voter = voters[msg.sender];
        require(voter.status == VoterStatus.verified);
        _;
    }
    /**
     * @dev As per the requirement, only co-owners can add voters so we need to 
     * pass voter address to the function as it will be executed by co-owners 
     * only
    */
    function registerVoter(address _voter, string memory  _fName, string memory _lName, uint _age) onlyOwner public{
        Voter storage voter = voters[_voter];
        voter.vAddress = _voter;
        voter.fName = _fName;
        voter.lName = _lName;
        voter.age = _age;
        uint32 minVotingAge = 18;
        /**
         * @dev Minimum 5 ETH to purchase 5 tokens
        */
        require(voter.tokens >= minTokenForVoting);
        require(voter.age >= minVotingAge, "You're a young grasshopper");
        /**
         * @dev If above eligibility criteria is met, owners set status to verified
        */
        voter.status = VoterStatus.verified;
    }
    /**
     * @dev To avoid spam, co-owners would allow ballot from voters who have 
     * minimum of 5 tokens (proof of stake) to vote. So let's build a buy 
     * function for the Voters to buy tokens
     * @return uint
     */
    function buy() payable public returns(uint){
        Voter storage voter = voters[msg.sender];
        uint tokensToBuy = msg.value/tokenPrice;
        voter.tokens = tokensToBuy;
        return tokensToBuy;
    }
    /**
     * @dev Define the vote function
    */
    function vote(Candidates _candidate) onlyVerifiedVoters public{
        Voter storage voter = voters[msg.sender];
        require (isOpen);
        //Voter must be Verified, only 3 fixed candidate choices
        assert(_candidate == Candidates.ALPHA || _candidate == Candidates.BETA || _candidate == Candidates.THETA);
        uint prevCount = candidateVotes[uint8(_candidate)];
        candidateVotes[uint8(_candidate)] = prevCount + 1 ;
        //Set the status of the voter back to Unverified 
        voter.status = VoterStatus.unverified;
    }
    function CloseVoting () onlyOwner public {
        require(isOpen);
        isOpen = false;
    }
    /**
     * @dev Declare the winner of this election
     * @return uint
     */
    function winnerCandidate() public view returns (uint) {
        require(!isOpen);
        uint winner = 0;  //TODO 
        for(uint i=0;i < candidateVotes.length;i++){
            if(candidateVotes[i] > candidateVotes[winner]){
                winner = i;
            }
        }
        return winner;
    }
}
