// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";

interface ERC721_bys is IERC721, IERC721Metadata {
    // Same function as in ERC721
    function supportsInterface(bytes4 interfaceId) external view override returns (bool);
    // Enhanced function that uses the \_owners map to determine the balance of a given address
    function balanceOf(address owner) external view override returns (uint);
    // Enhanced function of ERC721
    function ownerOf(uint tokenId) external view override returns (address);
    // Same function as in ERC721 
    function name() external view override returns (string memory);
    // Same function as in ERC721 
    function symbol() external view override returns (string memory);
    // Enhanced function that determines the URI just from the tokenId and other parameters
    function tokenURI(uint tokenId) external view override returns (string memory);
    // Same function as in ERC721 
    function approve(address to, uint tokenId) external override;
    // Same function as in ERC721 
    function getApproved(uint tokenId) external view override returns (address);
    // Same function as in ERC721 
    function setApprovalForAll(address operator, bool _approved) external override;
    // Same function as in ERC721 
    function isApprovedForAll(address owner, address operator) external view override returns (bool);
    // Enhanced function for transferring NFTs. It modifies only the \_owners map
    function transferFrom(address from, address to, uint tokenId) external override;
    // Same function as in ERC721 
    function safeTransferFrom(address from, address to, uint tokenId) external override;
    // Same function as in ERC721 
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) external override;
    // Same function as in ERC721 
    function _safeTransfer(address from, address to, uint tokenId, bytes memory _data) external;
    // If the tokenId is less then the tokenSupply and the owner of the token is not address(0) returns true, otherwise false
    function _exists(uint tokenId) external view returns (bool);
    // Same function as in ERC721 
    function _isApprovedOrOwner(address spender, uint tokenId) external view returns (bool);
    // Enhanced function that uses the tokenSupply and the amount given for safe-minting tokens
    function _safeMint(address to, uint amount) external;
    // Enhanced function that uses the tokenSupply and the amount given for safe-minting tokens
    function _safeMint(address to, bytes memory _data, uint amount) external;
    // Enhanced function that uses the tokenSupply and the amount given for minting tokens
    function _mint(address to, uint amount) external;
    // Same function as in ERC721 
    function _burn(uint tokenId) external;
    // Function adapted to the usage in this smart contract. Modifies the \_owners map
    function _transfer(address from, address to, uint tokenId) external;
    // Same function as in ERC721 
    function _approve(address to, uint tokenId) external;
    // Same function as in ERC721 
    function _setApprovalForAll(address owner, address operator, bool approved) external;
    // Same function as in ERC721 
    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory _data) external returns (bool);
    // Enhanced function
    function _exists(uint256 tokenId) external view returns (bool;
    // Same function as in ERC721 
    function _beforeTokenTransfer(address from, address to, uint tokenId) external;
    // Same function as in ERC721 
    function _afterTokenTransfer(address from, address to, uint tokenId) external;
}
