// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

 contract AgrimCryptoDevs is ERC721Enumerable, Ownable{

    string _baseTokenURI;

    IWhitelist whitelist;
    
    // @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
    // name in our case is `Agrim Crypto Devs` and symbol is `ACD`.
    // Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.

    bool public presaleStarted;

    uint256 public presaleEnded;

    uint256 public maxTokenIds = 10;

    uint256 public tokenIds;

    uint256 public _price = 0.01 ether;

    bool public _paused;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract is paused");
        _;
    }

    // It also initializes an instance of whitelist interface.
    // * In, this what I am doing is, whitelist is imported as Interface, which is providing me access to whitelisted addresses of my previous daap(whitelisted one). 
    // * Now, I give the interface the address (whitelistContract) of my whitelist contract, so the interface knows, which whitelist contract I have to call... that's why it is taking the address whitelistContract as input in constructor.

    constructor( string memory baseURI, address whitelistContract ) ERC721("Agrim Crypto Devs","ACD"){
        
        _baseTokenURI = baseURI;


        whitelist = IWhitelist(whitelistContract);
    
    }

        // * onlyOwner is a modifier coming from "ownable" we imported. it checks if the func is called only by owner, it won't allow anyone else.

    function startPresale() public onlyOwner{
        // * create a variable to know if presale has started.
        presaleStarted = true;

        // * track of when presale gonna be end.
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require( presaleStarted && block.timestamp < presaleEnded, "Presale Ended" );
        require(whitelist.whitelistedAddresses(msg.sender), "This address is not whitelisted and cannot mint.");
        require(tokenIds < maxTokenIds, "Exceeded the limit.");
        require(msg.value >= _price, "Ether sent is not sufficient ");
        tokenIds += 1;


        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);

    }

//* This is public mint.
// mint allows a user to mint 1 NFT per transaction after the presale has ended.
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "PreSale has not ended yet!");
        require(tokenIds < maxTokenIds, "Exceeded the limit.");
        require(msg.value >= _price, "Ether sent is not sufficient ");

        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);

    }

        /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }


    function setPaused( bool val ) public onlyOwner {
        _paused = val;
    }

    // * withdraw sends all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

      // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

 }