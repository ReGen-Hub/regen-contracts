// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Regen is Ownable {
    using Counters for Counters.Counter;

    // Structures
    struct Product {
        string name;
        string description;
        string category;
        uint256 price;
        uint256 productionDate;
        uint256 carbonFootprint;
        string imageCid; 
        uint256 quantity;
        address producer;
        address[] previousOwners;
        address currentOwner;
    }

    struct Order {
        uint256 productId;
        uint256 quantity;
        address buyer;
        uint256 purchaseDate;
    }
    Product[] productstructs;

    Order[] private orders;


    // Mappings
    mapping (uint256 => Product) public products;
    mapping (address => uint256) public customerRewards;
    mapping (uint256 => uint256) public carbonFootprints; // added mapping to track carbon footprint of each product sold

    // Counters
    Counters.Counter private _productIdCounter;
    Counters.Counter private _carbonFootprintCounter; // added counter to track total carbon footprint of all products sold

    // Events
    event ProductCreated(uint256 productId, string name);
    event ProductTransferred(uint256 productId, address from, address to);
    event ProductPurchased(address customer, uint256 productId);
    event OrderConfirmed(uint256 productId, address customer, uint256 date);

    // Functions
    function createProduct (
        string memory _name,
        string memory _description,
        string memory _category,
        uint256 _price,
        uint256 _carbonFootprint,
        string memory _imageCid,
        uint256 _quantity
    ) public {
        require(bytes(_imageCid).length > 0, "Image CID should not be empty");
        require(bytes(_name).length > 0, "Product name should not be empty");
        require(bytes(_description).length > 0, "Product description should not be empty");

        uint256 productId = _productIdCounter.current();

       productstructs.push(Product(
         _name,
            _description,
            _category,
            _price,
            block.timestamp,
            _carbonFootprint,
            _imageCid,
            _quantity,
            _msgSender(),
            new address[](0),
            _msgSender()
       ));
        products[productId] = Product (
            _name,
            _description,
            _category,
            _price,
            block.timestamp,
            _carbonFootprint,
            _imageCid,
            _quantity,
            _msgSender(),
            new address[](0),
            _msgSender()
        );

        _productIdCounter.increment();
        _carbonFootprintCounter.increment();

        emit ProductCreated(productId, _name);
    }

    function transferProduct(uint256 _productId, address _to) public {
        Product storage product = products[_productId];
        require(product.currentOwner == _msgSender(), "You do not own this product.");
        product.previousOwners.push(_msgSender());
        product.currentOwner = _to;
        customerRewards[_to] = product.price / 10;
        emit ProductTransferred(_productId, _msgSender(), _to);
    }

    function getProduct(uint256 _productId) public view returns (Product memory) {
return (products[_productId]);
}

function getAllProducts() public view returns (Product[] memory) {
   return (productstructs);
}

function buyProduct(uint256 _productId) public payable {
    Product storage product = products[_productId];
    require(msg.value >= product.price, "Insufficient funds");

    // Transfer the product price to the contract owner
    address payable owner = payable(address(this));
    owner.transfer(product.price);

    // Add the carbon footprint of the product to the total carbon footprint counter
    carbonFootprints[_carbonFootprintCounter.current()] = product.carbonFootprint;
    _carbonFootprintCounter.increment();

    // Calculate rewards for the customer
    uint256 reward = product.price / 10;

    // Add rewards to the customer's balance
    customerRewards[_msgSender()] += reward;

    // Transfer the product to the customer
    product.previousOwners.push(product.currentOwner);
    product.currentOwner = _msgSender();

    // Emit an event
    emit ProductPurchased(_msgSender(), _productId);
}

function getReward(address _customer) public view returns (uint256) {
    return customerRewards[_customer];
}

function confirmOrder(uint256 _productId, uint256 _quantity) public {
    Product storage product = products[_productId];
    require(product.currentOwner != address(0), "Product does not exist");
    require(product.currentOwner != msg.sender, "You cannot purchase your own product");
    require(_quantity > 0, "Quantity must be greater than zero");
    require(msg.sender != address(0), "Invalid sender address");
    
    // Deduct the quantity from the product
    require(product.quantity >= _quantity, "Insufficient product quantity");
    product.quantity -= _quantity;

    // Add a new order to the list of confirmed orders
    orders.push(Order({
        productId: _productId,
        quantity: _quantity,
        buyer: msg.sender,
        purchaseDate: block.timestamp
    }));

    // Emit an event
    emit OrderConfirmed(_productId, msg.sender, block.timestamp);
}

function getConfirmedOrders(address _buyer) public view returns (Order[] memory) {
    uint256 count = 0;
    for (uint256 i = 0; i < orders.length; i++) {
        if (orders[i].buyer == _buyer) {
            count++;
        }
    }

    Order[] memory result = new Order[](count);
    uint256 index = 0;
    for (uint256 i = 0; i < orders.length; i++) {
        if (orders[i].buyer == _buyer) {
            result[index] = orders[i];
            index++;
        }
    }

    return result;
}

function getAllConfirmedOrders() public view returns (Order[] memory) {
    return orders;
}

function redeemReward(uint256 rewardRedemptionPercentage) public {
    uint256 reward = customerRewards[_msgSender()];
    require(reward > 0, "No rewards to redeem");

    // Calculate the redemption amount based on the reward percentage set by the owner
    uint256 redemptionAmount = reward * rewardRedemptionPercentage / 100;
    require(redemptionAmount > 0, "Redemption amount is zero");

    // Deduct the redemption amount from the customer's rewards balance
    customerRewards[_msgSender()] -= reward;
}

// Function to calculate the total carbon footprint of all products sold
function getTotalCarbonFootprint() public view returns (uint256) {
    uint256 totalCarbonFootprint = 0;
    for (uint256 i = 0; i < _carbonFootprintCounter.current(); i++) {
        totalCarbonFootprint += carbonFootprints[i];
    }
    return totalCarbonFootprint;
}

// Function to calculate the sustainability impact of the rewards program
function getRewardsSustainabilityImpact() public view returns (uint256) {
uint256 totalRewardsRedeemed = 0;
for (uint256 i = 0; i < _productIdCounter.current(); i++) {
totalRewardsRedeemed += customerRewards[products[i].currentOwner];
}
return totalRewardsRedeemed;
}
}
