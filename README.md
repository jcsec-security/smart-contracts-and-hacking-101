# Smart Contracts and Hacking 101

If you are attending my talk about blockchain technology, smart contracts and common security issues of the latter, this repo is for you!

## Smart Contracts

To have your first peek into a [basic smart contract](src/MyFirstApp.sol) deployed in the Sepolia testnet, check this [Etherscan URL](https://sepolia.etherscan.io/address/0x39ec8aF720E28b5D71ecba56190722E6F9e959FB)

Here you can check:
- History of transactions directed to the contract
- Current Ether balance, although the most common ERC20 tokens are also listed
- Deployed bytecode, and, optionally, the verified code
- Value of the state variables (storage)

## Vulnerabilities

1) Front-running: 
    - [Crack the hash challenge](src/Crack_the_hash.sol)
2) Clear-text secrets:
    - [Case study 1](src/Password_1.sol)
    - [Case study 2](src/Password_2.sol)
    - [Case study 3](src/Password_3.sol)
3) Integer over/underflow:
    - Play with a basic one [deployed in Sepolia](https://sepolia.etherscan.io/address/0xdf847035247a545d5ba09f3ebdef48786603c65f) - unchecked, solc 0.7.6
    - [Cooldown!](src/Cooldown.sol) - checked underflow
4) Pull over push:
    - [Funds redistribution](src/Redistribution.sol)
5) Reentrancy:
    - [Victim](src/Reentrancy_victim.sol)
    - [Attacker template](src/Reentrancy_attacker.sol)
