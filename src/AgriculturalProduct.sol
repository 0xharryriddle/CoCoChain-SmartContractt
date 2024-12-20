// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAgriculturalProduct} from "./interfaces/IAgriculturalProduct.sol";
import {ICoCoChain} from "./interfaces/ICoCoChain.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Agricultural Product tokenizing into ERC721
contract AgriculturalProduct is ERC721, ERC721URIStorage, IAgriculturalProduct {

    /* ---------------------------------- EVENT --------------------------------- */
    event EventLogged(uint256 indexed cocoChainId, uint256 indexed productId, Event eventProduct);

    bytes32 public constant DEFAULT_PROOF = bytes32(0);

    address public immutable COCO_CHAIN;

    // mapping(uint256 => Product) public override products;

    mapping(uint256 => Product) public products;

    /* ------------------ productId => eventId => EventHistory ------------------ */
    mapping(uint256 => mapping(uint256 => Event)) public eventHistories; // Without harvest

    mapping(uint256 => mapping(uint256 => Event)) public harvestHistories;

    uint256 private _nextProductId;

    modifier onlyCoCoChain() {
        require(msg.sender == COCO_CHAIN, "Not CoCoChain");
        _;
    }

    modifier onlyAuthorizedFarmer(uint256 cocoChainId) {
        require(ICoCoChain(COCO_CHAIN).farmerIsApproved(cocoChainId, msg.sender), "Not authorized farmer");
        _;
    }

    modifier onlyManufacturer() {
        require(ICoCoChain(COCO_CHAIN).manufacturerIsApproved(msg.sender), "Not manufacturer");
        _;
    }

    constructor(
        address cocoChain
    ) ERC721("Agricultural Product", "CoCoChain") {
        COCO_CHAIN = cocoChain;
    }

    function plantSeed(uint256 cocoChainId, string memory _tokenURI, string memory metadata) external onlyAuthorizedFarmer(cocoChainId) {
        address sender = msg.sender;
        require(cocoChainId < ICoCoChain(COCO_CHAIN).productCount(), "Product in CoCoChain is not supported yet");
        uint256 productId = _nextProductId++;
        Product memory product = products[productId];
        require(product.createdAt == 0, "Product already exists");
        Event memory eventPlant = Event({
            eventType: EventType.PLANT,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: sender,
            delivered: false
        });
        
        product.tokenId = productId;
        product.cocoChainId = cocoChainId;
        product.farmer = sender;
        product.createdAt = block.timestamp;
        product.eventCount = 0;
        product.harvestCount = 0;

        eventHistories[productId][product.eventCount++] = eventPlant;
        products[productId] = product;

        _setTokenURI(productId, _tokenURI);
        _safeMint(msg.sender, productId);

        emit EventLogged(cocoChainId, productId, eventPlant);
    }

    function fertilize(uint256 cocoChainId, uint256 productId, string memory metadata) external override onlyAuthorizedFarmer(cocoChainId) {
        address sender = msg.sender;
        Product memory product = products[productId];
        require(product.farmer == sender && product.tokenId == productId, "Not own this product");
        Event memory eventFertilize = Event({
            eventType: EventType.FERTILIZE,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: sender,
            delivered: false
        });
        
        eventHistories[productId][product.eventCount++] = eventFertilize;
        products[productId] = product;

        emit EventLogged(cocoChainId, productId, eventFertilize);
    }

    function spray(uint256 cocoChainId, uint256 productId, string memory metadata) external override onlyAuthorizedFarmer(cocoChainId) {
        address sender = msg.sender;
        Product memory product = products[productId];
        require(product.farmer == sender && product.tokenId == productId, "Not own this product");
        Event memory eventSpray = Event({
            eventType: EventType.SPRAY,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: sender,
            delivered: false
        });
        
        eventHistories[productId][product.eventCount++] = eventSpray;
        products[productId] = product;

        emit EventLogged(cocoChainId, productId, eventSpray);
    }

    function water(uint256 cocoChainId, uint256 productId, string memory metadata) external override onlyAuthorizedFarmer(cocoChainId) {
        address sender = msg.sender;
        Product memory product = products[productId];
        require(product.farmer == sender && product.tokenId == productId, "Not own this product");
        Event memory eventWatering = Event({
            eventType: EventType.WATER,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: sender,
            delivered: false
        });
        
        eventHistories[productId][product.eventCount++] = eventWatering;
        products[productId] = product;

        emit EventLogged(cocoChainId, productId, eventWatering);
    }

    function delivery(uint256 productId, string memory metadata) external override onlyManufacturer {
        Product memory product = products[productId];
        require(
            product.tokenId == productId && 
            productId < _nextProductId && 
            product.createdAt != 0 && 
            product.harvestCount > 0 &&
            harvestHistories[productId][product.harvestCount - 1].delivered == false, 
        "Product is not harvested");
        Event memory eventDelivery = Event({
            eventType: EventType.DELIVERY,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: msg.sender,
            delivered: false
        });
        
        eventHistories[productId][product.eventCount++] = eventDelivery;
        harvestHistories[productId][product.harvestCount - 1].delivered = true;
        products[productId] = product;
        
        emit EventLogged(product.cocoChainId, productId, eventDelivery);
    }

    function harvest(uint256 cocoChainId, uint256 productId, string memory metadata) external override onlyAuthorizedFarmer(cocoChainId) {
        address sender = msg.sender;
        Product memory product = products[productId];
        require(
            product.farmer == sender && 
            product.tokenId == productId && 
            productId < _nextProductId && 
            product.createdAt != 0 && 
            (product.harvestCount == 0 || harvestHistories[productId][product.harvestCount - 1].delivered == true), 
        "Product has had to deliver first");
        Event memory eventHarvest = Event({
            eventType: EventType.HARVEST,
            metadata: metadata,
            timestamp: block.timestamp,
            performer: sender,
            delivered: false
        });

        harvestHistories[productId][product.harvestCount++] = eventHarvest;

        products[productId] = product;

        emit EventLogged(cocoChainId, productId, eventHarvest);
    }

    /* ---------------------------------- VIEW ---------------------------------- */

    /* -------------------------------- OVERRIDE -------------------------------- */

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}