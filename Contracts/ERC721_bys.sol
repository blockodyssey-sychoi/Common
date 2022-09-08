// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Imports - The smart contract musts inherit the Ownable functionalities
import "./Ownable.sol";
// It must interact with an utils smart contract
import "../interfaces/Utils_interface.sol";
// Default imports of ERC721
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
// ERC721_bys Contract:
contract ERC721_bys is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint;
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Token base URI
    string private baseURI;
    // Mapping from token ID to owner address
    mapping(uint => address) private owners;
    // Mapping from token ID to approved address
    mapping(uint => address) private tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;
    // Mapping for the burned tokens
    mapping(uint => bool) private burnedTokens;
    uint burnedN;
    // Utils Smart Contract
    Utils_interface utils;
    // Token Supply
    uint private tokenSupply;
    // First tokenId of the collection
    uint private startingId;
    // Constructor:
    constructor(string memory name_, string memory symbol_, uint _startingId, address _utils) Ownable () {
        _name = name_;
        _symbol = symbol_;
        startingId = _startingId;
        utils = Utils_interface(_utils);
    }
    // _name
    function setName(string memory name_) public virtual{
        require (isAdminOrFounder(msg.sender), "ERC721_bys: You cannot perform this action!");
        require(!utils.equals(_name, name_), "The contract has currently the same name!");
        _name = name_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    // _symbol
    function setSymbol(string memory symbol_) public{
        require (isAdminOrFounder(msg.sender), "ERC721_bys: You cannot perform this action!");
        require(!utils.equals(_symbol, symbol_), "The contract has the same symbol!");
        _symbol = symbol_;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    // supportsInterface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    // balanceOf
    function balanceOf(address owner) public view virtual override returns (uint) {
        require(owner != address(0), "ERC721_bys: balance query for the zero address");
        uint balance;
        uint currentAmount;
        for(uint i = startingId; i < tokenSupply + startingId; i++){
            if(!burnedTokens[i]){
                currentAmount++;
            }
            if(owners[i] != address(0)){
                if(owners[i] == owner){
                    balance += currentAmount;
                }
                currentAmount = 0;
            }
        }
        return balance;
    }
    // ownerOf
    function ownerOf(uint tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721_bys: Invalid token provided");
        for(uint i = tokenId; i < tokenSupply + startingId; i++){
            if(owners[i] != address(0)){
                return owners[i];
            }else if(burnedTokens[tokenId]){
                return address(0);
            }
        }
        revert("ERC721_bys: Cannot find the owner of this token!");
    }
    // tokenSupply
    function getTokenSupply() public view virtual returns (uint){
        return tokenSupply - burnedN;
    }
    // baseURI
    function setBaseURI(string memory _baseURI) public virtual{
        require(isAdminOrFounder(msg.sender), "You cannot perform this action!");
        require(!utils.equals(_baseURI, baseURI), "The same URI is already specified!");
        baseURI = _baseURI;
    }
    function getBaseURI() internal virtual view returns (string memory){
        return baseURI;
    }
    function tokenURI(uint _tokenId) public virtual view override returns (string memory) {
        require(_exists(_tokenId), "The token specified does not exists!");
        string memory uri = string(abi.encodePacked(baseURI, "/", Utils_interface(utils).toString(_tokenId), ".json"));
        require(bytes(uri).length > 0, "Cannot find the specified token");
        return uri;
    }
    // startingId
    function getStartingId() public view returns(uint){
        return startingId;
    }
    // approval
    function approve(address to, uint tokenId) public virtual override {
        require(isAdminOrFounder(msg.sender), "ERC721_bys: You cannot perform this action!");
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

        return tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool _approved) public virtual override {
        require(isAdminOrFounder(msg.sender), "ERC721_bys: You cannot perform this action!");
        _setApprovalForAll(_msgSender(), operator, _approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {                                                                                                                                                                                                                                    // // //
        return operatorApprovals[owner][operator];                                                                                                                                                                                                                                                                                              //      //
    }                                                                                                                                                                                                                                                                                                                                           // // //
    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns (bool) {                                                                                                                                                                                                                                           //      //
        require(_exists(tokenId), "ERC721_bys: operator query for nonexistent token");                                                                                                                                                                                                                                                          // // //
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _approve(address to, uint tokenId) internal virtual {
        tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721_bys: approve to caller");
        operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    // transfers
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
    function _transfer(address from, address to, uint tokenId) internal virtual {

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        if(tokenId > startingId && owners[tokenId - 1] == address(0)){
            owners[tokenId - 1] = from;
        }
        for(uint i = tokenId; i < tokenSupply + startingId; i++){
            if(owners[i] != address(0)){
                if(owners[i] != to){
                    owners[tokenId] = to;
                }
            }
        }

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }
    // mint
    function _safeMint(address to, uint amount) internal virtual {
        _safeMint(to, "", amount);
    }
    function _safeMint(address to, bytes memory _data, uint amount) internal virtual {
        _mint(to, amount);
        for(uint i = tokenSupply + startingId; i > tokenSupply + startingId - amount; i--){
            require(_checkOnERC721Received(address(0), to, i, _data), "ERC721_bys: transfer to non ERC721Receiver implementer");
        }
    }
    function _mint(address to, uint amount) public virtual {
        require(to != address(0), "ERC721_bys: mint to the zero address");
        require(amount > 0, "ERC721_bys: The mint amount must be greater than zero");

        uint currentToken = startingId + tokenSupply;
        for(uint i = currentToken; i < currentToken + amount; i++){
            _beforeTokenTransfer(address(0), to, i);


            if(i == currentToken + amount - 1){
                owners[i] = to;
            }

            emit Transfer(address(0), to, i);
            _afterTokenTransfer(address(0), to, i);
            
            tokenSupply++;
        }
    }
    // burn
    function _burn(uint tokenId) public virtual {
        require(msg.sender == ownerOf(tokenId),  "ERC721_bys: You must be the owner of the token for burning it");
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        if(owners[tokenId] != address(0)){
            if(ownerOf(tokenId - 1) == msg.sender){
                owners[tokenId - 1] = msg.sender;
            }
            burnedTokens[tokenId] = true;
            owners[tokenId] = address(0);
            burnedN++;
        }

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }
    // checks
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
    function _exists(uint tokenId) internal view virtual returns (bool) {
        return (tokenId < (tokenSupply + startingId) && tokenId >= startingId) ;
    }
    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual {}
    // default withdraw
    function withdraw() public virtual{
        require(isAdminOrFounder(msg.sender), "GlimmersOfHome - You cannot perform this action!");
        require(address(this).balance > 0 wei, "This contract has no funds");
        payable(msg.sender).transfer(address(this).balance);
    }
}
