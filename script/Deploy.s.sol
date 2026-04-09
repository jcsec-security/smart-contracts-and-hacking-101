// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {CrackTheHashChallenge} from "../src/Crack_the_hash.sol";
import {FirstApp} from "../src/MyFirstApp.sol";
import {Password1} from "../src/Password_1.sol";
import {Password2} from "../src/Password_2.sol";
import {Password3} from "../src/Password_3.sol";
import {PullOverPush} from "../src/Redistribution.sol";

// ---------------------------------------------------------------------------
// Helper contracts deployed on-chain
// ---------------------------------------------------------------------------

contract DoSAttackerContract {
    PullOverPush public target;

    constructor(address payable _target) {
        target = PullOverPush(_target);
    }

    receive() external payable {
        revert("Pull over Push!");
    }

    function joinContest() external {
        target.participate();
    }
}

// ---------------------------------------------------------------------------
// Deployment & interaction script
// ---------------------------------------------------------------------------

contract DeployAll is Script {
    // Main deployer
    uint256 DEPLOYER_PK = vm.envUint("DEPLOYER_PK");

    // Derived random private keys for interaction accounts
    uint256 randPK1 = uint256(keccak256("crackHash_submitter_1"));
    uint256 randPK2 = uint256(keccak256("crackHash_submitter_2"));
    uint256 randPK3 = uint256(keccak256("firstApp_depositor_1"));
    uint256 randPK4 = uint256(keccak256("firstApp_depositor_2"));
    uint256 randPK5 = uint256(keccak256("redistribution_member_1"));
    uint256 randPK6 = uint256(keccak256("redistribution_member_2"));
    uint256 randPK7 = uint256(keccak256("redistribution_member_3"));
    uint256 randPK8 = uint256(keccak256("redistribution_member_4"));

    // Contracts (stored at script level so all helpers can reference them)
    CrackTheHashChallenge crackHash;
    FirstApp firstApp;
    Password1 pw1;
    Password2 pw2;
    Password3 pw3;
    PullOverPush pop;
    DoSAttackerContract dosAttacker;

    function run() external {
        address deployer = vm.addr(DEPLOYER_PK);
        address a1 = vm.addr(randPK1);
        address a2 = vm.addr(randPK2);
        address a3 = vm.addr(randPK3);
        address a4 = vm.addr(randPK4);
        address a5 = vm.addr(randPK5);
        address a6 = vm.addr(randPK6);
        address a7 = vm.addr(randPK7);
        address a8 = vm.addr(randPK8);

        console.log("========== ACCOUNTS ==========");
        console.log("Deployer          :", deployer);
        console.log("CrackHash sub 1   :", a1);
        console.log("CrackHash sub 2   :", a2);
        console.log("FirstApp dep 1    :", a3);
        console.log("FirstApp dep 2    :", a4);
        console.log("Redist member 1   :", a5);
        console.log("Redist member 2   :", a6);
        console.log("Redist member 3   :", a7);
        console.log("Redist member 4   :", a8);

        // =================================================================
        // PHASE 1 — Deploy everything & fund random accounts (deployer tx)
        // =================================================================
        vm.startBroadcast(DEPLOYER_PK);
        crackHash = new CrackTheHashChallenge();
        firstApp = new FirstApp("Hello there ");
        pw1 = new Password1("ThisIsNotSoSecret");
        pw2 = new Password2(keccak256("HolaOlaHelloBonjour"));
        pw3 = new Password3(keccak256("ThirdSecret"));
        pop = new PullOverPush();

        console.log("========== DEPLOYED CONTRACTS ==========");
        console.log("CrackTheHashChallenge :", address(crackHash));
        console.log("FirstApp              :", address(firstApp));
        console.log("Password1             :", address(pw1));
        console.log("Password2             :", address(pw2));
        console.log("Password3             :", address(pw3));
        console.log("PullOverPush          :", address(pop));

        // --- Fund random accounts (minimum for gas + any value transfers) ---
        (bool s,) = payable(a1).call{value: 0.002 ether}("");
        require(s);
        (s,) = payable(a2).call{value: 0.002 ether}("");
        require(s);
        (s,) = payable(a3).call{value: 0.003 ether}("");
        require(s); // +0.001 deposit
        (s,) = payable(a4).call{value: 0.003 ether}("");
        require(s); // +0.001 deposit
        (s,) = payable(a5).call{value: 0.002 ether}("");
        require(s);
        (s,) = payable(a6).call{value: 0.002 ether}("");
        require(s);
        (s,) = payable(a7).call{value: 0.002 ether}("");
        require(s);
        (s,) = payable(a8).call{value: 0.002 ether}("");
        require(s);

        // --- CrackTheHash: create a random challenge ---
        crackHash.newChallenge("0xbcd0bb24a652089bd0a0a53ba68450521d4f1c331610456309936263f44561f6"); //keccak256("mySuperSecretGoal")
        console.log("[CrackTheHash] challenge created: mySuperSecretGoal");

        // --- Password1: setGreeting ---
        pw1.setGreeting("ThisIsNotSoSecret", "HellO there ");
        console.log("[Password1] greeting set to 'HellO there '");

        // --- Password2: setGreeting ---
        pw2.setGreeting("HolaOlaHelloBonjour", "Welcome ");
        console.log("[Password2] greeting set to 'Welcome '");

        // --- Password3: setGreeting ---
        pw3.setGreeting("ThirdSecret", keccak256("AnotherOne"), "Welcome ");
        console.log("[Password3] greeting set to 'Welcome ', hash rotated");

        // --- MyFirstApp: direct ETH deposit (via receive) ---
        (s,) = address(firstApp).call{value: 0.001 ether}("");
        require(s, "direct ETH deposit failed");
        console.log("[FirstApp] direct ETH deposit 0.001 ether");

        vm.stopBroadcast();

        // =================================================================
        // PHASE 2 — CrackTheHash: submit answers from random addresses
        // =================================================================
        vm.startBroadcast(randPK1);
        crackHash.submitAnswer("thisIsATest");
        console.log("[CrackTheHash] a1 submitted 'thisIsATest'");
        vm.stopBroadcast();

        vm.startBroadcast(randPK2);
        crackHash.submitAnswer("notSureIfCorrect");
        console.log("[CrackTheHash] a2 submitted 'notSureIfCorrect'");
        vm.stopBroadcast();

        // =================================================================
        // PHASE 3 — MyFirstApp: deposits from random addresses
        // =================================================================
        vm.startBroadcast(randPK3);
        firstApp.deposit{value: 0.001 ether}();
        console.log("[FirstApp] a3 deposited 0.001 ether");
        vm.stopBroadcast();

        vm.startBroadcast(randPK4);
        firstApp.deposit{value: 0.001 ether}();
        console.log("[FirstApp] a4 deposited 0.001 ether");
        vm.stopBroadcast();
        // =================================================================
        // PHASE 4 — MyFirstApp: withdraw from one random address
        // =================================================================
        vm.startBroadcast(randPK4);
        firstApp.withdraw();
        console.log("[FirstApp] a4 withdrew");
        vm.stopBroadcast();

        // =================================================================
        // PHASE 5 — Redistribution: 4 EOAs + DoSAttacker, fund pot, fail
        // =================================================================
        vm.startBroadcast(randPK5);
        pop.participate();
        vm.stopBroadcast();

        vm.startBroadcast(randPK6);
        pop.participate();
        vm.stopBroadcast();

        vm.startBroadcast(randPK7);
        pop.participate();
        vm.stopBroadcast();

        vm.startBroadcast(randPK8);
        pop.participate();
        vm.stopBroadcast();

        vm.startBroadcast(DEPLOYER_PK);

        dosAttacker = new DoSAttackerContract(payable(address(pop)));
        console.log("DoSAttackerContract   :", address(dosAttacker));
        dosAttacker.joinContest();
        console.log("[Redistribution] DoSAttacker joined as 5th member");

        // Fund pot (must be divisible by 5)
        (s,) = address(pop).call{value: 0.005 ether}("");
        require(s, "pot funding failed");
        console.log("[Redistribution] pot funded with 0.005 ether");

        vm.stopBroadcast();

        // =================================================================
        // Summary
        // =================================================================
        console.log("");
        console.log("============ ALL CONTRACTS ============");
        console.log("CrackTheHashChallenge  :", address(crackHash));
        console.log("FirstApp               :", address(firstApp));
        console.log("Password1              :", address(pw1));
        console.log("Password2              :", address(pw2));
        console.log("Password3              :", address(pw3));
        console.log("PullOverPush           :", address(pop));
        console.log("DoSAttackerContract    :", address(dosAttacker));
        console.log("=======================================");
        console.log("");
        console.log("To test the Redistribution DoS, run:");
        console.log("  cast send <PullOverPush_addr> 'retrieveAllPush()' --rpc-url sepolia --private-key <PK>");
        console.log("  (this tx will REVERT on-chain, confirming the DoS)");
    }
}
