# Smart Contracts and Hacking 101

If you are attending my talk about blockchain technology, smart contracts and common security issues of the latter, this repo is for you!

## Smart Contracts

To have your first peek into a smart contract deployed in the Sepolia testnet, check this [Etherscan URL](https://sepolia.etherscan.io/address/0x4747df6e3bc844b21f681dcf0270e9cab51b33a6)

Here you can check:
- History of transactions directed to the contract
- Current Ether balance, although the most common ERC20 tokens are also listed
- Deployed bytecode, and, optionally, the verified code
- Value of the state variables (storage)

## Vulnerabilities

1) Front-running: 
    - [Crack the hash challenge](./vulnerabilities/crack_the_hash.sol)
2) Clear-text secrets:
    - [Case study 1](./vulnerabilities/password_1.sol)
    - [Case study 2](./vulnerabilities/password_2.sol)
    - [Case study 3](./vulnerabilities/password_3.sol)
3) Integer over/underflow:
    - Play with a basic one [deployed in Sepolia](https://sepolia.etherscan.io/address/0xdf847035247a545d5ba09f3ebdef48786603c65f)
    - [Sum up!](./vulnerabilities/sum_up.sol)
5) Reentrancy:
    - [Victim](./vulnerabilities/reentrancy_victim.sol)
    - [Attacker template](./vulnerabilities/reentrancy_attacker.sol)
