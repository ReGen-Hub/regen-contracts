const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Regen", function () {
  let regen;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    console.log("AAA")
    const accounts = await ethers.getSigners();
    console.log(accounts)

    console.log("Before get contract")
    const Regen = await ethers.getContractFactory("Regen");
    console.log(("After get contract "))
    regen = await Regen.deploy();
    await regen.deployed();
  });

  it("should create a product", async function () {
    await regen.connect(owner).createProduct("Product 1", "Description", "Organic farming", 10, 10, "imagecid");
    const product = await sustainableSupplyChain.getProduct(ethers.utils.keccak256(ethers.utils.solidityPack(["string", "string", "string", "uint256"], ["Product 1", "USA", "Organic farming", 10])));
    console.log(product)
  });

  it("should transfer a product", async function () {
    // await sustainableSupplyChain.connect(owner).createProduct("Product 1", "USA", "Organic farming", 10);
    // const productId = ethers.utils.keccak256(ethers.utils.solidityPack(["string", "string", "string", "uint256"], ["Product 1", "USA", "Organic farming", 10]));
    // await sustainableSupplyChain.connect(owner).transferProduct(productId, user1.address);
    // const product = await sustainableSupplyChain.getProduct(productId);
    // expect(product.previousOwners).to.have.lengthOf(1);
    // expect(product.previousOwners[0]).to.equal(owner.address);
    // expect(product.currentOwner).to.equal(user1.address);
  });

  it("should not allow a non-owner to create a product", async function () {
    //await expect(sustainableSupplyChain.connect(user1).createProduct("Product 1", "USA", "Organic farming", 10)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should not allow a non-owner to transfer a product", async function () {
    // await sustainableSupplyChain.connect(owner).createProduct("Product 1", "USA", "Organic farming", 10);
    // const productId = ethers.utils.keccak256(ethers.utils.solidityPack(["string", "string", "string", "uint256"], ["Product 1", "USA", "Organic farming", 10]));
    // await expect(sustainableSupplyChain.connect(user1).transferProduct(productId, user2.address)).to.be.revertedWith("You do not own this product.");
  });
});
