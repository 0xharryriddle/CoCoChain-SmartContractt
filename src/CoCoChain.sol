// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ICoCoChain} from "./interfaces/ICoCoChain.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";
import {AgriculturalProduct} from "./AgriculturalProduct.sol";

contract CoCoChain is ICoCoChain, Ownable {

    address public immutable VERIFIER;

    mapping(address => bool) internal MANUFACTURERS;

    bool public initialized;

    uint256 public override productCount;

    AgriculturalProduct public productNFT;

    mapping(uint256 => Product) public override products;

    mapping(uint256 => mapping(address => Farmer)) override public farmers;

    /* --------------------------------- EVENTS --------------------------------- */
    event ProductRegistered(uint256 indexed productId);
    event ProductStopped(uint256 indexed productId);
    event ProductUpdated(uint256 indexed productId);
    event FarmerRequested(uint256 indexed productId);
    event FarmerAdded(uint256 indexed productId, address indexed farmerAddress);
    event FarmerBanned(uint256 indexed productId, address indexed farmerAddress);

    modifier onlyInitialized() {
        require(initialized, "Not Initialized");
        _;
    }

    modifier onlyManufacturer() {
        require(MANUFACTURERS[msg.sender], "Only Manufacturer");
        _;
    }

    constructor(address _manufacturer, address verifier) Ownable(msg.sender) {
        MANUFACTURERS[_manufacturer] = true;
        VERIFIER = verifier;
    }

    function initialize(address _productNFT) external override {
        require(!initialized, "Initialized");
        productNFT = AgriculturalProduct(_productNFT);
    }

    function addAgriculturalProduct(string memory metadata) external override onlyManufacturer {
        uint256 productId = productCount++;
        Product memory newProduct = Product({
            id: productId,
            metadata: metadata,
            active: true
        });

        products[productId] = newProduct;   
        emit ProductRegistered(productId);
    }

    function stopAgriculturalProduct(uint256 productId) external override onlyManufacturer {
        require(productId < productCount, "Exceed count");
        Product memory product = products[productId];
        require(product.active, "Product is not active yet");
        products[productId].active = false;
        emit ProductStopped(productId);
    }

    function modifierAgriculturalProduct(
        uint256 productId,
        string memory metadata
    ) external override onlyManufacturer {
        require(productId < productCount, "Exceed count");
        Product memory product = products[productId];
        Product memory newProduct = Product({
            id: productId,
            metadata: metadata,
            active: product.active
        });

        products[productId] = newProduct;

        emit ProductUpdated(productId);
    }

    function requestFarmer(
        uint256 productId,
        string memory metadata
    ) external override {
        require(productId < productCount, "Exceed count");
        address farmerAddress = msg.sender;
        Farmer memory farmer = farmers[productId][farmerAddress];
        require(farmer.farmerAddress == address(0), "Already requested");
        farmer.productId = productId;
        farmer.farmerAddress = farmerAddress;
        farmer.metadata = metadata;
        
        farmers[productId][farmerAddress] = farmer;

        emit FarmerRequested(productId);
    }

    function addFarmer(
        uint256 productId,
        address farmerAddress
    ) external override onlyManufacturer {
        require(productId < productCount, "Exceed count");
        Farmer memory farmer = farmers[productId][farmerAddress];
        require(!farmer.active, "Farmer is already active");

        farmers[productId][farmerAddress].active = true;

        emit FarmerAdded(productId, farmerAddress);
    }

    function banFarmer(uint256 productId, address farmerAddress) external override onlyManufacturer {
        require(productId < productCount, "Exceed count");
        Farmer memory farmer = farmers[productId][farmerAddress];
        require(farmer.active, "Farmer is not active currently");

        farmers[productId][farmerAddress].active = false;

        emit FarmerBanned(productId, farmerAddress);
    }

    function flipManufacturer(address _manufacturer) external override onlyOwner {
        MANUFACTURERS[_manufacturer] = !MANUFACTURERS[_manufacturer];
    }

    /* ----------------------------- View functions ----------------------------- */

    function farmerIsApproved(uint256 productId, address farmerAddress) external view override returns(bool) {
        Farmer memory farmer = farmers[productId][farmerAddress];
        return farmer.farmerAddress == farmerAddress;
    }

    function manufacturerIsApproved(address manufacturer) external view override returns(bool) {
        return MANUFACTURERS[manufacturer];
    }

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[2] calldata _pubSignals
    ) external view returns (bool) {
        return IVerifier(VERIFIER).verifyProof(_pA, _pB, _pC, _pubSignals);
    }
}