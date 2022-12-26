// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;


//Import  for nft openzipline
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract nftmarket is ERC721URIStorage{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenID;
    Counters.Counter private _itemsSold;

    uint256 listingprice =0.0025 ether;
    
    address payable owner;

    mapping (uint256 => MarketItem) private idMarketItem;

    struct MarketItem{
        uint256 tokenID;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;

    }

    event MarketItemCreated(
        uint256 indexed tokenID,
        address seller,
        address owner,
        uint256 price,
        bool sold


    );

    modifier onlyowner(){
        require(
            msg.sender == owner,
            "only owner can change the lising price "
        );
        _;
    }



    constructor() ERC721("NFT Token", "TheNFT"){
        owner == payable(msg.sender);

    }

    function updatelistingprice(uint256 _listingprice) public payable onlyowner{
        listingprice = _listingprice;
    }

    function getlistingprice() public view returns(uint256){
        return listingprice;
    }

    //

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        _tokenID.increment();

        uint256 newtokenID= _tokenID.current();
        _mint(msg.sender, newtokenID);
        _setTokenURI(newtokenID, tokenURI);

        createmarketitem(newtokenID, price);

        return newtokenID;
    }

    function createmarketitem(uint256 tokenID, uint256 price) private{
        require(price > 0, "Price must be atleast 1");
        require(msg.value == lisingPrice, "Price must be equal to lising price");

        idMarketItem[tokenID] = MarketItem(
            tokenID,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenID);

        emit marketitemcreated(
            tokenID,msg.sender, address(this),price,false
        );

    }

    //Function for resale token

    function reselltoken(uint256 tokenID, uint256 price) public payable{
        require (idmarketitem[tokenID].owner ==msg.sender, "Only item owner can perform this task");

        require(msg.value == listingprice, "Price must be atleast listing price");
        
        idmarketitem[tokenID].sold=false;
        idmarketitem[tokenID].price = price;
        idmarketitem[tokenID].seller = payable(msg.sender);
        idmarketitem[tokenID].owner = payable(address(this));

        _itemsold.decrement(); 
        _transfer(msg.sender, address(this),tokenID);


    }

    //Function creakemarketsale

    function createmarketsale(uint256 tokenID) public payable{
        uint256 price = idmarketitem[tokenId].price;

        require (msg.value == price,"Enter the asking price only");

        idmarketitem[tokenID].owner = payable(msg.sender);
        idmarketitem[tokenID].sold = true;
        idmarketitem[tokenID].owner = payable(address(0));

        _itemsold.increment();
        _transfer(address(this), msg.sender, tokenID);
        payable(owner).transfer(lisingPrice);
        payable(idmarketitem[tokenID].seller).transfer(msg.value);

    
    }

    //Getting unsold NFts
    function fetchmarketitem() public view returns(Marketitem[] memory ){
        uint256 itemcount =_tokenIds.current();
        uint256 unsolditemcount = _tokenIds.current()- _itemsSold.current();
        uint256 currentindex =0;

        Marketitem[] memory items = new Marketitem[](unsolditemcount);
        for (uint256 i=0; i<itemcount; i++){
            if(idmarketitem[i+1].owner == address(this)){
                uint256 currentid=i+1;
                marketitem storage currentitem = idmarketitem[currentID];
                items[currentindex]= currentitem;
                currentindex +=1;

            }
        }
        return items;

    }

    //purchase item
    function fetchmynft() public view returns(marketitem[] memory){
        uint256 totalcount = _tokenIds.current();
        uint256 itemcount=0;
        uint256 currentindex =0;

        for(uint256 i=0; i<totalcount;i++){

            if (idMarketItem[i+1].owner == msg.sender){
                itemcount += 1;

            }
        }
        MarketItem[] memory items =new MarketItem[](itemcount);
        for(uint256 i=0; i< totalcount; i++){
            if(idMarketItem[i+1].owner == msg.sender){
            uint256 currentid =i+1;
            MarketItem storage currentitem = idMarketItem[currentid];
            items[currentindex] = currentitem;
            currentindex +=1;
            }

        }
        return items;


    }
    //Single User items
    function fetchitemslisted() public view returns(MarketItem[] memory){
        uint256 totalcount = _tokenids.current();
        uint256 itemcount = 0;
        uint256 currentindex=0;

        for(uint256 i= 0; i< totalcount;i++){
            if(idMarketItem[i+1].seller == msg.sender){
                itemcount +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemcount);
        for(uint256 i = 0; i<totalcount; i++){
            if(idMarketItem[i+1].seller== msg.sender){
                uint256 currentid =i+1;
                MarketItem storage currentitem = idMarketItem[currentid];
                items[currentindex]= currentitem;
                currentindex += 1;

            }
        }
        return items;
    }



}