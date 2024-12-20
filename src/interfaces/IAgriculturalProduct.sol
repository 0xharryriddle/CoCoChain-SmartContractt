// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAgriculturalProduct {

    enum EventType {
        PLANT,
        FERTILIZE,
        SPRAY,
        WATER,
        HARVEST,
        DELIVERY
    }

    struct Event {
        EventType eventType;
        string metadata;
        uint256 timestamp;
        address performer;
        bool delivered;
    }

    struct Product {
        uint256 tokenId;
        uint256 cocoChainId;
        address farmer;
        uint256 createdAt;
        uint256 eventCount;
        uint256 harvestCount;
    }

    struct ZKProofInputs {
        uint256 tokenId;
        EventType eventType;
        uint256 standardId;
        uint256 maxAllowedValue;
        bytes32 eventDetailsHash;
        address performer;
        uint256 timestamp;
        uint256 quantity;
        string location;
        bytes proof;
    }

    function plantSeed(uint256 cocoChainId, string memory _tokenURI, string memory metadata) external;

    function fertilize(uint256 cocoChainId, uint256 tokenId, string memory metadata) external;

    function spray(uint256 cocoChainId, uint256 productId, string memory metadata) external;

    function water(uint256 cocoChainId, uint256 tokenId, string memory metadata) external;

    function harvest(uint256 cocoChainId, uint256 tokenId, string memory metadata) external;

    function delivery(uint256 tokenId, string memory metadata) external;

    /* ------------------------------ View function ----------------------------- */
}