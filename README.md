# Smart Contracts and Hacking 101

If you are attending my talk about blockchain technology, smart contracts and common security issues of the latter, this repo is for you!

## Smart Contracts

First peek into a live smart contract using a block explorer
- [Goerli Etherscan URL](https://goerli.etherscan.io/address/0xd7F07FA527C4eE13717125534A7258fFa60CE6c1)

## Vulnerabilities

1) Front-running: 
    - [Crack the hash challenge](./vulnerabilities/crack_the_hash.sol)
2) Clear-text secrets:
    - [Case study 1](./vulnerabilities/password_1.sol)
    - [Case study 2](./vulnerabilities/password_2.sol)
    - [Case study 3](./vulnerabilities/password_3.sol)
3) Integer over/underflow: 
    - [Sum up!](./vulnerabilities/sum_up.sol)
4) Reentrancy:
    - [Victim](./vulnerabilities/reentrancy_victim.sol)
    - [Attacker template](./vulnerabilities/reentrancy_attacker.sol)
