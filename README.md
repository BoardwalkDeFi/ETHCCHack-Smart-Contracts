## Boardwalk Smart Contracts Demo Instructions
Boardwalk contracts are deployed on Rinkeby and easy to demo with

NOTE: The superfluid streaming is not currently included, this makes things a lot simpler but does make the deposit side of the tx hard to visualize. We recommend sticking to the swap buying experience outlined below


Instructions
------------
First head to the setup contract to get some test tokens minted.
https://rinkeby.etherscan.io/address/0xAa618621c371aadF982a017C1c310dcc587fc998#writeContract
Call the `setMeUp()` function with your Rinkeby wallet to get some test tokens

To quickly rundown the tokens here they are:
Boardwalk Token: 0x3c1339DA839900A7fBa612A934560dE4d82fE405
    - Token is used as collateral necessary to buy swaps

tUSDC: 0x42DCAA257a35e875D6D6B7401a85094cf40897Ea
    - Used as a test USDC, deposited to fund swaps as well as returned as rewards

tWETH: 0x700FF7B56546eF9239650E2B97cC7276E33dDD16
    - used as a pretend asset that the swap is purchased on, neither party uses this but it's used by the contract

Note setup has a function to deposit to the liquidity pools tUSDC/tWETH and tUSDC/BORD.

Approvals:
The etherscan pages for the tokens above can be used to approve them. You must approve the Strategy contract bellow with these tokens for various functions. For good measure at this point it would be wise to visit each of their etherscan pages and call `approve()` with the Strategy address and a really large number, something larger than any number you will enter to test with.

Next head to the Strategy contract: https://rinkeby.etherscan.io/address/0xdA2F37Ac5DA4BAEAc574d0c64aA0E85b3675de1A#writeContract
Here you can call several functions,

- `deposit()` deposits tUSDC to fund other swaps. There may be enough in the contract already that you do not need to do this, if you get an error when buying a swap "Not enough cash in contract to purchase this swap" then depositing soem tUSDC with this function will solve it. Don't forget to approve the Strategy contract to spend your tUSDC in the tUSDC contract.

- `depositCollateral()` deposits BORD into the contract for your collateral which you will need to buy swaps

- `buySwap()` starts a swap! You must have deposited enough collateral, and you define the CASH VALUE of the swap, not the underlying value. In this case that is expressed in tUSDC. Everything is denominated in tUSDC. If you collateral was worth 20 tUSDC, then you are permitted to buy a swap on at most 200 tUSDC worth of tWETH. The max leverage at the moment is hard coded at 10x

- `withdrawal()` if you deposited you are returned a BORDscETH token to represent your deposit. You can later withdrawal it using this function. Note that BORDscETH token is an ERC20 you can do all the normal functions such as transfer with here.

Now that you have started your swap you can play with the price and see how it impacts your settlement.

First head over to Uniswap: https://app.uniswap.org/#/swap?chain=rinkeby 
And enter the tUSDC and tWETH or BORD token and make some trades to change the price.

One you have manipulated the price to your liking you can head over to our final contract Swaps
https://rinkeby.etherscan.io/address/0xcd347d38e4f8D197c02773984b188f298acB32F2#writeContract

Here you can call the test function `_endSwap` to end your swap. Note this takes a strange paramenter... Receiver index. This is because when you started your swap you were actually given an NFT representing the swap, and so was the other party, the receiver (which is the strategy contract). Receiver indexes are ALWAYS EVEN while the payer indexes (the matching NFT index you recieved) are always odd. Note that these NFTs determine who fulfills which end of the agreement and you can play with transfering them between wallets and seeing what happens when ths swap is ended.

To find your receiver index you may need to go back to the transaction you submitted to start your swap and copy the NFT id that is even of the NFTs minted. You can check more info about the IDs using this function 
https://rinkeby.etherscan.io/address/0xcd347d38e4f8D197c02773984b188f298acB32F2#readContract (`AssetsByReceiverIndex(INDEX HERE)`)

Once you have the index, enter it in the `_endSwap()` function and see the results of your swap! If the price decreased or swap fees ate away at the investment then your BORD collateral will be liquidated into tUSDC for Strategy. If the price increased then any extra tUSDC profits will be sent to you!


Deploying your own
------------------
If you would like to deploy your own contracts run `npm i` and fill out the example.env (and of course remove the "example" leaving just ".env"). Then simply run `npx hardhat deploy` if you would like to deploy on rinkeby add the `--network rinkeby` flag

END
---
Thank you for checking out the Boardwalk demo! Appologies it's not more user friendly but we hope you can still get a good idea of the project from this and can see the potential for the system




