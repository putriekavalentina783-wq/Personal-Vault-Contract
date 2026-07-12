// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PersonalVault {

    // State Variables
    address public owner;
    uint256 public unlockTime;

    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed receiver, uint256 amount);
    event LockExtended(uint256 oldUnlockTime, uint256 newUnlockTime);

    // Custom Errors
    error NotOwner();
    error FundsLocked();
    error NoFunds();
    error InvalidUnlockTime();

    // Constructor
    constructor(uint256 _unlockTime) {
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // Deposit ETH ke vault
    function deposit() external payable {
        if (msg.value == 0) {
            revert NoFunds();
        }

        emit Deposit(msg.sender, msg.value);
    }

    // Perpanjang waktu lock
    function extendLock(uint256 _newUnlockTime) external {
        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (_newUnlockTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        uint256 oldUnlockTime = unlockTime;
        unlockTime = _newUnlockTime;

        emit LockExtended(oldUnlockTime, _newUnlockTime);
    }

    // Withdraw seluruh saldo
    function withdraw() external {
        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        uint256 amount = address(this).balance;

        if (amount == 0) {
            revert NoFunds();
        }

        (bool success, ) = payable(owner).call{value: amount}("");

        require(success, "Transfer failed");

        emit Withdraw(owner, amount);
    }
}