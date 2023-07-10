// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IWeth {
    function deposit() external payable;

    function approve(address _spender, uint256 _amount) external;

    function balanceOf(address account) external view returns (uint256);
}
