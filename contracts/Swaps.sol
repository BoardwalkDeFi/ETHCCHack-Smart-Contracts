//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import { ISuperfluid }from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol"; //"@superfluid-finance/ethereum-monorepo/packages/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import { IInstantDistributionAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IInstantDistributionAgreementV1.sol";

interface IReceiver{
    function settle(uint underlyingAmount, uint startingStablePrice, address payer) external;
}

contract Swaps is ERC721{

    uint public index;

    constructor() ERC721("BoardwalkSwap","sWLK"){

    }

    struct Asset{
        int96 flowRateForAssets;
        uint amountUnderlyingExposed;
        uint lockedCollateral;
        uint priceStable;
        address strategy;
    }

    mapping(uint => Asset) public AssetsByReceiverIndex;

    function newSwap(address _receiver, address _payer, int96 _requiredFlowRate, uint _amountUnderlying) external{
        // start a new flow from user to caller of required flow rate
        /// todo

        // log swap data
        AssetsByReceiverIndex[index] = Asset(_requiredFlowRate, _amountUnderlying, 0, 0, msg.sender);

        // mint NFTs
        _mint(_receiver, index++);
        _mint(msg.sender, index++);
    }


    function _endSwap(uint _receiverIndex) external{
        Asset memory a = AssetsByReceiverIndex[_receiverIndex];

        // end the stream
        /// todo
        
        // call settlement
        IReceiver(a.strategy).settle(a.amountUnderlyingExposed, a.priceStable, ownerOf(_receiverIndex+1));

        // burn NFTs
        _burn(_receiverIndex);
        _burn(_receiverIndex+1);
    }


}