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
        hook = Hook721Deployment(address(0)); //TODO add the right address.

        // The project's NFT tiers.
        JB721TierConfig[] memory tiers = new JB721TierConfig[](30);

        // Astronaut Body
        tiers[0] = JB721TierConfig({
            price: uint104(1 * 10 ** (decimals - 2)),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0xadb4f498b101bdfd65030fb597f7f2817d908f034ba25581ca11f8408cc3770a"),
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
            encodedIPFSUri: bytes32("0xc0c2a75331d0513765e951191c150992fd4d165960ad3f2c3ff313405772359f"),
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
            encodedIPFSUri: bytes32("0xc9a3b7f6c641966285e345d12a68fb6d962b0e62f5b10398f206ad0282ca31cd"),
            category: 12,
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
            encodedIPFSUri: bytes32("0xdc278de8567be400acb8d95a5a8bdb921f1802bac54b53637f2ac3edd057d087"),
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
            encodedIPFSUri: bytes32("0x0b976fd6faacf732b33b59a4286997c15ce6ea28cb5058393fef83ff56b88ada"),
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
            encodedIPFSUri: bytes32("0xba6aacfc67494db3d1b21f812d72fc59d8f6eb5df7102221f4238c43ac8db0d8"),
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
            encodedIPFSUri: bytes32("0xd1982a45f353111302f371e1b2b6a0edb2b2413b5fc38e4b406e856e85e842f7"),
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
            encodedIPFSUri: bytes32("0x777c052bb6782e66234c1c847e6cb88e675301629949c968de4aa304401e9ca9"),
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
            encodedIPFSUri: bytes32("0xd7f2442faeb9a2221a290a9ec71291fb0296e7deb9e0cc78ef5dd3b215407bff"),
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
            encodedIPFSUri: bytes32("0x40fca04e7a981777cb61cdaa65eb0972ef5ec5fac36d0812143b7938d0d454f2"),
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
            encodedIPFSUri: bytes32("0xc1ff2dfb5a2874e2c29a08c4c368f546627575b9761ddbb3a72582c3c41fa59a"),
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
            encodedIPFSUri: bytes32("0x074d00adc03e38fbb16fade19890729547b155f7c3e72f14a4136a0de62d0885"),
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
            encodedIPFSUri: bytes32("0xb2657b0e4c127a9c8da0dca6381d3c9584beaac5c2da15d2cf1ce053478227f9"),
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
            encodedIPFSUri: bytes32("0x56f93601fe3818f09fbac468c37d823d08787a6998080e9a2688c0721af4c3e6"),
            category: 13,
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
            encodedIPFSUri: bytes32("0x52d8a9562651c1c6d3afc693aec5deee156c0cf0bd606c53be1eb6a5d1734135"),
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
            encodedIPFSUri: bytes32("0x6e2c3c803fd2faa857cbe641071c038ca4b1c4742b0be7f58a5290efd7aa72f9"),
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
            encodedIPFSUri: bytes32("0x60ca58d9e671bd835a73546ae7525b17554a3c11f4e25d9d384b3708f3f9b6f8"),
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
            encodedIPFSUri: bytes32("0xd7de6178afca3caac5358152172f9aa72467ab63c000cd13a953dfa4d2251ed3"),
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
            encodedIPFSUri: bytes32("0xa49c14447402b7c5e7542b515e2d8626d92c03ec528727d95904cbcfe36a0e30"),
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
            encodedIPFSUri: bytes32("0xeda629ccb05c28b7ffbd274499d52132c40cd866dc77b5b349ca837fc7340607"),
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
            encodedIPFSUri: bytes32("0x945d121df5de0697be72bcd378392aa1bb5689c6ba3df1a67fe1c337602493be"),
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
            encodedIPFSUri: bytes32("0x0e3badd2c4df330aa41fe44ac4c1fde418879072326d0bb653bc109f60f4a72c"),
            category: 13,
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
            encodedIPFSUri: bytes32("0x61d5b8b66e0b5f6cedbb496f58a03ad6381fce70b9ee2d20017668468352d52c"),
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
            encodedIPFSUri: bytes32("0xc5a88a1a769d3c44d7ae43ca2bea33911aa2e9fb28bf2a0b3f14563b79d31039"),
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
            encodedIPFSUri: bytes32("0x80fd71363a83c0e69ef58b647447b91ac765ab091a4d015397552a2414148099"),
            category: 13,
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
            encodedIPFSUri: bytes32("0x4291eee6b32443c1df6b38dc1fb2e9fac00acdda0156d4a167f67d622c8fa1ed"),
            category: 13,
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
            encodedIPFSUri: bytes32("0x773605e3d0ab2236b5780f22a64783bbc0b938445a1d41f76955ebcd21dae42c"),
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
            encodedIPFSUri: bytes32("0xbc0593966b22f3621df9b124eacb2642a0bad60b4207be4236a9dd4922afa1bd"),
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
            encodedIPFSUri: bytes32("0x6c2081c821d5514a3c49cc5f0c3a4b4fb93607808b23814f4950cba9370e8a9f"),
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
            encodedIPFSUri: bytes32("0xd582b8bb3dff885efd6c4c15418e8fcaed10d97bf0a4b8e58e4fb07fb550c969"),
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
            encodedIPFSUri: bytes32("0x035a3585ec319463ec6a1a172308b3555d109805bd37d004e5f946044d21a4e8"),
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
            encodedIPFSUri: bytes32("0xc3ad10afe4e2836882501666642c3d45ae5e5b214fd9167221bfe95a42fbc5c6"),
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
            encodedIPFSUri: bytes32("0x9f014b202de86447ab15ed58204869bbb0cbe43c3f6e7797e8864d63513ed7d1"),
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
            encodedIPFSUri: bytes32("0x858b5b740b509d8c4cc22f3c45c5e9cbb0bfc056655f73f940e19bc5c5063010"),
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
            encodedIPFSUri: bytes32("0x227a244f9e0857a0e1acffc80fefca06759323f856e0e19bf6bd39b48a034efc"),
            category: 13,
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
            encodedIPFSUri: bytes32("0xf27e9ad443d3f461fad933a1fac00eb1b0dd2e37ef6a0e05712b3bf75068c117"),
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
            encodedIPFSUri: bytes32("0x57340ff766ac33856e36742e9f50a2e3acb94c9075b4fc645a5b0416cb3b2050"),
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
            encodedIPFSUri: bytes32("0x6381dd96e0bf909f669984648a353b096aa260394933c5db6a960046110386b7"),
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
            encodedIPFSUri: bytes32("0xe8a6364935ae91b7ec87db765b3d6d14723a54f4413cafdc6ade2140a24b2ddc"),
            category: 13,
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
            encodedIPFSUri: bytes32("0x8e21fe91a6b4756e70e006cebfce662ab8861b4a62af8aaed83d35e57956b1dc"),
            category: 13,
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