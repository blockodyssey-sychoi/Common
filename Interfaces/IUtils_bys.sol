// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Utils_bys{
    function toString(uint value) external returns (string memory);
    // Does a string contain another one?
    function contains(string memory main, string memory subString) external pure returns (bool);
    // Inspired by: https://ethereum.stackexchange.com/questions/52246/solidity-extracting-slicing-characters-from-a-string
    function getSlice(uint begin, uint end, string memory text) external pure returns (string memory);
    // Is a string equal to another?
    function equals(string memory a, string memory b) external pure returns (bool);
}
