//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

library Queues{

    struct Queue{
        bytes32[] array;
        uint headIndex;
    }

    function pushUint(Queue storage q, uint element) internal{
        q.array.push(bytes32(element));
    }

    function popUint(Queue storage q) internal returns(uint top){
        top = uint(q.array[q.headIndex]); 
        delete(q.array[q.headIndex++]);
    }

    function getTopUint(Queue storage q) internal view returns(uint top){
        top = uint(q.array[q.headIndex]);
    }

    function getLastUint(Queue storage q) internal view returns(uint last){
        last = uint(q.array[q.array.length - 1]);
    }

    function getLength(Queue storage q) internal view returns(uint length){
        length = q.array.length - q.headIndex;
    }
}
