//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

contract ExampleStrings {
    // storage vars
    string public myString = "HW";
    bytes public myBites = "HW";

    function setMyString(string memory _myString) public {
        myString = _myString;
    }

    // read function
    function compareTwoStrings(string memory _myString) public view returns(bool) {
        return keccak256(abi.encodePacked(myString)) == keccak256(abi.encodePacked(_myString));
    }
}