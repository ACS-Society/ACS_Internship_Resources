// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


contract SupplyChainTracker {

    enum Stage {
        Created,
        Shipped,
        InTransit,
        Delivered
    }

    struct Product {
        uint256 id;
        string name;
        Stage stage;
        address currentOwner;
        uint256 timestamp;
    }


    mapping(uint256 => Product) public products;
    mapping(uint256 => address[]) public ownershipHistory;

    uint256 public productCount;

    event ProductCreated(uint256 indexed productId, string name, address indexed owner);
    event ProductUpdated(uint256 indexed productId, Stage stage, address indexed owner);
    
 
    function createProduct(string memory name) external {
        productCount++;
        products[productCount] = Product({
            id: productCount,
            name: name,
            stage: Stage.Created,
            currentOwner: msg.sender,
            timestamp: block.timestamp
        });
        ownershipHistory[productCount].push(msg.sender);

        emit ProductCreated(productCount, name, msg.sender);
    }

    function updateProductStage(uint256 productId, Stage newStage) external {
        require(products[productId].id != 0, "Product does not exist");
        require(products[productId].currentOwner == msg.sender, "Only the current owner can update the stage");

        products[productId].stage = newStage;
        products[productId].timestamp = block.timestamp;

        ownershipHistory[productId].push(msg.sender);

        emit ProductUpdated(productId, newStage, msg.sender);
    }

    function transferProduct(uint256 productId, address newOwner) external {
        require(products[productId].id != 0, "Product does not exist");
        require(products[productId].currentOwner == msg.sender, "Only the current owner can transfer ownership");

        products[productId].currentOwner = newOwner;
        products[productId].timestamp = block.timestamp;

        // Track ownership history
        ownershipHistory[productId].push(newOwner);

        emit ProductUpdated(productId, products[productId].stage, newOwner);
    }


    function getProductDetails(uint256 productId) external view returns (
        uint256 id,
        string memory name,
        Stage stage,
        address currentOwner,
        uint256 timestamp
    ) {
        Product storage product = products[productId];
        return (product.id, product.name, product.stage, product.currentOwner, product.timestamp);
    }

    function getOwnershipHistory(uint256 productId) external view returns (address[] memory) {
        return ownershipHistory[productId];
    }
}