// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/VoteSystem.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract VoteSystemTest {

    string[] proposalNames = ["Test 1", "Test 2", "Test 3"];
    uint256 startTime = 1644046200;
    uint256 endTime = 1675582200;

    VoteSystem voteSystemToTest;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'

    /// #value: 100000000000000000
    function beforeAll() public payable {
        // <instantiate contract>
        voteSystemToTest = new VoteSystem{value: 0.1 ether}(startTime, endTime, proposalNames);
    }

    function checkWinningProposal() public {
        voteSystemToTest.vote(1);
        Assert.equal(uint(1), voteSystemToTest.getWinningProposal(), "proposal at index 0 should be the winning proposal");
    }

    function checkCreateProposal() public {
        voteSystemToTest.createProposal("Test 4");
        Assert.equal(uint(4), voteSystemToTest.getProposalNames().length, "proposal should have length 4.");
    }

    function checkExtendClosingTime() public {
        voteSystemToTest.extendClosingTime(1675582500);
        Assert.equal(uint(1675582500), voteSystemToTest.closingTime(), "closing time should equal 1675582500");
    }
}
    