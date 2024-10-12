//SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

contract ExampleAssert {

    mapping (address => uint8) public balanceReceived;

    function receiveMoney() public payable {
        // GAS IS EATEN UP FULLY
        assert(msg.value == uint8(msg.value));
        balanceReceived[msg.sender] += uint8(msg.value);
    
    }

    // GAS IS RETURNED ASWELL - when i initialise with 8mil gas, uses 100k until here, 7.9mil is returned still
    function withdrawMoney (address payable _to, uint8 _amount) public {
        require(_amount <= balanceReceived[msg.sender], "Not enough funds, abort!!!");
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}