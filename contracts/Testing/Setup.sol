//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "../interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITestToken is IERC20{
    function mint(address _to, uint _amount) external;
}
/// @dev contract to help demo by minting a user necessary tokens as well as starting the liquidity pool
contract Setup{

    ITestToken public stable;
    ITestToken public bord;
    ITestToken public asset;
    constructor(address _stable, address _bord, address _asset){
        stable = ITestToken(_stable);
        bord = ITestToken(_bord);
        asset = ITestToken(_asset);
    }

    function setupLiquidityPools(address _dex) external{
        uint toMint = 2**100;

        stable.mint(address(this),toMint);
        asset.mint(address(this),toMint);
        bord.mint(address(this),toMint);
        stable.approve(_dex, toMint);
        asset.approve(_dex, toMint);
        bord.approve(_dex, toMint);

        IUniswapV2Router02(_dex).addLiquidity(
            address(stable),
            address(asset),
            toMint,
            toMint,
            0,
            0,
            address(this),
            block.timestamp+30
        );

        IUniswapV2Router02(_dex).addLiquidity(
            address(stable),
            address(bord),
            toMint,
            toMint,
            0,
            0,
            address(this),
            block.timestamp+30
        );

    }

    function setMeUp() external{
        stable.mint(msg.sender, 100 ether);
        bord.mint(msg.sender, 100 ether);
        asset.mint(msg.sender, 100 ether);
    }
}