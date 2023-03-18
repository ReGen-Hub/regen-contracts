// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract regen is Ownable {
   using Counters for Counters.Counter;
   Counters.Counter _suplierIds;

   event ProductCreated(
    uint256 ProductId,
    string name
   );

   struct Product {
    uint256 id;
    string title;
    string description;
    string category;
    uint256 price;
    uint256 carbonFootprint;
    string imageCid;
    string date;
    address producer;
    address[] previousOwners;
    address currentOwner;
   }

   Product[] products;

   function getSupplier (uint256 _id) public view returns (Supplier memory) {
    return suppliers[_id];
   }

   function createProduct (
    string memory _title,
    string memory _description,
    string memory _category,
    uint256 _price,
    string memory _imageCid,
    string memory _date,
    address producer,
    address[] previousOwners,
    address currentOwner
   ) public {

    require (bytes(_imageCid).length > 0);
    require (bytes(_title).length > 0);
    require (bytes(_description).length > 0);

    _suplierIds.increment();
    
    uint productId = uint(keccak256(abi.encode(
      _title, 
      _description,
      _category,
      _price,
      _imageCid,
      _date,
      _carbonFootprint
      )));

    suppliers.push(
      Product (
         _suplierIds.current();
         _title,
         _description,
         _category,
         _price,
         _imageCid,
         _date
      )
    );

    emit ProductCreated(
      _suplierIds.current();
         _title,
         _description,
         _category,
         _price,
         _imageCid,
         _date
    );

   }


}
