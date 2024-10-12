//SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

contract ExampleExceptionRequire {

    mapping (address => uint) public balanceReceived;

    function receiveMoney() public payable {
        balanceReceived[msg.sender] += msg.value;
    
    }

    // GAS IS RETURNED ASWELL - when i initialise with 8mil gas, uses 100k until here, 7.9mil is returned still
    function withdrawMoney (address payable _to, uint _amount) public {
        require(_amount <= balanceReceived[msg.sender], "Not enough funds, abort!!!");
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}