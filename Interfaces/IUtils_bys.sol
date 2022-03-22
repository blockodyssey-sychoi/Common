// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Utils_bys{
    function toString(uint value) external returns (string memory);
    // Contains function. Returns true if a specified string contains another specified string
    function contains(string memory main, string memory subString) external pure returns (bool);
    // Inspired by: https://ethereum.stackexchange.com/questions/52246/solidity-extracting-slicing-characters-from-a-string
    // Returns the "slice" (substring) of a string
    function getSlice(uint begin, uint end, string memory text) external pure returns (string memory);
    // Returns true if a string is equal to another
    function equals(string memory a, string memory b) external pure returns (bool);
}
