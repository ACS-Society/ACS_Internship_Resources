# SupplyChainTracker Smart Contract

## Introduction to the Contract

The `SupplyChainTracker` smart contract is designed to manage and track the lifecycle of products in a supply chain. Each product goes through various stages from creation to delivery, and the contract ensures that the ownership and stage history of the products are maintained securely on the blockchain. The main features include creating products, updating their stages, transferring ownership, and retrieving product details along with their ownership history.

## Core Function Explanation

### 1. **createProduct**
```solidity
function createProduct(string memory name) external;
```
- **Purpose:** Creates a new product with the specified name, assigns it an ID, sets its initial stage to `Created`, and assigns ownership to the caller.
- **Events:** Emits a `ProductCreated` event with the product ID, name, and owner address.

### 2. **updateProductStage**
```solidity
function updateProductStage(uint256 productId, Stage newStage) external;
```
- **Purpose:** Updates the stage of an existing product. Only the current owner can update the stage.
- **Events:** Emits a `ProductUpdated` event with the product ID, new stage, and owner address.

### 3. **transferProduct**
```solidity
function transferProduct(uint256 productId, address newOwner) external;
```
- **Purpose:** Transfers the ownership of a product to a new owner. Only the current owner can transfer the ownership.
- **Events:** Emits a `ProductUpdated` event with the product ID, current stage, and new owner address.

### 4. **getProductDetails**
```solidity
function getProductDetails(uint256 productId) external view returns (
    uint256 id,
    string memory name,
    Stage stage,
    address currentOwner,
    uint256 timestamp
);
```
- **Purpose:** Retrieves the details of a specific product, including its ID, name, stage, current owner, and the timestamp of the last update.

### 5. **getOwnershipHistory**
```solidity
function getOwnershipHistory(uint256 productId) external view returns (address[] memory);
```
- **Purpose:** Retrieves the ownership history of a specific product.

## Contract Explanation

```solidity
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
```

### 1. **State Variables**
- `products`: A mapping from product ID to `Product` struct, storing product details.
- `ownershipHistory`: A mapping from product ID to an array of addresses, storing the history of owners for each product.
- `productCount`: A counter to keep track of the total number of products created.

### 2. **Structs and Enums**
- `Stage`: An enum representing the stages a product can be in (`Created`, `Shipped`, `InTransit`, `Delivered`).
- `Product`: A struct representing a product with its ID, name, stage, current owner, and timestamp.

### 3. **Events**
- `ProductCreated`: Emitted when a new product is created.
- `ProductUpdated`: Emitted when a product's stage is updated or ownership is transferred.

## Steps to Interaction

1. **Deploy the Contract:**
   - Deploy the `SupplyChainTracker` contract to the Ethereum network.

2. **Create a Product:**
   - Call the `createProduct` function with the product name to create a new product. The caller becomes the initial owner of the product.

3. **Update Product Stage:**
   - Call the `updateProductStage` function with the product ID and new stage. Only the current owner can update the product's stage.

4. **Transfer Product Ownership:**
   - Call the `transferProduct` function with the product ID and new owner's address. Only the current owner can transfer ownership.

5. **Retrieve Product Details:**
   - Call the `getProductDetails` function with the product ID to get the product's details, including its current stage and owner.

6. **Retrieve Ownership History:**
   - Call the `getOwnershipHistory` function with the product ID to get the history of owners for the product.

This contract ensures transparency and traceability in the supply chain by recording every update and transfer on the blockchain.
