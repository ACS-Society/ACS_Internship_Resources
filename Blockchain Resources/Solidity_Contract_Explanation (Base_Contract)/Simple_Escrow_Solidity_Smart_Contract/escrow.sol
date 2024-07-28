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
