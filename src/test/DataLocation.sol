// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

/*
Description:
Misuse of storage and memory references of the user in the updaterewardDebt function.

Recommendation:
Ensure the correct usage of memory and storage in the function parameters. Make all the locations explicit.

Real case: cover protocol: https://mudit.blog/cover-protocol-hack-analysis-tokens-minted-exploit/
Storage vs. memory in Solidity: https://www.educative.io/answers/storage-vs-memory-in-solidity
*/

contract ContractTest is Test {
    Array ArrayContract;

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        //vm.startPrank(alice);
        ArrayContract = new Array();
        ArrayContract.updaterewardDebt(100); // update rewardDebt to 100
        
        (uint256 amount, uint256 rewardDebt) = ArrayContract.userInfo(
            address(this)
        );
        console.log("Non-updated rewardDebt", rewardDebt);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardDebt(100);
        (uint256 newamount, uint256 newrewardDebt) = ArrayContract.userInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardDebt);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => UserInfo) public userInfo; // storage

    struct UserInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.
    }

    function updaterewardDebt(uint256 amount) public {
        UserInfo memory user = userInfo[msg.sender]; // memory, vulnerable point
        user.rewardDebt = amount;
    }

    function fixedupdaterewardDebt(uint256 amount) public {
        UserInfo storage user = userInfo[msg.sender]; // storage
        user.rewardDebt = amount;
    }
}
