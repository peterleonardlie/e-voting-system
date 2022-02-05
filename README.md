# e-voting-system
Electronic Voting System on Ethereum Blockchain

## Configuration
- Ensure that there is at least 0.1 ETH in wallet before deploying the contract.
- The 0.1ETH is used as deposit to the smart contract which would be release to 1 winner when finalize() is being called after the voting period ended.
- Upon deployment, there are 3 variables that need to be filled.
  - openingTime – start time of the vote system
  - closingTime – end time of the vote system
  - proposalNames – initial proposal / choices.


## Deployment Steps
- Clone the git repository
- Open a new remix IDE (https://remix.ethereum.org/)
- Create a new workspace in remix IDE and copy the structure to the IDE (i.e. /contracts/math/SafeMath.sol)
  - VoteSystem_flat.sol is the flatted version.
- Open VoteSystem.sol in /contracts/
- Go to SOLIDITY COMPILER tab and compile the code. (works with compiler version 0.7.0 up to 0.9.0, in my deployed contracts I used 0.8.7 compiler)
- After compile successful, go to DEPLOY & RUN TRANSACTION tab and deploy the code with desired variables (opening time, closing time, proposal names []).
  - One thing to take note is that the VALUE needs to be 0.1 ETH / 100000000 Gwei, this will serve as deposit to the smart contract for the final reward.
- The smart contract is now deployed
-To verify, we would need to flatten the code (VoteSystem_flat.sol) and verify the smart contracts.

## Unit Tests
- Clone the git repository
- Open a new remix IDE (https://remix.ethereum.org/)
- Create a new workspace in remix IDE and copy the structure to the IDE (i.e. /contracts/math/SafeMath.sol)
  - VoteSystem_flat.sol is the flatted version.
- Open VoteSystem_test.sol in /tests/
- Go to SOLIDITY UNIT TESTING tab and select the test file (should be tests/VoteSystem_test.sol)
- Click Run and unit test should start.

