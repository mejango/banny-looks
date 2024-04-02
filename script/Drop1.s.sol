// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {JB721TierConfig} from "@bananapus/721-hook/src/structs/JB721TierConfig.sol";
import {JB721TieredHook} from "@bananapus/721-hook/src/JB721TieredHook.sol";

import {Sphinx} from "@sphinx-labs/contracts/SphinxPlugin.sol";
import {Script} from "forge-std/Script.sol";

import {Banny721TokenUriResolver} from "./../src/Banny721TokenUriResolver.sol";

contract Drop1Script is Script, Sphinx {
    /// @notice tracks the deployment of the 721 hook contracts for the chain we are deploying to.
    JB721TieredHook hook;

    BannyverseRevnetConfig bannyverseConfig;

    uint256 PREMINT_CHAIN_ID = 1;
    bytes32 SALT = "BANNYVERSE";
    bytes32 SUCKER_SALT = "BANNYVERSE_SUCKER";
    bytes32 RESOLVER_SALT = "Banny721TokenUriResolver";

    address OPERATOR = 0x817738DC393d682Ca5fBb268707b99F2aAe96baE;
    address TRUSTED_FORWARDER = 0xB2b5841DBeF766d4b521221732F9B618fCf34A87;

    function configureSphinx() public override {
        // TODO: Update to contain revnet devs.
        sphinxConfig.owners = [0x26416423d530b1931A2a7a6b7D435Fac65eED27d];
        sphinxConfig.orgId = "cltepuu9u0003j58rjtbd0hvu";
        sphinxConfig.projectName = "bannyverse-core";
        sphinxConfig.threshold = 1;
        sphinxConfig.mainnets = ["ethereum", "optimism"];
        sphinxConfig.testnets = ["ethereum_sepolia", "optimism_sepolia"];
        sphinxConfig.saltNonce = 6;
    }

    function run() public {
        address producer;

        // Get the deployment addresses for the 721 hook contracts for this chain.
        hook = Hook721Deployment(0xB2b5841DBeF766d4b521221732F9B618fCf34A87);

        // The project's NFT tiers.
        JB721TierConfig[] memory tiers = new JB721TierConfig[](30);

        // Astronaut Body
        tiers[0] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x9639b46715172ad9d838ea37014b1c43c70365b15857ef955d96891239e58af0"),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Head
        tiers[1] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x19830ffcbccfc3f36147eedf5d8eb9bb3a848cd83fb6d678951b85da8e1ed944"),
            category: 4,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        tiers[2] = JB721TierConfig({
            price: uint104(15 * 10 ** (decimals - 1)),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x02e7e97b235567a77cd029baaad84bdebae9649ac431c9631e7fb56e17b76a40"),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Bandolph staff
        tiers[3] = JB721TierConfig({
            price: uint104(125 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x4bec1f322ec29571a78642d691e8ddf9532c0f73619ddeca1f02d8eac62fedc8"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Banny vision pro 
        tiers[4] = JB721TierConfig({
            price: uint104(1 * 10 ** decimals),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: producer,
            encodedIPFSUri: bytes32("0xea4a659665860960deaeb2e7315033c2d774e7b8ffacb8f5eca8014b1981177c"),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: true,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cheap beer
        tiers[5] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xee9e83c134b975d0b6a13281809f65e035f1e8f9a9e1c7b7c1c64b039c745203"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Catana
        tiers[6] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x4dbcd1aa5a39d7791b36f3feb896b1cf33ebf3473bdd5008cbe5fc0685cffdfa"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Chefs knife
        tiers[6] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x55eaaa4416a3d5a0edc15de2710347261afcb817a439ea175857806f4f5a251d"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Club beanie
        tiers[7] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 1_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x565e83a9e41165c65cdac43dc2f29c6bbb566b00b3867c11cfaf29f0d245a991"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Constitution
        tiers[8] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x3c32ab30b6690b26d75b849a041597cf4700d4cf83a4b70f161a35da170f5bfa"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cyberpunk glasses 
        tiers[9] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x1732aecac3ff57268531d4dd59ff5f99c331b3097ac08ef894b6c42eb5305562"),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Pew pew 
        tiers[10] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x590629c9666022c2c9f6e4b11a38836605c7d225a467c6e7a20d433bcc772689"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // DJ booth
        tiers[11] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 10,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x2559da791a99eb1d38abce25b7e71acd752cd552d7cf814e9e7c304c47735b72"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Doc coat
        tiers[12] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x4a92036f7077efa4daaa8df8938a08e35f57ff542c9e9ebb7604663aac47e1ea"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy dress
        tiers[13] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xfd19d14b78edb4ebfa55098c89c0e1d9465c149cf745a61fc3ff44f12695e971"),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy shoes 
        tiers[14] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xfd19d14b78edb4ebfa55098c89c0e1d9465c149cf745a61fc3ff44f12695e971"),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy hair
        tiers[15] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x34e7b7607a4d4c2a3e952512fcd4259629ab64414fbbc40ac63cadb0f7154ec9"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Farmer hat
        tiers[16] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x492a6150cf967397b49ac5b16c223b8183753ba5975a3901294a016bd8386289"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Gas can
        tiers[17] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x84a4659f1b90f62ec34fb40b7ba40fd6755d3fdb55e7361b5d14925db6423531"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha body
        tiers[18] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x607ff2a869fb7a68e17f726a8ab1c76cc10ef5b6212ff52d6134a138082c0632"),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha hair
        tiers[19] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xce7f83c230a30e7b1a7df19de6110777e192a80d0109466c17236eec4e77205e"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Goat jersey
        tiers[20] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 12,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x1c26f25136860efdb7cd56a022ea6d4712682bf23b7eb5e98547298ffe5d397e"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Headphones
        tiers[21] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x5bc382a18249565059be56110df54090b479d9d0e7d4532be95b134f37e28f31"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Investor shades 
        tiers[22] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x68d7bd3d5cf439ec2c5496086b47836b515fc62d8d2fb1ceaf23299ed5280a1e"),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Irie tshirt 
        tiers[23] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xc1663fd3af2eb603e77f574b949babce9e7e8f8891729319ecc74a97f96aab4f"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Jonny utah shirt 
        tiers[24] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x07bf6be9d9e799a5d8b09bb13010c184cff10708a2c0c6991ee1bb2f34641915"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Lightsaber 
        tiers[25] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 5000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xe796db9ed1129bdd4308d3a7a4b47fbd3474662f725f3c5bf774d1c0550c36d3"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Mouthstraw 
        tiers[26] = JB721TierConfig({
            price: uint104(1 * 10 ** decimals),
            initialSupply: 15,
            votingUnits: 0,
            reserveFrequency: 15,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x87e7b96163e2026775b9542cc8fe27af8b82d238faff00f3c4e1716900aef0e5"),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Natty dread
        tiers[27] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xd921f11a90d95d49912d7720353485f61fe60d4f5f8c46d2cda86db18d559244"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Nerd
        tiers[28] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x5b8d4844edc7e51199a668ff850fd1bd1249a5203fdee945a30b1c65e319aafc"),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Peachhair 
        tiers[29] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x26f7754a967552abd5f8facf389d946dd40d207e147d2868ba84eb19a2b7a5ec"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Potion 
        tiers[30] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 50,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x093178452b12340bf7b5e0e37c8bb1f3e1e4a13ab09951a068ed81ce90d7bc05"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff glasses
        tiers[31] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xa3fcbbf007d2eca44cdb08c8a529a10259012ebc2bb83a8b45158c1419eecf72"),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff hair
        tiers[32] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x8e0823c4284791611f3ffeeebff48461a6ddb7c8fef22712324465a25062c458"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Punk jacket
        tiers[33] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x161b46d539f342bd14bf6a6bdbae97481c62c5db65dfcd2589eb29a25b156cd8"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Quaid helmet
        tiers[34] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x965dcda31011a48dc3bba46cf48e658cced561fd108faa6efdba1821c65cd0d6"),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Sweatsuit
        tiers[35] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 1)),
            initialSupply: 20,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xa1e9a64b57e76faf02cbd52619533cfccc326eb782ed8bc9b0886ad433bb9ce1"),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dagger 
        tiers[36] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x02d9af84c3abcfaf3ad838a253e51dc4519fe31803ace6eefad56af2d4bbf35d"),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zipper jacket
        tiers[37] = JB721TierConfig({
            price: uint104(25 * 10 ** (decimals - 2)),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xe290ab91349cccfcfe039ea91473b2249a2470f512395775c8d52da1495c55da"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zucco tshirt
        tiers[38] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 3)),
            initialSupply: 10000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x9f70b3ab00a94db2383503f650bba47a9d936a56f5158dc339e02418590de779"),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(tiers, new uint256[](0));
    }

    function _isDeployed(
        bytes32 salt,
        bytes memory creationCode,
        bytes memory arguments
    )
        internal
        view
        returns (address, bool)
    {
        address _deployedTo = vm.computeCreate2Address({
            salt: salt,
            initCodeHash: keccak256(abi.encodePacked(creationCode, arguments)),
            // Arachnid/deterministic-deployment-proxy address.
            deployer: address(0x4e59b44847b379578588920cA78FbF26c0B4956C)
        });

        // Return if code is already present at this address.
        return (_deployedTo, address(_deployedTo).code.length != 0);
    }
}