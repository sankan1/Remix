//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract WillThrow {

    error NotAllowedError(string);

    function aFn() public pure {
        //require(false, "Error message");
        // assert(false)
        revert NotAllowedError("You are not allowed!");
    }
}

contract ErrorHandling {

    event ErrorLogging(string reason);
    event ErrorLogCode(uint code);
    event ErrorLogBytes(bytes lowLevelData);

    function catchTheError() public {
        WillThrow will = new WillThrow();

        try will.aFn() {

        } catch Error(string memory reason) {
            emit ErrorLogging(reason);
        } catch Panic(uint errorCode) { // ASSERT ERROR
            emit ErrorLogCode(errorCode);
        } catch(bytes memory lowLevelData) {
            emit ErrorLogBytes(lowLevelData);
        }
    }
}