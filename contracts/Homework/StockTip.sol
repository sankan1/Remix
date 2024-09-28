//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract StockTip {
    address private owner;

    string private freeStockTip;
    string private paidStockTip;

    constructor() {
        owner = msg.sender;
    }

    function getStockTip() public payable returns(string memory) {
        if(msg.sender != owner) {
            if(msg.value == 3 ether) {
                return paidStockTip;
            } else if(msg.value != 3 ether) {
                payable(msg.sender).transfer(msg.value);
                return freeStockTip;
            }
        }

        return "";
    }

    function setOrChangeFreeStockTip(string memory _newFreeTip) public {
        if(msg.sender == owner) {
            freeStockTip = _newFreeTip;
        }
    }

    function setOrChangePaidStockTip(string memory _newPaidTip) public {
        if(msg.sender == owner) {
            paidStockTip = _newPaidTip;
        }
    }

    function withdrawContractBalance() public payable {
        if(msg.sender == owner) {
            payable(owner).transfer(address(this).balance);
        }
    }
}