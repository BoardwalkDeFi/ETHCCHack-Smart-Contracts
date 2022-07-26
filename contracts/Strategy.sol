//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";

interface ISwaps{
    function newSwap(address _receiver, address _payer, uint _requiredFlowRate, uint _amountUnderlying, uint _amountStable) external;
}
contract Strategy is ERC20{
    uint constant SLIPPAGE = 5;
    uint constant ONE_HUNDRED_PERCENT = 100;
    uint constant BASE_APY = 12;
    uint constant MIN_COLLATERAL = 10;

    IERC20 public stablecoin;
    IERC20 public streamCoin;
    IERC20 public asset;
    IERC20 public boardwalkToken;
    IUniswapV2Router02 public dex;
    ISwaps public swaps;

    mapping(address => uint) public availableCollateral;

    constructor(
        IERC20 _stablecoin, 
        IERC20 _streamCoin, 
        IERC20 _asset, 
        IERC20 _boardwalkToken, 
        IUniswapV2Router02 _dex, 
        ISwaps _swaps
        )
        ERC20("ETH Swap Coupon", "BORDscETH")
        {
        stablecoin = _stablecoin;
        streamCoin = _streamCoin;
        asset = _asset;
        boardwalkToken = _boardwalkToken;
        dex = _dex;
        swaps = _swaps;
    }
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
        return streamCoin.balanceOf(address(this));
    }

    function getCashFunds() public view returns(uint){
        return stablecoin.balanceOf(address(this));
    }

    function getAssetsFunds() public view returns(uint){
        return asset.balanceOf(address(this));
    }

    function getCollateralFunds() public view returns(uint){
        return boardwalkToken.balanceOf(address(this));
    }

    function getAPY() public view returns(uint){
        // future idea is to add multiplier based on 1/x, x being the ratio of cash to assets.
        return BASE_APY;
    }

    function deposit(uint amount) external{
        stablecoin.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdrawal(uint _amount) external{
        /// idea is to add in mechanism for reserve rate with the coupons, or just build a better system
        uint amount = _amount <= getCashFunds() ? _amount : getCashFunds();
        _burn(msg.sender, amount);
        stablecoin.transfer(msg.sender, amount);
        streamCoin.transfer(msg.sender, getStreamFunds() * amount / totalSupply());
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

        // issue swap stream
        swaps.newSwap(address(this), msg.sender, (getAPY() * amountCash) / ONE_HUNDRED_PERCENT, amounts[1], amountCash);
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
