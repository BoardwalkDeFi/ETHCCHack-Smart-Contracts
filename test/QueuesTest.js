const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Queues Test", function () {
    let contract;
    it("Should run tests", async function(){
        const Contract = await ethers.getContractFactory("QueuesTest");
        contract = await Contract.deploy();
        
        await contract.pushTest();
        await contract.popTest();
        assert.equal(await contract.Expected().toString(), await contract.getTop().toString())
    });
});