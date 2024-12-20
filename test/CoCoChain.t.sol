// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BaseTest} from "./BaseTest.t.sol";

import {ICoCoChain} from "../src/interfaces/ICoCoChain.sol";

contract CoCoChainTest is BaseTest {

    function setUp() public override {
        super.setUp();
    }

    function test_addAgriculturalProduct() public {
        string memory metadataProduct = DEFAULT_URI;
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(metadataProduct);

        (uint256 id, string memory metadata, bool active) = cocoChain.products(0);

        assert(id == 0);
        assert(active == true);
        assertEq(metadata, metadataProduct);
    }

    function test_stopAgriculturalProduct() public {
        string memory metadataProduct = DEFAULT_URI;
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(metadataProduct);

        (uint256 id, string memory metadata, bool active) = cocoChain.products(0);

        assert(id == 0);
        assert(active == true);
        assertEq(metadata, metadataProduct);

        vm.prank(manufacturer);
        cocoChain.stopAgriculturalProduct(0);

        (, , active) = cocoChain.products(0);
        assert(active == false);
    }

    function test_modifierAgriculturalProduct() public {
        string memory metadataProduct = DEFAULT_URI;
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(metadataProduct);

        (uint256 id, string memory metadata, bool active) = cocoChain.products(0);

        assert(id == 0);
        assert(active == true);
        assertEq(metadata, metadataProduct);

        metadataProduct = string(abi.encode(uint160(1)));

        vm.prank(manufacturer);
        cocoChain.modifierAgriculturalProduct(0, metadataProduct);

        (, metadata,) = cocoChain.products(0);
        assertEq(metadata, metadataProduct);
    }

    function test_requestFarmer() public {
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(DEFAULT_URI);

        (uint256 id, string memory metadataProduct, bool activeProduct) = cocoChain.products(0);

        assert(id == 0);
        assert(activeProduct == true);
        assertEq(DEFAULT_URI, metadataProduct);

        address expectedFarmerAddress = farmers[0];

        vm.prank(expectedFarmerAddress);
        cocoChain.requestFarmer(id, DEFAULT_URI);

        (
            uint256 productId,
            address farmerAddress,
            string memory metadataFarmer,
            bool activeFarmer
        ) = cocoChain.farmers(0, expectedFarmerAddress);

        assert(productId == 0);
        assert(farmerAddress == expectedFarmerAddress);
        assertEq(metadataFarmer, DEFAULT_URI);
        assert(activeFarmer == false);
    }

    function test_addFarmer() public {
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(DEFAULT_URI);

        (uint256 id, string memory metadataProduct, bool activeProduct) = cocoChain.products(0);

        assert(id == 0);
        assert(activeProduct == true);
        assertEq(DEFAULT_URI, metadataProduct);

        address expectedFarmerAddress = farmers[0];

        vm.prank(expectedFarmerAddress);
        cocoChain.requestFarmer(id, DEFAULT_URI);

        (
            uint256 productId,
            address farmerAddress,
            string memory metadataFarmer,
            bool activeFarmer
        ) = cocoChain.farmers(0, expectedFarmerAddress);

        assert(productId == 0);
        assert(farmerAddress == expectedFarmerAddress);
        assertEq(metadataFarmer, DEFAULT_URI);
        assert(activeFarmer == false);

        vm.prank(manufacturer);
        cocoChain.addFarmer(productId, expectedFarmerAddress);
        (
            ,
            ,
            ,
            activeFarmer
        ) = cocoChain.farmers(0, expectedFarmerAddress);
        assert(activeFarmer == true);
    }

    function test_banFarmer() public {
        address manufacturer = manufacturers[0];

        vm.prank(manufacturer);
        cocoChain.addAgriculturalProduct(DEFAULT_URI);

        (uint256 id, string memory metadataProduct, bool activeProduct) = cocoChain.products(0);

        assert(id == 0);
        assert(activeProduct == true);
        assertEq(DEFAULT_URI, metadataProduct);

        address expectedFarmerAddress = farmers[0];

        vm.prank(expectedFarmerAddress);
        cocoChain.requestFarmer(id, DEFAULT_URI);

        (
            uint256 productId,
            address farmerAddress,
            string memory metadataFarmer,
            bool activeFarmer
        ) = cocoChain.farmers(0, expectedFarmerAddress);

        assert(productId == 0);
        assert(farmerAddress == expectedFarmerAddress);
        assertEq(metadataFarmer, DEFAULT_URI);
        assert(activeFarmer == false);

        vm.prank(manufacturer);
        cocoChain.addFarmer(productId, expectedFarmerAddress);
        (
            ,
            ,
            ,
            activeFarmer
        ) = cocoChain.farmers(0, expectedFarmerAddress);
        assert(activeFarmer == true);

        vm.prank(manufacturer);
        cocoChain.banFarmer(0, expectedFarmerAddress);

        (, , , activeFarmer) = cocoChain.farmers(0, expectedFarmerAddress);

        assert(activeFarmer == false);
    }

    function test_flipManufacturer() public {
        address manufacturer = manufacturers[0];

        assert(cocoChain.manufacturerIsApproved(manufacturer) == true);
        vm.prank(owner);
        cocoChain.flipManufacturer(manufacturer);
        assert(cocoChain.manufacturerIsApproved(manufacturer) == false);
    }

    function test_verifyProofSuccessfully() public view {
        uint256[2] memory pi_a = [uint256(12179243887309605240057378676853336302462326984573366832062778831064175406440), uint256(6290172423958439749976060493904374278527926044675193468465173569460677988728)];
        uint256[2][2] memory pi_b = [
            [
                uint256(18297313887178939583970702755167977638708912710548241985836483292766065876174),
                uint256(3612222687786136662689823505230993750812486427617780781573367214594995607722)
            ],
            [
                uint256(16336659433856759485534771068631444248736686945803424623137733824285624896236),
                uint256(10335436863847900249497482113527990087479283816458353939169182866621808440874)
            ]
        ];
        uint256[2]  memory pi_c = [
            uint256(18829205060501048047769764436688189593011681201743451837571437433462967629849),
            uint256(9629382810418767769228482342709161147122762666511251912264737275497711489944)
        ];
        uint256[2] memory publicSignals = [
            uint256(1),
            uint256(100)
        ];

        bool verified = verifier.verifyProof(pi_a, pi_b, pi_c, publicSignals);

        assert(verified == true);
    }

    function test_verifyProofFailed() public view {
        uint256[2] memory pi_a = [uint256(1109752515310295365162628241354404310195648987314638844239081556566017491465), uint256(950920608260099021898466014833760389170185084919784401327127568306752543773)];
        uint256[2][2] memory pi_b = [
            [
                uint256(8100608635491369901326166367063200290817181699707957872798616051832171313955),
                uint256(2723818419744843059425821946065390671188367218446132779247364949216983780669)
            ],
            [
                uint256(6810927489953793562720105410414963085250904262869091494486126760398363343990),
                uint256(10146018764267307963746761545351235372986885788875254245727982916411505706350)
            ]
        ];
        uint256[2]  memory pi_c = [
            uint256(8837810482328066198206523302216883669552987776729980992840989914916499601389),
            uint256(8837810482328066198206523302216883669552987776729980992840989914916499601389)
        ];
        uint256[2] memory publicSignals = [
            uint256(0),
            uint256(10)
        ];

        bool verified = verifier.verifyProof(pi_a, pi_b, pi_c, publicSignals);

        assert(verified == false);
    }
}