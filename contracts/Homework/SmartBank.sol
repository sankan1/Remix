//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract SmartBank {
    
    address payable owner;
    uint public interest;

    struct BankAccount {
        uint depositedEth;
        uint generatedInterest;
        uint currentLoan;
    }

    mapping(address => BankAccount) public accounts;

    constructor() {
        owner = payable(msg.sender);
    }

    function depositEth() public payable {
        require(msg.sender != owner, "Only the client can deposit ETH!");
        accounts[msg.sender].depositedEth += msg.value;
    }

    function withdrawEth(uint _amount) public {
        require(msg.sender != owner, "Only the client can deposit ETH!");
        require(_amount <= address(this).balance, "Can't withdraw more than the bank account balance!");

        accounts[msg.sender].depositedEth -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function makePayment(address payable _to, uint _amount) public {
        require(msg.sender != owner, "Only the client can make payments!");
        require(_amount <= accounts[msg.sender].depositedEth, "Can't send more than your deposited ETH!");

        accounts[msg.sender].depositedEth -= _amount;
        (bool success,) = _to.call{value:_amount, gas:1000000}("");
        require(success, "Aborting, call not successful");
    }

    function setDepositInterest(uint _interest) public {
        require(msg.sender == owner, "Only the owner can set the interest!");
        interest = _interest;
    }

    function payInterestOnDeposit(address payable _to) public {
        require(msg.sender == owner, "Only the owner can pay interest on deposits!");
        require(interest != 0, "The interest rate has not been set!");

        uint interestAmount = (accounts[_to].depositedEth * interest) / 100;
        
        accounts[_to].generatedInterest += interestAmount;
    }

    function receiveInterestPayment() public {
        require(msg.sender != owner, "Only the client can receive interest!");
        require(accounts[msg.sender].generatedInterest > 0, "No interest accumulated on the deposit, nothing to withdraw!");
        
        uint interestToSendOut = accounts[msg.sender].generatedInterest;
        accounts[msg.sender].generatedInterest = 0;
        payable(msg.sender).transfer(interestToSendOut);
    }

    receive() external payable {
        depositEth();
     }
}

