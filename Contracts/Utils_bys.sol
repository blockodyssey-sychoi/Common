// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Utils_bys{
    // From: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol
    function toString(uint value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    // Does a string contain another one?
    function contains(string memory main, string memory subString) public pure returns (bool){
        require(bytes(main).length >= bytes(subString).length, "Error in string comparsions");
        if(bytes(main).length == bytes(subString).length){
            return equals(main, subString);
        }else{
            for(uint i; i < bytes(main).length - bytes(subString).length; i++){
                if(equals(subString, getSlice(i, bytes(subString).length + i, main))){
                    return true;
                }
            }
            return false;
        }
    }
    // Inspired by: https://ethereum.stackexchange.com/questions/52246/solidity-extracting-slicing-characters-from-a-string
    function getSlice(uint begin, uint end, string memory text) public pure returns (string memory) {
        bytes memory a = new bytes(end - begin);
        for(uint i; i < end - begin; i++){
            a[i] = bytes(text)[begin + i];
        }
        return string(a);    
    }
    // Is a string equal to another?
    function equals(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
