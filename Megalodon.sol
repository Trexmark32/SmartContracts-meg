// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Megalodon is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address private _owner;
    address public constant teamMegAddress =
        0xdD870fA1b7C4700F2BD7f44238821C26f7392148; // change the address before deploy
    uint256 public mintCost = 0.0015 ether;
    uint256 public selfMintCost = 0.001 ether;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event withdrawBal(address Sender, address Receiver, uint256 balance);
    event NFTminted(address NFTowner, uint256 tokenId, string uri);

    constructor() ERC721("Megalodon", "MEG") {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "must be owner");
        _;
    }

    function owner() public view onlyOwner returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function safeMintOwner(address to, string memory uri) public onlyOwner {
        _minter(to, uri);
    }

    function safeMintCreator(string memory uri) public payable {
        require(msg.value >= selfMintCost, "insufficient ether");
        _minter(msg.sender, uri);
    }

    function safeMintUser(string memory uri) public payable {
        require(msg.value >= mintCost, "insufficient ether");
        _minter(msg.sender, uri);
    }

    function _minter(address to, string memory uri) internal {
        require(to != address(0), "invalid address");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit NFTminted(to, tokenId, uri);
    }

    function withdraw() external onlyOwner {
        emit withdrawBal(address(this), teamMegAddress, address(this).balance);
        payable(teamMegAddress).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
