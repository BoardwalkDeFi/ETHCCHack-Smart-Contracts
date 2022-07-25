//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract Strategy{

    IERC20 public stablecoin;
    IERC20 public asset;
    IERC20 public boardwalkToken;
    IUniswapV2Router02 public dex;

    mapping(address => uint) public availableCollateral;

    uint constant SLIPPAGE = 5;
    uint constant ONE_HUNDRED_PERCENT = 100;
    uint constant BASE_APY = 12;
    uint constant MIN_COLLATERAL = 10;

    /*
    Each Strategy has 4 categories of funds in it
        ============
        |Streams   |
        ============
        |Cash      |
        ============
        |Assets    |
        ============
        |Collateral|
        ============
    */
    function getStreamFunds() public view returns(uint){
        /// todo
    }

    function getCashFunds() public view returns(uint){
        return stablecoin.balanceOf(address(this));
    }

    function getAssetsFunds() public view returns(uint){
        /// todo
    }

    function getCollateralFunds() public view returns(uint){
        /// todo
    }

    function getAPY() public view returns(uint){
        // future idea is to add multiplier based on 1/x, x being the ratio of cash to assets.
        return BASE_APY;
    }

    function deposit(uint amount) external{
        stablecoin.transferFrom(msg.sender, address(this), amount);
        /// todo (get back some form of coupon)
    }

    function buySwap(uint amountCash) external{
        // require collateral
        require(
            _getCashValue(
            address(boardwalkToken), 
            availableCollateral[msg.sender]) >= (MIN_COLLATERAL * amountCash) / ONE_HUNDRED_PERCENT,
             "Not enough collateral to buy this swap"
             );
        // swap cash to asset
        require(getCashFunds() >= amountCash, "Not enough cash in contract to purchase this swap");
        address[] memory path = new address[](2);
        path[0] = address(stablecoin);
        path[1] = address(asset);
        uint[] memory amounts = dex.swapExactTokensForTokens(
            amountCash,
            _getMinOut(amountCash, path),
            path, 
            address(this), 
            block.timestamp+30
        );

        // issue swap stream and token
        /// todo
    }

    function settle(uint underlyingAmount, uint startingStablePrice, address payer) external{
        //f irst trade underlying back for stables and capture the amounts
        address[] memory path = new address[](2);
        path[0] = address(asset);
        path[1] = address(stablecoin);
        uint[] memory amounts = dex.swapExactTokensForTokens(
            underlyingAmount,
            _getMinOut(underlyingAmount, path),
            path, 
            address(this), 
            block.timestamp+30
        );

        // compare returned amount of stable to the origionall amount
        // if larger then return difference to the swap buyer
        if(amounts[1] > startingStablePrice){
            stablecoin.transfer(payer, amounts[1]-startingStablePrice);
        }
        
        // if smaller then remove then liquidate appropriate amount of collateral from the buyer
        // if there's not enough collateral then liquidate all of it
        /// todo
    }

    function depositCollateral(uint amount) external{
        boardwalkToken.transferFrom(msg.sender, address(this), amount);
        availableCollateral[msg.sender] += amount;
    }

    function _getMinOut(uint _amountIn, address[] memory _path) internal view returns(uint minOut){
        uint out = dex.getAmountsOut(_amountIn, _path)[_path.length-1];
        minOut = (out * (ONE_HUNDRED_PERCENT - SLIPPAGE)) / ONE_HUNDRED_PERCENT;
    }

    function _getCashValue(address token, uint amount) internal view returns(uint cashVal){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = address(stablecoin);
        uint[] memory amountsOut = dex.getAmountsOut(amount, path);
        return(amountsOut[1]);
    }

}
