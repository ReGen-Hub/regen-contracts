const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const assert = require("assert");

describe("Regen", function () {
  let regen;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    console.log("AAA")
    const accounts = await ethers.getSigners();
    owner = accounts[0]
    user1 = accounts[1]
    user2 = accounts[2]
   
    const Regen = await ethers.getContractFactory("Regen");
   
    regen = await Regen.deploy();
    await regen.deployed();
  });

  it("should create a product", async function () {
    await regen.createProduct("Product 1", "Description", "Organic farming", 10, 10, "imagecid", 10);
    await regen.createProduct("Product 2", "Description2", "Organic farming2", 20, 20, "imagecid2", 20);
    const abi = new ethers.utils.AbiCoder();
    const encoded = abi.encode(["string", "string", "string", "uint256", "uint256", "string", "uint"], ["Product 1", "Description", "Organic farming", 10, 10, "imagecid", 10]);
   
    const hash1 = ethers.utils.keccak256(encoded);
    const productId = ethers.BigNumber.from(hash1).toString();
  
    const product = await regen.getAllProducts();
    console.log(product)
    
  });

  // it("should transfer a product", async function () {
  //   await regen.createProduct("Product 1", "Description", "Organic farming", 10, 10, "imagecid");
  //   const abi = new ethers.utils.AbiCoder();
  //   const encoded = abi.encode(["string", "string", "string", "uint256", "uint256", "string"], ["Product 1", "Description", "Organic farming", 10, 10, "imagecid"]);
   
  //   const hash1 = ethers.utils.keccak256(encoded);
  //   const productId = ethers.BigNumber.from(hash1).toString();
  //   console.log(productId)
  //   await regen.connect(owner).transferProduct(productId, user1.address);
  //   const product = await regen.getProduct(productId);
    
  //    expect(product.previousOwners).to.have.lengthOf(1);
  //    expect(product.previousOwners[0]).to.equal(owner.address);
  //    expect(product.currentOwner).to.equal(user1.address);
  // });

  // it("should not allow a non-owner to create a product", async function () {
  //   await expect(regen.connect(user1).createProduct("Product 1", "Description", "Organic farming", 10, 10, "imagecid")).to.be.revertedWith("Ownable: caller is not the owner");
  // });

  // it("should not allow a non-owner to transfer a product", async function () {
  //    await regen.createProduct("Product 1", "Description", "Organic farming", 10, 10, "imagecid");
  //    const abi = new ethers.utils.AbiCoder();
  //    const encoded = abi.encode(["string", "string", "string", "uint256", "uint256", "string"], ["Product 1", "Description", "Organic farming", 10, 10, "imagecid"]);
   
  //   const hash1 = ethers.utils.keccak256(encoded);
  //   const productId = ethers.BigNumber.from(hash1).toString();
  //   await expect(regen.connect(user1).transferProduct(productId, user2.address)).to.be.revertedWith("You do not own this product.");
  // });
});
