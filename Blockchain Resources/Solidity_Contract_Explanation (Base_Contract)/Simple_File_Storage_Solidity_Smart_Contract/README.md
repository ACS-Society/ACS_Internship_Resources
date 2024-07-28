# SimpleFileStorage Smart Contract

## Introduction to the Contract

The `SimpleFileStorage` smart contract allows users to upload files by storing their hash and name on the blockchain. Each file is associated with an owner and can be transferred to other users. This contract provides basic functionality for uploading, retrieving, and transferring file ownership.

## Core Function Explanation

### Variables

- **File Struct**:
  - `fileHash`: The hash of the file.
  - `fileName`: The name of the file.
  - `owner`: The owner of the file.

### Functions

- **uploadFile**:
  - `uploadFile(string memory _fileHash, string memory _fileName) public`: Allows users to upload a file by providing its hash and name. Increments the file counter and emits the `FileUploaded` event.
  
- **getFile**:
  - `getFile(uint256 _fileId) public view returns (string memory, string memory, address)`: Allows users to retrieve the details of a file using its ID. Requires the file ID to be valid.

- **transferFile**:
  - `transferFile(uint256 _fileId, address _newOwner) public`: Allows the owner of a file to transfer its ownership to a new owner. Requires the caller to be the current owner of the file and the file ID to be valid.

## Contract Explanation

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleFileStorage {
    struct File {
        string fileHash; // Hash of the file
        string fileName; // Name of the file
        address owner;   // Owner of the file
    }

    mapping(uint256 => File) private files; // Mapping of file IDs to files
    uint256 private fileCount = 0;          // Counter for file IDs

    event FileUploaded(uint256 fileId, string fileHash, string fileName, address owner);
    event FileTransferred(uint256 fileId, address newOwner);

    function uploadFile(string memory _fileHash, string memory _fileName) public {
        fileCount++;
        files[fileCount] = File(_fileHash, _fileName, msg.sender);
        emit FileUploaded(fileCount, _fileHash, _fileName, msg.sender);
    }

    function getFile(uint256 _fileId) public view returns (string memory, string memory, address) {
        require(_fileId > 0 && _fileId <= fileCount, "File does not exist");
        File memory file = files[_fileId];
        return (file.fileHash, file.fileName, file.owner);
    }

    function transferFile(uint256 _fileId, address _newOwner) public {
        require(_fileId > 0 && _fileId <= fileCount, "File does not exist");
        require(msg.sender == files[_fileId].owner, "Only the owner can transfer the file");
        files[_fileId].owner = _newOwner;
        emit FileTransferred(_fileId, _newOwner);
    }
}
```

This contract provides a simple way to manage files on the blockchain. Users can upload files by submitting their hash and name. Each file is assigned a unique ID and linked to its uploader. Owners can transfer files to other users, enabling decentralized file management and ownership tracking.

### uploadFile Function

The `uploadFile` function allows users to upload files by providing their hash and name. When called, the function:
1. Increments the `fileCount`.
2. Stores the file information in the `files` mapping.
3. Emits the `FileUploaded` event with the file details.

### getFile Function

The `getFile` function allows users to retrieve file details using the file ID. When called, the function:
1. Checks if the file ID is valid.
2. Returns the file hash, name, and owner address.

### transferFile Function

The `transferFile` function allows the owner of a file to transfer its ownership to a new owner. When called, the function:
1. Checks if the file ID is valid.
2. Ensures the caller is the current owner of the file.
3. Updates the file owner.
4. Emits the `FileTransferred` event with the new owner details.

## Steps to Interaction

1. **Deploy the Contract**: Deploy the `SimpleFileStorage` contract on the desired blockchain network.
   
2. **Upload a File**: 
   - Call the `uploadFile` function with the file hash and name.
   - The function will emit the `FileUploaded` event with the file ID, hash, name, and owner address.

3. **Retrieve a File**:
   - Call the `getFile` function with the file ID.
   - The function will return the file hash, name, and owner address.

4. **Transfer File Ownership**:
   - Call the `transferFile` function with the file ID and the new owner’s address.
   - Ensure the caller is the current owner of the file.
   - The function will emit the `FileTransferred` event with the new owner details.
