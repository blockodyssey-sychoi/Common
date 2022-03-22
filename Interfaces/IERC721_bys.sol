// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";

interface ERC721_bys is IERC721, IERC721Metadata {

    function supportsInterface(bytes4 interfaceId) external view override returns (bool);

    function balanceOf(address owner) external view override returns (uint);

    function ownerOf(uint tokenId) external view override returns (address);

    function name() external view override returns (string memory);

    function symbol() external view override returns (string memory);

    function tokenURI(uint tokenId) external view override returns (string memory);

    function approve(address to, uint tokenId) external override;

    function getApproved(uint tokenId) external view override returns (address);

    function setApprovalForAll(address operator, bool _approved) external override;

    function isApprovedForAll(address owner, address operator) external view override returns (bool);

    function transferFrom(address from, address to, uint tokenId) external override;

    function safeTransferFrom(address from, address to, uint tokenId) external override;

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) external override;

    function _safeTransfer(address from, address to, uint tokenId, bytes memory _data) external;

    function _exists(uint tokenId) external view returns (bool);

    function _isApprovedOrOwner(address spender, uint tokenId) external view returns (bool);

    function _safeMint(address to, uint amount) external;

    function _safeMint(address to, bytes memory _data, uint amount) external;

    function _mint(address to, uint amount) external;

    function _burn(uint tokenId) external;

    function _transfer(address from, address to, uint tokenId) external;

    function _approve(address to, uint tokenId) external;

    function _setApprovalForAll(address owner, address operator, bool approved) external;

    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory _data) external returns (bool);

    function _beforeTokenTransfer(address from, address to, uint tokenId) external;

    function _afterTokenTransfer(address from, address to, uint tokenId) external;
}
