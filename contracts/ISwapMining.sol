// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

interface ISwapMining {
    function takerWithdraw() external;
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}