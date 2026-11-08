// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title SimpleVault
/// @notice A minimal ETH vault demonstrating NatSpec.
contract SimpleVault {
    uint256 public constant MIN_DEPOSIT = 1 ether;
    uint256 public constant MAX_DEPOSIT = 5 ether;

    mapping(address account => uint256 amount) public balances;

    error IncorrectDepositAmount(uint256 declaredAmount, uint256 valueSent);
    error DepositBelowMinimum(uint256 amount, uint256 minimum);
    error DepositAboveMaximum(uint256 amount, uint256 maximum);
    error InsufficientBalance(address account, uint256 requested, uint256 available);
    error EtherTransferFailed(address recipient, uint256 amount);

    /// @notice Deposit ETH into the vault.
    /// @param amount Amount to deposit; must be between 1 and 5 ETH and equal the ETH sent.
    function deposit(uint256 amount) external payable {
        if (amount == 0 || amount != msg.value) {
            revert IncorrectDepositAmount(amount, msg.value);
        }
        if (amount < MIN_DEPOSIT) {
            revert DepositBelowMinimum(amount, MIN_DEPOSIT);
        }
        if (amount > MAX_DEPOSIT) {
            revert DepositAboveMaximum(amount, MAX_DEPOSIT);
        }

        balances[msg.sender] += amount;
    }
    /// @notice Withdraw ETH previously deposited by the caller.
    /// @param amount Amount to withdraw, in wei.
    /// @return amountWithdrawn Amount transferred to the caller.
    function withdraw(uint256 amount) external returns (uint256 amountWithdrawn) {
        uint256 available = balances[msg.sender];
        if (amount > available) {
            revert InsufficientBalance(msg.sender, amount, available);
        }

        balances[msg.sender] = available - amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert EtherTransferFailed(msg.sender, amount);
        }

        return amount;
    }
}
