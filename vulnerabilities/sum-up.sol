// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;


contract SumUp {

    uint256 public sum = 32897;

    // Which number should you submit to get True?
    function sumZero(uint256 input) external returns(bool) { 
        bool res;

        // The summation between 0 and 256 is 32,896
        for (uint8 i = 0; i < 256; i++) {
            sum -= i;
        }

        sum += input;
        res = sum == 0;
        sum = 32897;

        return res;
    }

}