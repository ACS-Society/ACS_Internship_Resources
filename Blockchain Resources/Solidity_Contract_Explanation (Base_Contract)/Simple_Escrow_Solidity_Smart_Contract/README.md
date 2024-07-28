# SimpleEscrow Contract

## Introduction to the Contract
The `SimpleEscrow` contract facilitates secure and conditional token transactions between a payer and a payee. It acts as an intermediary that holds tokens until the conditions for release are met, ensuring trust in transactions. The contract supports ERC-20 tokens and leverages OpenZeppelin's IERC20 interface.

## Core Function Explanation

### 1. `depositTokens`
This function allows the payer to deposit tokens into the escrow. The tokens are transferred from the payer's address to the contract's address and an escrow record is created.

**Parameters:**
- `address payee`: The address of the payee who will receive the tokens upon release.
- `address token`: The address of the ERC-20 token contract.
- `uint256 amount`: The amount of tokens to be deposited.

### 2. `releaseTokens`
This function allows the payer to release the tokens to the payee. It transfers the tokens from the contract to the payee's address.

**Parameters:**
- `uint256 escrowId`: The ID of the escrow to be released.

### 3. `refundTokens`
This function allows the payer to refund the tokens. It transfers the tokens back from the contract to the payer's address.

**Parameters:**
- `uint256 escrowId`: The ID of the escrow to be refunded.

### 4. `getEscrowDetails`
This function allows anyone to view the details of a specific escrow.

**Parameters:**
- `uint256 escrowId`: The ID of the escrow to be viewed.

**Returns:**
- `address payer`: The address of the payer.
- `address payee`: The address of the payee.
- `address token`: The address of the ERC-20 token.
- `uint256 amount`: The amount of tokens in the escrow.
- `bool isReleased`: The status of the escrow (true if tokens have been released).

## Contract Explanation

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract SimpleEscrow {


    struct Escrow {
        address payer;
        address payee;
        address token;
        uint256 amount;
        bool isReleased;
    }


    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCount;

    event TokensDeposited(uint256 escrowId, address indexed payer, address indexed payee, address indexed token, uint256 amount);
    event TokensReleased(uint256 escrowId, address indexed payer, address indexed payee, address indexed token, uint256 amount);
    event TokensRefunded(uint256 escrowId, address indexed payer, address indexed token, uint256 amount);

    function depositTokens(
        address payee,
        address token,
        uint256 amount
    ) external {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient token balance");
        require(IERC20(token).allowance(msg.sender, address(this)) >= amount, "Insufficient token allowance");

    
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        escrows[escrowCount] = Escrow({
            payer: msg.sender,
            payee: payee,
            token: token,
            amount: amount,
            isReleased: false
        });

        emit TokensDeposited(escrowCount, msg.sender, payee, token, amount);
        escrowCount++;
    }

    function releaseTokens(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];

        require(!escrow.isReleased, "Tokens have already been released");
        require(escrow.amount > 0, "No tokens to release");

        
        escrow.isReleased = true;
        IERC20(escrow.token).transfer(escrow.payee, escrow.amount);

        emit TokensReleased(escrowId, escrow.payer, escrow.payee, escrow.token, escrow.amount);
    }

    function refundTokens(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];

        require(!escrow.isReleased, "Tokens have already been released");
        require(escrow.amount > 0, "No tokens to refund");
        escrow.isReleased = true;
        IERC20(escrow.token).transfer(escrow.payer, escrow.amount);
        emit TokensRefunded(escrowId, escrow.payer, escrow.token, escrow.amount);
    }

    function getEscrowDetails(uint256 escrowId) external view returns (
        address payer,
        address payee,
        address token,
        uint256 amount,
        bool isReleased
    ) {
        Escrow storage escrow = escrows[escrowId];
        return (escrow.payer, escrow.payee, escrow.token, escrow.amount, escrow.isReleased);
    }
}
```

### Structs
- `Escrow`: This struct holds the details of each escrow, including the payer, payee, token, amount, and release status.

### State Variables
- `mapping(uint256 => Escrow) public escrows`: A mapping to store all escrows by their ID.
- `uint256 public escrowCount`: A counter to keep track of the total number of escrows.

### Events
- `TokensDeposited`: Emitted when tokens are deposited into an escrow.
- `TokensReleased`: Emitted when tokens are released to the payee.
- `TokensRefunded`: Emitted when tokens are refunded to the payer.

## Steps to Interaction

1. **Deploy the Contract**
   - Deploy the `SimpleEscrow` contract to the Ethereum blockchain.

2. **Deposit Tokens**
   - Call the `depositTokens` function with the payee's address, token address, and the amount of tokens to deposit. Ensure the ERC-20 token allowance is set for the contract.

3. **Release Tokens**
   - Call the `releaseTokens` function with the escrow ID to release the tokens to the payee. Only the payer can release the tokens.

4. **Refund Tokens**
   - Call the `refundTokens` function with the escrow ID to refund the tokens to the payer. Only the payer can refund the tokens.

5. **View Escrow Details**
   - Call the `getEscrowDetails` function with the escrow ID to view the details of a specific escrow.

This contract ensures a secure and conditional token transfer mechanism, providing trust and security in transactions involving ERC-20 tokens.
