// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "openzeppelin-solidity/contracts/access/Roles.sol";
// Uncomment this line to use console.log
//import "hardhat/console.sol";

contract Regen is Ownable {
   //using Roles for Roles.Role;
   // Roles.Role vendors; // Stores Vendor Roles
   // Roles.Role buyers; // Stores Buyer Roles
  
   mapping (uint => Product) public products;

   // Product struct
   struct Product {
    string name;
    string description;
    string category;
    uint256 price;
    uint productionDate;
    uint256 carbonFootprint;
    string imageCid; 
    address producer;
    address[] previousOwners;
    address currentOwner;
   }

   // Events
   event ProductCreated(
    uint productId,
    string name
   );

   event ProductTransferred(uint productId, address from, address to);

   // function addVendorRoles(address [] memory _vendors) public onlyOwner {
   //      for(uint i=0; i< _vendors.length; i++)
   //      {
   //          vendors.add(_vendors[i]);
   //      }
   //  }

   //  function addBuyerRoles(address [] memory _buyers) public onlyOwner
   //  {
   //      for(uint j =0; j< _buyers.length; j++)
   //      {
   //          buyers.add(_buyers[j]);
   //      }
   //  }


   function createProduct (
    string memory _name,
    string memory _description,
    string memory _category,
    uint256 _price,
    uint256 _carbonFootprint,
    string memory _imageCid
   ) public onlyOwner {
    //require(vendors.has(msg.sender), "DOES NOT HAVE VENDOR ROLE");
    require (bytes(_imageCid).length > 0);
    require (bytes(_name).length > 0);
    require (bytes(_description).length > 0);
    
    uint productId = uint(keccak256(abi.encode(
      _name, 
      _description,
      _category,
      _price,
      _carbonFootprint,
      _imageCid
      //block.timestamp
      )));

      //console.log(productId);
      products[productId] = Product (
         _name,
         _description,
         _category,
         _price,
         block.timestamp,
         _carbonFootprint,
         _imageCid,
         msg.sender,
         new address[](0),
         msg.sender
      );

    emit ProductCreated(
      productId,
      _name
    );

   }

   function transferProduct(uint _productId, address _to) public {
      require(products[_productId].currentOwner == msg.sender, "You do not own this product.");
        products[_productId].previousOwners.push(msg.sender);
        products[_productId].currentOwner = _to;
        emit ProductTransferred(_productId, msg.sender, _to);
   }

   function getProduct(uint _productId) public view returns (Product memory) {
      return (products[_productId]);
   }
   

}
