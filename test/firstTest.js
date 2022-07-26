const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
require("dotenv").config();

describe("Boardwalk Tests", function () {
    let strategy, swaps, stable, stream, asset, bordToken;
    let owner, user, user2;
    const toWei = ethers.utils.parseEther;
    before(async function(){
        [owner, user, user2] = await ethers.getSigners();

        const TestToken = await ethers.getContractFactory("TestToken");
        stable = await TestToken.deploy("USDC","USDC");
        stream = await TestToken.deploy("xUSDC","xUSDC");
        asset = await TestToken.deploy("WETH","WETH");
        bordToken = await TestToken.deploy("BORD","BORD");

        const Swaps = await ethers.getContractFactory("Swaps");
        swaps = await Swaps.deploy();

        const dex = await ethers.getContractAt("IUniswapV2Router02",process.env.DEX_ADDRESS);

        const Strategy = await ethers.getContractFactory("Strategy");
        strategy = await Strategy.deploy(stable.address, stream.address, asset.address, bordToken.address, dex.address, swaps.address)

        await stable.mint(owner.address, toWei("100000"));
        await stream.mint(owner.address, toWei("100000"));
        await asset.mint(owner.address, toWei("100000"));
        await bordToken.mint(owner.address, toWei("100000"));

    })
    it("Deposit", async function(){
        await stable.approve(strategy.address, toWei("10"));
        await strategy.deposit(toWei("10"));
        expect(await strategy.getCashFunds()).to.equal(toWei("10"))
    });
});