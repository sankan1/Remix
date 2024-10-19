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

    constructor() payable {
        owner = payable(msg.sender);
    }

    // modifier onlyClient() {
    //     require(msg.sender != owner, "Only the client can deposit ETH!");
    //     _;
    // }
    

    function depositEth() public payable {
        require(msg.sender != owner, "Only the client can deposit ETH!");
        accounts[msg.sender].depositedEth += msg.value;
    }

    function withdrawEth(uint _amount) public {
        require(msg.sender != owner, "Only the client can withdraw ETH!");
        require(_amount <= accounts[msg.sender].depositedEth, "Can't withdraw more than the bank account balance!");

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

    function giveLoan(address payable _to, uint _amount) public {
        require(msg.sender == owner, "Only the owner can give loans!");
        require(_amount <= address(this).balance, "Not enough funds in the contract to give the loan!");

        accounts[_to].currentLoan += _amount + (_amount / 6); // SO BANK MAKES BANK
        accounts[_to].depositedEth += _amount;
    }

    function payOffLoan() public {
        BankAccount storage userAccount = accounts[msg.sender];
        require(userAccount.currentLoan > 0, "No outstanding loan to pay off!");

        uint paymentAmount;

        if (userAccount.depositedEth >= userAccount.currentLoan) {

            paymentAmount = userAccount.currentLoan;
            userAccount.depositedEth -= userAccount.currentLoan;
            userAccount.currentLoan = 0;
        } else {

            paymentAmount = userAccount.depositedEth;
            userAccount.currentLoan -= userAccount.depositedEth;
            userAccount.depositedEth = 0;
        }
    }

    receive() external payable {
        depositEth();
     }
}

