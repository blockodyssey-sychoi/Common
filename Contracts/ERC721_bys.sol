// SPDX-License-Identifier: MIT
// Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)
// Inspired from ERC721A (https://www.azuki.com/erc721a)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ERC721_bys is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint => address) private _owners;

    // Mapping from token ID to approved address
    mapping(uint => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Token Supply
    uint private tokenSupply;

    // Owner of the Contract
    address private owner;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint) {
        require(owner != address(0), "ERC721_bys: balance query for the zero address");
        uint balance;
        uint currentAmount;
        for(uint i; i < tokenSupply; i++){
            currentAmount++;
            if(_owners[i] != address(0)){
                if(_owners[i] == owner){
                    balance += currentAmount;
                }
                currentAmount = 0;
            }
        }
        return balance;
    }

    function ownerOf(uint tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721_bys: Invalid token provided");
        for(uint i = tokenId; i < tokenSupply; i++){
            if(_owners[i] != address(0)){
                return _owners[i];
            }
        }
        revert("ERC721_bys: Cannot find the owner of this token!");
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // It will be overridden
    function tokenURI(uint tokenId) public view virtual override returns (string memory) {}

    function approve(address to, uint tokenId) public virtual override {
        require(msg.sender == owner, "ERC721_bys: You cannot perform this action!");
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721_bys: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721_bys: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721_bys: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) public virtual override {
        require(msg.sender == owner, "ERC721_bys: You cannot perform this action!");
        _setApprovalForAll(_msgSender(), operator, _approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint tokenId) public virtual override {
        require(from != address(0) && to != address(0), "ERC721_bys: transfer to the zero address");
        require(ownerOf(tokenId) != to, "ERC721_bys: This address already owns this token");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721_bys: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721_bys: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721_bys: transfer to non ERC721Receiver implementer");
    }

    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721_bys: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint amount) internal virtual {
        _safeMint(to, "", amount);
    }

    function _safeMint(address to, bytes memory _data, uint amount) internal virtual {
        _mint(to, amount);
        for(uint i = tokenSupply; i > tokenSupply - amount; i--){
            require(_checkOnERC721Received(address(0), to, i, _data), "ERC721_bys: transfer to non ERC721Receiver implementer");
        }
    }

    function _mint(address to, uint amount) internal virtual {
        require(to != address(0), "ERC721_bys: mint to the zero address");
        require(amount > 0, "ERC721_bys: The mint amount must be greater than zero");

        _beforeTokenTransfer(address(0), to, tokenSupply);

        for(uint i; i < amount; i++){
            if(i == amount - 1){
                _owners[tokenSupply] = to;
            }
            tokenSupply++;
        }

        emit Transfer(address(0), to, tokenSupply);

        _afterTokenTransfer(address(0), to, tokenSupply);
    }

    function _burn(uint tokenId) internal virtual {
        require(msg.sender == ownerOf(tokenId),  "ERC721_bys: You must be the owner of the token for burning it");
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        if(_owners[tokenId] != address(0)){
            delete _owners[tokenId];
        }

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint tokenId) internal virtual {

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        if(tokenId > 0 && _owners[tokenId - 1] == address(0)){
            _owners[tokenId - 1] = from;
        }
        for(uint i = tokenId; i < tokenSupply; i++){
            if(_owners[i] != address(0)){
                if(_owners[i] != to){
                    _owners[tokenId] = to;
                }
            }
        }

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721_bys: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721_bys: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual {}
}
