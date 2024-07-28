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
