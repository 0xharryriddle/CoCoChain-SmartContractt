// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Groth16Verifier} from "../src/Verifier.sol";
import {CoCoChain} from "../src/CoCoChain.sol";
import {AgriculturalProduct} from "../src/AgriculturalProduct.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address manufacturer = vm.envAddress("MANUFACTURER");

        vm.startBroadcast(deployerPrivateKey);
        Groth16Verifier verifier = new Groth16Verifier();
        CoCoChain cocoChain = new CoCoChain(manufacturer, address(verifier));
        AgriculturalProduct product = new AgriculturalProduct(address(cocoChain));

        vm.stopBroadcast();
    }
}