// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoCoChain {
    struct Product {
        uint256 id;
        string metadata;
        bool active;
    }

    struct Farmer {
        uint256 productId;
        address farmerAddress;
        string metadata;
        bool active;
    }

    function initialize(address _productNFT) external;

    function addAgriculturalProduct(string memory metadata) external;

    function stopAgriculturalProduct(uint256 productId) external;

    function modifierAgriculturalProduct(uint256 productId, string memory metadata) external;

    function requestFarmer(uint256 productId, string memory metadata) external;

    function addFarmer(uint256 productId, address farmerAddress) external;

    function banFarmer(uint256 productId, address farmerAddress) external;

    function flipManufacturer(address _manufacturer) external;

    // View functions

    function farmerIsApproved(uint256, address) external view returns(bool);

    function manufacturerIsApproved(address) external view returns(bool);

    function productCount() external view returns(uint256);

    function products(uint256) external view returns(uint256, string memory, bool);

    function farmers(uint256, address) external view returns(uint256, address, string memory, bool);
}