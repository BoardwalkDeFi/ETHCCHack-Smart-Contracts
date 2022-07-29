//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "../Queues.sol";

contract QueuesTest{
    using Queues for Queues.Queue;

    Queues.Queue public Queue;

    uint public Expected = 14;

    function pushTest() external{
        Queue.pushUint(0);
        Queue.pushUint(34);
        Queue.pushUint(2**256-1);
        Queue.pushUint(Expected);
        Queue.pushUint(2);
    }

    function popTest() external{
        Queue.popUint();
        Queue.popUint();
        Queue.popUint();
    }

    function getTop() external view returns(uint top){
        top = Queue.getTopUint();
    }
}