// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomerCardSystem {

    struct Customer {
        string encryptedData;
        bytes32 dataHash;
        string customerCardId;
    }

    mapping(address => Customer) public customers;
    mapping(bytes32 => string) public customerNames;

    address public cardIssuer;

    event CustomerRegistered(address indexed customerAddress, string customerCardId, bytes32 dataHash);

    constructor() {
        cardIssuer = msg.sender;
    }

    modifier onlyCardIssuer() {
        require(msg.sender == cardIssuer, "Only card issuer can modify!");
        _;
    }

    function registerCustomer(
        string memory _name,
        string memory _encryptedData,
        string memory _customerCardId
    ) public {
        bytes32 hash = keccak256(abi.encodePacked(_encryptedData));
        customers[msg.sender] = Customer(_encryptedData, hash, _customerCardId);
        customerNames[hash] = _name;

        emit CustomerRegistered(msg.sender, _customerCardId, hash);
    }

    function viewCustomerData(bytes32 _hash) public view onlyCardIssuer returns (string memory, string memory) {
        require(bytes(customerNames[_hash]).length != 0, "No client data found!");
        
        string memory name = customerNames[_hash];
        Customer memory customer = customers[msg.sender];
        
        return (name, customer.encryptedData);
    }
}
