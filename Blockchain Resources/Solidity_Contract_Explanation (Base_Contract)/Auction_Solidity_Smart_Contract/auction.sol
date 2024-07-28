// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MultiSigWallet {


    event TransactionSubmitted(uint256 txIndex, address indexed sender, address indexed to, uint256 amount, string data);
    event TransactionConfirmed(uint256 txIndex, address indexed owner);
    event TransactionExecuted(uint256 txIndex);
    event TransactionRevoked(uint256 txIndex, address indexed owner);

    struct Transaction {
        address to;
        uint256 amount;
        string data;
        bool executed;
        uint256 confirmations;
        mapping(address => bool) isConfirmed;
    }

    address[] public owners;
    uint256 public required;
    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactionCount, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!transactions[_txIndex].isConfirmed[msg.sender], "Transaction already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
        }
        required = _required;
    }

    function isOwner(address _addr) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _addr) return true;
        }
        return false;
    }

    function submitTransaction(address _to, uint256 _amount, string memory _data) external onlyOwner {
        uint256 txIndex = transactionCount++;
        Transaction storage txn = transactions[txIndex];
        txn.to = _to;
        txn.amount = _amount;
        txn.data = _data;
        txn.executed = false;
        txn.confirmations = 0;

        emit TransactionSubmitted(txIndex, msg.sender, _to, _amount, _data);
    }

    function confirmTransaction(uint256 _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage txn = transactions[_txIndex];
        txn.isConfirmed[msg.sender] = true;
        txn.confirmations++;

        emit TransactionConfirmed(_txIndex, msg.sender);

        if (txn.confirmations >= required) {
            executeTransaction(_txIndex);
        }
    }

    function executeTransaction(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage txn = transactions[_txIndex];
        require(txn.confirmations >= required, "Not enough confirmations");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.amount}(bytes(txn.data));
        require(success, "Transaction failed");

        emit TransactionExecuted(_txIndex);
    }

    function revokeConfirmation(uint256 _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage txn = transactions[_txIndex];
        require(txn.isConfirmed[msg.sender], "Transaction not confirmed");

        txn.isConfirmed[msg.sender] = false;
        txn.confirmations--;

        emit TransactionRevoked(_txIndex, msg.sender);
    }

    receive() external payable {}
}