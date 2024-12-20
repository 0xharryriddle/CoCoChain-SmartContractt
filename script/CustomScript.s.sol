// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Groth16Verifier} from "../src/Verifier.sol";
import {CoCoChain} from "../src/CoCoChain.sol";
import {AgriculturalProduct} from "../src/AgriculturalProduct.sol";

contract CustomScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address manufacturer = vm.envAddress("MANUFACTURER");
        address verifier = vm.envAddress("VERIFIER");
        address cocochain = vm.envAddress("COCOCHAIN");

        vm.startBroadcast(deployerPrivateKey);
        // CoCoChain cocoChain = new CoCoChain(manufacturer, verifier);
        AgriculturalProduct product = new AgriculturalProduct(cocochain);

        vm.stopBroadcast();
    }
}