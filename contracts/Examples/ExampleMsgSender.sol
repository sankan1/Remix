//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

// Acc -> Contract(msg.sender to Acc)
// Acc -> Contract1 -> Contract2 (msg.sender to Contract1) 

contract ExampleMsgSender {
    address public someAddress;

    function updateSomeAddress() public {
        someAddress = msg.sender; // Account calls a contract, the msg.sender is the account
    }
}