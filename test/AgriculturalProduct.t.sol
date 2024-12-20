// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console} from "forge-std/Test.sol";

import {BaseTest} from "./BaseTest.t.sol";
import {ICoCoChain} from "../src/interfaces/ICoCoChain.sol";
import {IAgriculturalProduct} from "../src/interfaces/IAgriculturalProduct.sol";

contract AgriculturalProductTest is BaseTest {

    address public firstManufacturer;
    address public firstFarmer;

    function setUp() public override {
        super.setUp();
        firstManufacturer = manufacturers[0];
        firstFarmer = farmers[0];

        vm.prank(firstManufacturer);
        cocoChain.addAgriculturalProduct(DEFAULT_URI);
        vm.prank(firstFarmer);
        cocoChain.requestFarmer(0, DEFAULT_URI);
        vm.prank(firstManufacturer);
        cocoChain.addFarmer(0, firstFarmer);
        vm.stopPrank();
    }

    function test_plantSeed() public {
        uint256 expectedCocoChainId = 0;
        uint256 productId = 0;
        (
            uint256 tokenId,
            uint256 cocoChainId,
            address farmer,
            ,
            uint256 eventCount,
            uint256 harvestCount
        )  = product.products(productId);

        assert(farmer == address(0));
        assert(tokenId == 0);
        assert(cocoChainId == 0);
        assert(eventCount == 0);
        assert(harvestCount == 0);

        vm.prank(firstFarmer);
        product.plantSeed(expectedCocoChainId, DEFAULT_URI, DEFAULT_URI);
        assert(product.balanceOf(firstFarmer) == 1);
        assertEq(product.tokenURI(productId), DEFAULT_URI);

        (
            tokenId,
            cocoChainId,
            farmer,
            ,
            eventCount,
            harvestCount
        )  = product.products(productId);
        assert(farmer == firstFarmer);
        assert(tokenId == productId);
        assert(cocoChainId == expectedCocoChainId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        assert(eventCount == 1);
        assert(harvestCount == 0);
        assert(eventType == IAgriculturalProduct.EventType.PLANT);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstFarmer);
        assert(delivered == false);
    }

    function test_fertilize() public {
        uint256 expectedCocoChainId = 0;
        uint256 productId = 0;
        vm.startPrank(firstFarmer);
        product.plantSeed(expectedCocoChainId, DEFAULT_URI, DEFAULT_URI);
        product.fertilize(expectedCocoChainId, productId, DEFAULT_URI);
        vm.stopPrank();

        (
            ,
            ,
            ,
            ,
            uint256 eventCount,
            uint256 harvestCount
        ) = product.products(productId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        assert(eventCount == 2);
        assert(harvestCount == 0);
        assert(eventType == IAgriculturalProduct.EventType.FERTILIZE);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstFarmer);
        assert(delivered == false);
    }

    function test_spray() public {
        uint256 cocoChainId = 0;
        uint256 productId = 0;
        vm.startPrank(firstFarmer);
        product.plantSeed(cocoChainId, DEFAULT_URI, DEFAULT_URI);
        product.spray(cocoChainId, productId, DEFAULT_URI);
        vm.stopPrank();

        (
            ,
            ,
            ,
            ,
            uint256 eventCount,
            uint256 harvestCount
        ) = product.products(productId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        assert(eventCount == 2);
        assert(harvestCount == 0);
        assert(eventType == IAgriculturalProduct.EventType.SPRAY);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstFarmer);
        assert(delivered == false);
    }

    function test_water() public {
        uint256 cocoChainId = 0;
        uint256 productId = 0;
        vm.startPrank(firstFarmer);
        product.plantSeed(cocoChainId, DEFAULT_URI, DEFAULT_URI);
        product.water(cocoChainId, productId, DEFAULT_URI);
        vm.stopPrank();

        (
            ,
            ,
            ,
            ,
            uint256 eventCount,
            uint256 harvestCount
        ) = product.products(productId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        assert(eventCount == 2);
        assert(harvestCount == 0);
        assert(eventType == IAgriculturalProduct.EventType.WATER);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstFarmer);
        assert(delivered == false);
    }

    function test_harvest() public {
        uint256 cocoChainId = 0;
        uint256 productId = 0;
        vm.startPrank(firstFarmer);
        product.plantSeed(cocoChainId, DEFAULT_URI, DEFAULT_URI);
        product.harvest(cocoChainId, productId, DEFAULT_URI);
        vm.stopPrank();

        (
            ,
            ,
            ,
            ,
            uint256 eventCount,
            uint256 harvestCount
        ) = product.products(productId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        (
            IAgriculturalProduct.EventType eventTypeHarvest,
            string memory metadataHarvest,
            ,
            address performerHarvest,
            bool deliveredHarvest
        ) = product.harvestHistories(productId, harvestCount - 1);

        assert(eventCount == 1);
        assert(eventType == IAgriculturalProduct.EventType.PLANT);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstFarmer);
        assert(delivered == false);

        assert(harvestCount == 1);
        assert(eventTypeHarvest == IAgriculturalProduct.EventType.HARVEST);
        assertEq(metadataHarvest, DEFAULT_URI);
        assert(performerHarvest == firstFarmer);
        assert(deliveredHarvest == false);
    }

    function test_delivery() public {
        uint256 cocoChainId = 0;
        uint256 productId = 0;
        vm.startPrank(firstFarmer);
        product.plantSeed(cocoChainId, DEFAULT_URI, DEFAULT_URI);
        product.harvest(cocoChainId, productId, DEFAULT_URI);
        vm.stopPrank();
        vm.prank(firstManufacturer);
        product.delivery(productId, DEFAULT_URI);

        (
            ,
            ,
            ,
            ,
            uint256 eventCount,
            uint256 harvestCount
        ) = product.products(productId);

        (
            IAgriculturalProduct.EventType eventType,
            string memory metadata,
            ,
            address performer,
            bool delivered
        ) = product.eventHistories(productId, eventCount - 1);

        (
            IAgriculturalProduct.EventType eventTypeHarvest,
            string memory metadataHarvest,
            ,
            address performerHarvest,
            bool deliveredHarvest
        ) = product.harvestHistories(productId, harvestCount - 1);

        assert(eventCount == 2);

        assert(eventType == IAgriculturalProduct.EventType.DELIVERY);
        assertEq(metadata, DEFAULT_URI);
        assert(performer == firstManufacturer);
        assert(delivered == false);

        assert(harvestCount == 1);
        assert(eventTypeHarvest == IAgriculturalProduct.EventType.HARVEST);
        assertEq(metadataHarvest, DEFAULT_URI);
        assert(performerHarvest == firstFarmer);
        assert(deliveredHarvest == true);
    }
}