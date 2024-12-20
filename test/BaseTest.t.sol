// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {IVerifier} from "../src/interfaces/IVerifier.sol";
import {Groth16Verifier as Verifier} from "../src/Verifier.sol";
import {CoCoChain} from "../src/CoCoChain.sol";
import {AgriculturalProduct} from "../src/AgriculturalProduct.sol";

contract BaseTest is Test{

    bytes32 public constant DEFAULT_PROOF = bytes32(0);
    string public DEFAULT_URI = "DEFAULT_URI";

    Verifier public verifier;
    CoCoChain public cocoChain;
    AgriculturalProduct public product;

    address public owner = makeAddr("owner");
    address[] public manufacturers;
    address[] public farmers;

    function setUp() public virtual {
        for (uint256 i = 0; i < 100; i++) {
            address manufacturer = makeAddr(string(abi.encodePacked("manufacturer", Strings.toString(i))));
            address farmer = makeAddr(string(abi.encodePacked("farmer", Strings.toString(i))));
            manufacturers.push(manufacturer);
            farmers.push(farmer);
        }
        vm.startPrank(owner);
        verifier = new Verifier();
        cocoChain = new CoCoChain(manufacturers[0], address(verifier));
        product = new AgriculturalProduct(address(cocoChain));
        cocoChain.initialize(address(product));
        vm.stopPrank();
    }
}