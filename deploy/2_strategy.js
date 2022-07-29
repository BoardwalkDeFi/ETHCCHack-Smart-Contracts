const { ethers } = require("hardhat");
require("dotenv").config();

module.exports = async ({getNamedAccounts, deployments}) => {

    const {deploy, get} = deployments;
    const {account0} = await getNamedAccounts();

    const stablecoin = await get("StableCoin");
    const streamCoin = await get("StreamCoin");

    const asset = await get("Asset");
    const boardwalkToken = await get("BoardwalkToken");
    const dex = await ethers.getContractAt("IUniswapV2Router02",process.env.DEX_ADDRESS);

    const swaps = await get("Swaps");

    await deploy('Strategy', {
      from: account0,
      args: [stablecoin.address, streamCoin.address, asset.address, boardwalkToken.address, dex.address, swaps.address],
      log: true,
    });

};