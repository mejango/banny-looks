// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {JB721TierConfig} from "@bananapus/721-hook/src/structs/JB721TierConfig.sol";
import {JB721TiersHook} from "@bananapus/721-hook/src/JB721TiersHook.sol";

import "./helpers/BannyverseDeploymentLib.sol";
import "@rev-net/core/script/helpers/RevnetCoreDeploymentLib.sol";

import {Sphinx} from "@sphinx-labs/contracts/SphinxPlugin.sol";
import {Script} from "forge-std/Script.sol";

contract Drop1Script is Script, Sphinx {
    /// @notice tracks the deployment of the revnet contracts for the chain we are deploying to.
    RevnetCoreDeployment revnet;
    /// @notice tracks the deployment of the bannyverse contracts for the chain we are deploying to.
    BannyverseDeployment bannyverse;

    JB721TiersHook hook;

    function configureSphinx() public override {
        // TODO: Update to contain revnet devs.
        sphinxConfig.owners = [0x26416423d530b1931A2a7a6b7D435Fac65eED27d];
        sphinxConfig.orgId = "cltepuu9u0003j58rjtbd0hvu";
        sphinxConfig.projectName = "bannyverse-drop-1";
        sphinxConfig.threshold = 1;
        sphinxConfig.mainnets = ["ethereum", "optimism"];
        sphinxConfig.testnets = ["ethereum_sepolia", "optimism_sepolia"];
        sphinxConfig.saltNonce = 6;
    }

    function run() public {
        // Get the deployment addresses for the revnet contracts for this chain.
        revnet = RevnetCoreDeploymentLib.getDeployment(
            vm.envOr("REVNET_CORE_DEPLOYMENT_PATH", string("node_modules/@rev-net/core/deployments/"))
        );

        // Get the deployment addresses for the 721 hook contracts for this chain.
        bannyverse = BannyverseDeploymentLib.getDeployment(
            vm.envOr("BANNYVERSE_CORE_DEPLOYMENT_PATH", string("deployments/"))
        );

        // Get the hook address by using the deployer. 
        hook = JB721TiersHook(address(revnet.croptop_deployer.payHookSpecificationsOf(bannyverse.revnetId)[0].hook));
        deploy();
    }

    function deploy() public sphinx {
        address producer = safeAddress();
        uint256 decimals = 18;

        // The project's NFT tiers.
        JB721TierConfig[] memory tiers = new JB721TierConfig[](1);//(40);

        // Astronaut Head
        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc0c2a75331d0513765e951191c150992fd4d165960ad3f2c3ff313405772359f),
            category: 4,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // // Banny vision pro 
        // tiers[1] = JB721TierConfig({
        //     price: uint104(1 * (10 ** decimals)),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 25,
        //     reserveBeneficiary: producer,
        //     encodedIPFSUri: bytes32(0x0b976fd6faacf732b33b59a4286997c15ce6ea28cb5058393fef83ff56b88ada),
        //     category: 6,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: true,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Cyberpunk glasses 
        // tiers[2] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 150,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xc1ff2dfb5a2874e2c29a08c4c368f546627575b9761ddbb3a72582c3c41fa59a),
        //     category: 6,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Investor shades 
        // tiers[3] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xc5a88a1a769d3c44d7ae43ca2bea33911aa2e9fb28bf2a0b3f14563b79d31039),
        //     category: 6,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Nerd
        // tiers[4] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 50,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xd582b8bb3dff885efd6c4c15418e8fcaed10d97bf0a4b8e58e4fb07fb550c969),
        //     category: 6,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Proff glasses
        // tiers[5] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 200,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x9f014b202de86447ab15ed58204869bbb0cbe43c3f6e7797e8864d63513ed7d1),
        //     category: 6,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Mouthstraw 
        // tiers[6] = JB721TierConfig({
        //     price: uint104(1 * (10 ** decimals)),
        //     initialSupply: 15,
        //     votingUnits: 0,
        //     reserveFrequency: 15,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xbc0593966b22f3621df9b124eacb2642a0bad60b4207be4236a9dd4922afa1bd),
        //     category: 7,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Club beanie
        // tiers[7] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 1_000,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xd7f2442faeb9a2221a290a9ec71291fb0296e7deb9e0cc78ef5dd3b215407bff),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Dorthy hair
        // tiers[8] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x60ca58d9e671bd835a73546ae7525b17554a3c11f4e25d9d384b3708f3f9b6f8),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Farmer hat
        // tiers[9] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xd7de6178afca3caac5358152172f9aa72467ab63c000cd13a953dfa4d2251ed3),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Geisha hair
        // tiers[10] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 100,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x945d121df5de0697be72bcd378392aa1bb5689c6ba3df1a67fe1c337602493be),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Headphones
        // tiers[11] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 500,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x61d5b8b66e0b5f6cedbb496f58a03ad6381fce70b9ee2d20017668468352d52c),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Natty dread
        // tiers[12] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x6c2081c821d5514a3c49cc5f0c3a4b4fb93607808b23814f4950cba9370e8a9f),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Peachhair 
        // tiers[13] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x035a3585ec319463ec6a1a172308b3555d109805bd37d004e5f946044d21a4e8),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Proff hair
        // tiers[14] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 200,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x858b5b740b509d8c4cc22f3c45c5e9cbb0bfc056655f73f940e19bc5c5063010),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Quaid helmet
        // tiers[15] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xf27e9ad443d3f461fad933a1fac00eb1b0dd2e37ef6a0e05712b3bf75068c117),
        //     category: 8,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Astronaut Body
        // tiers[16] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xadb4f498b101bdfd65030fb597f7f2817d908f034ba25581ca11f8408cc3770a),
        //     category: 9,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Dorthy shoes 
        // tiers[17] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x6e2c3c803fd2faa857cbe641071c038ca4b1c4742b0be7f58a5290efd7aa72f9),
        //     category: 10,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Sweatsuit
        // tiers[18] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 20,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x57340ff766ac33856e36742e9f50a2e3acb94c9075b4fc645a5b0416cb3b2050),
        //     category: 10,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Dorthy dress
        // tiers[19] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x52d8a9562651c1c6d3afc693aec5deee156c0cf0bd606c53be1eb6a5d1734135),
        //     category: 11,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Geisha body
        // tiers[20] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 100,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xeda629ccb05c28b7ffbd274499d52132c40cd866dc77b5b349ca837fc7340607),
        //     category: 11,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Baggies
        // tiers[21] = JB721TierConfig({
        //     price: uint104(15 * (10 ** (decimals - 1))),
        //     initialSupply: 30,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xc9a3b7f6c641966285e345d12a68fb6d962b0e62f5b10398f206ad0282ca31cd),
        //     category: 12,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Jonny utah shirt 
        // tiers[22] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x4291eee6b32443c1df6b38dc1fb2e9fac00acdda0156d4a167f67d622c8fa1ed),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Doc coat
        // tiers[23] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x56f93601fe3818f09fbac468c37d823d08787a6998080e9a2688c0721af4c3e6),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Goat jersey
        // tiers[24] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 50,
        //     votingUnits: 0,
        //     reserveFrequency: 12,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x0e3badd2c4df330aa41fe44ac4c1fde418879072326d0bb653bc109f60f4a72c),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Irie tshirt 
        // tiers[25] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x80fd71363a83c0e69ef58b647447b91ac765ab091a4d015397552a2414148099),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Punk jacket
        // tiers[26] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 50,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x227a244f9e0857a0e1acffc80fefca06759323f856e0e19bf6bd39b48a034efc),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Zipper jacket
        // tiers[27] = JB721TierConfig({
        //     price: uint104(25 * (10 ** (decimals - 2))),
        //     initialSupply: 25,
        //     votingUnits: 0,
        //     reserveFrequency: 25,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xe8a6364935ae91b7ec87db765b3d6d14723a54f4413cafdc6ade2140a24b2ddc),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Zucco tshirt
        // tiers[28] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 10000,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x8e21fe91a6b4756e70e006cebfce662ab8861b4a62af8aaed83d35e57956b1dc),
        //     category: 13,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Bandolph staff
        // tiers[29] = JB721TierConfig({
        //     price: uint104(125 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xdc278de8567be400acb8d95a5a8bdb921f1802bac54b53637f2ac3edd057d087),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Catana
        // tiers[30] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 250,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xd1982a45f353111302f371e1b2b6a0edb2b2413b5fc38e4b406e856e85e842f7),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Chefs knife
        // tiers[31] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 500,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x777c052bb6782e66234c1c847e6cb88e675301629949c968de4aa304401e9ca9),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Cheap beer
        // tiers[32] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 10_000,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xba6aacfc67494db3d1b21f812d72fc59d8f6eb5df7102221f4238c43ac8db0d8),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Constitution
        // tiers[33] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 10_000,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x40fca04e7a981777cb61cdaa65eb0972ef5ec5fac36d0812143b7938d0d454f2),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Pew pew 
        // tiers[34] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 2))),
        //     initialSupply: 150,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x074d00adc03e38fbb16fade19890729547b155f7c3e72f14a4136a0de62d0885),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // DJ booth
        // tiers[35] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 10,
        //     votingUnits: 0,
        //     reserveFrequency: 10,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xb2657b0e4c127a9c8da0dca6381d3c9584beaac5c2da15d2cf1ce053478227f9),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Gas can
        // tiers[36] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 25,
        //     votingUnits: 0,
        //     reserveFrequency: 25,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xa49c14447402b7c5e7542b515e2d8626d92c03ec528727d95904cbcfe36a0e30),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Lightsaber 
        // tiers[37] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 5000,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x773605e3d0ab2236b5780f22a64783bbc0b938445a1d41f76955ebcd21dae42c),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Potion 
        // tiers[38] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 1))),
        //     initialSupply: 100,
        //     votingUnits: 0,
        //     reserveFrequency: 50,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0xc3ad10afe4e2836882501666642c3d45ae5e5b214fd9167221bfe95a42fbc5c6),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });
        // // Dagger 
        // tiers[39] = JB721TierConfig({
        //     price: uint104(1 * (10 ** (decimals - 3))),
        //     initialSupply: 150,
        //     votingUnits: 0,
        //     reserveFrequency: 0,
        //     reserveBeneficiary: address(0),
        //     encodedIPFSUri: bytes32(0x6381dd96e0bf909f669984648a353b096aa260394933c5db6a960046110386b7),
        //     category: 14,
        //     allowOwnerMint: false,
        //     useReserveBeneficiaryAsDefault: false,
        //     transfersPausable: false,
        //     useVotingUnits: false,
        //     cannotBeRemoved: false
        // });

        hook.adjustTiers(tiers, new uint256[](0));

        uint256[] memory tierIds = new uint256[](1);//(40);
        bytes32[] memory svgHashes = new bytes32[](1);//(40);
        tierIds[0] = 5;
        // for (uint256 i; i < 40; i++) {
        //   tierIds[i] = i + 5;
        // }

        // svgHashes[0] = bytes32(0x72c967fccb0ecfb66d8b5902c00b28cd19b7fabb0396cc8d110d2c7b1c5be369);
        svgHashes[0] = bytes32(0x3912f3b815511f3fc935703669624b1efb9ab6afdbd308f66edcb2960ac8f93f);
        // svgHashes[2] = bytes32(0xa056a061d44fe1d02ee153c030afaaa773521056bc591ec9ed3290fe7a3b9917);
        // svgHashes[3] = bytes32(0xacfbffe21e3de73825eaf11dd666d7ac1ed3dce71c40e2f78abfdcc61de6e231);
        // svgHashes[4] = bytes32(0x48722804c2fb5388619745793bb4664aa99a58b33809093db0023cf6c2a94dfb);
        // svgHashes[5] = bytes32(0x40e6ae57605ea4bc547bafafb1dc8b00f0235070ca4005a4f277ac6197612b28);
        // svgHashes[6] = bytes32(0x4bacb12fd3dac3a392d8edca1c4ddb9f480619f4c7e18c3fbda6fa44f59f2080);
        // svgHashes[7] = bytes32(0xe2a349c0acba1d273ba01e9ad266bbdad652cec5184ad73ee82c11044ac28558);
        // svgHashes[8] = bytes32(0x5aeb94cf89e7be61849b77d4fb32a105473048d7a4a35bccbf87bee0f48e4c71);
        // svgHashes[9] = bytes32(0xd571397055350d3338d73f7594ba5d12deb1345ee16dffaa6d108bb0b2e50e4a);
        // svgHashes[10] = bytes32(0x74ce81a55d03e0a3cb769df5723243f5ffc879b5af3960ecc6eafddbfe03e319);
        // svgHashes[11] = bytes32(0xfd3ac98d3d60677cbcbf1c3f88d97214618ee15839616c916c0ef954e62ca13a);
        // svgHashes[12] = bytes32(0x84a5e65f54a55bcfffbb050892be115a1f9e51f749c09f899f84886c547e0ad9);
        // svgHashes[13] = bytes32(0x43985a2ccd8f5fe3a08d0d6f6ccd37c58797f83b1b7fbd4fe921135257d9317a);
        // svgHashes[14] = bytes32(0xafb136b2e279fab66ebc2ad03f254a6bb15845cfd2d02659b67b05b0cb212171);
        // svgHashes[15] = bytes32(0xef34613334ea81f3e6394fb3156f029810341f422ce553187483cc11a05ee06b);
        // svgHashes[16] = bytes32(0x1417655d1e83bb653e865f7a8653c065c9677ec42c0fac7ea75d9142099ee04d);
        // svgHashes[17] = bytes32(0x294170bd6598f1e1ec50f9b4fc8e13195595581017f4f5eecc67e15a7c22bbf3);
        // svgHashes[18] = bytes32(0xcc63099a7a1172d04db284be80a6b14c2b2c44f546837fd2864e9f10d7fd32aa);
        // svgHashes[19] = bytes32(0xe2db3e12eac178f0ec6ca29f0354050d6f9bea8dc1ed1ede7650a982d074dc52);
        // svgHashes[20] = bytes32(0x27cb2a6eaba1ed713e06759a2cbbeb202b9c30d14b3277650112c4a33b904abe);
        // svgHashes[21] = bytes32(0x1d8a511b9f64f91ba487c3f154b72a27e6e0006b5fcd936d4144b840c4c89e17);
        // svgHashes[22] = bytes32(0x660274af6d3a0cbf6eb5c17653dc987ff5ffeae0cbd4f43217c69bf855ae6f60);
        // svgHashes[23] = bytes32(0x99f076bd58bcd99698984eddbf98c26fe2724279bb251273ffe33d3ba70841b3);
        // svgHashes[24] = bytes32(0x8ea063476043ea13f2c5234c5c436904910ffc2057160f0107ee9e282f19e297);
        // svgHashes[25] = bytes32(0x9f0084ae54058a1501ab4475406829effc1b720c43a1eff64f7528be3d5233fb);
        // svgHashes[26] = bytes32(0xa6292ef611888f53067dff30033f1e20d7fc53d21111a18537b5932639b20fe1);
        // svgHashes[27] = bytes32(0xce073a9ba6daaf651ef126ad5a377717006150abd6a89217669d619d53ed716d);
        // svgHashes[28] = bytes32(0x310312dbf88bcd24550fe00ceacc2df4e58741f99f9f48a07f34a57b4e3bf57f);
        // svgHashes[29] = bytes32(0xcca9b51edef8e733b928028b3f9a61619b72ce937cd47d25fe0f15b9cb5f2ec3);
        // svgHashes[30] = bytes32(0x55e4e915c0642002cfedef043154b00b0f5c9b084ee241e2f283f8040ab3af92);
        // svgHashes[31] = bytes32(0x22dd4da99647543397cbd8afa162b9bf3243a774c3db1ab2130251ab4c47eb48);
        // svgHashes[32] = bytes32(0x252faea09bdfea00c4616dbe51d208200b5b8369093dfb5acc7fbcdd739dac83);
        // svgHashes[33] = bytes32(0x8bc333f872da87d8f11875a1f8cbb5947759ec69484fdd25b6e927ffe2547346);
        // svgHashes[34] = bytes32(0xa60f89b538e91947a1c3902527d8258816c55d8cce027c24c317d7194f780588);
        // svgHashes[35] = bytes32(0xacd990609f9ecced2b7baa0d251f8561a78793e4bd80c82ced2c7d6e305ed1ef);
        // svgHashes[36] = bytes32(0xdb88f7db87040a94e91ad12bf12a59dcb6324a9f47d56325a787ddc28d1e3b3e);
        // svgHashes[37] = bytes32(0x7e95e4f07ff7b2fa2b1afce8729079119a43ab865a691166ba9c6b6bb99e79f0);
        // svgHashes[38] = bytes32(0x0dbc34cc734039dae91309142c5042a9ffc46f14a6c3a11eb8c74fa7d7b23e55);
        // svgHashes[39] = bytes32(0x63ecce624ab9c586fed702aee4496063482ad846b8e685767dfc2509f6bdfb12);

        bannyverse.resolver.setSvgHashsOf(tierIds, svgHashes);

        string[] memory names = new string[](1);
        // names[0] = "Astronaut Body";
        names[0] = "Astronaut Helmet";
        // names[2] = "Baggies";
        // names[3] = "Bandolph Staff";
        // names[4] = "Banny Vision Pro";
        // names[5] = "Cheap Beer";
        // names[6] = "Catana";
        // names[7] = "Chefs Knife";
        // names[8] = "Club Beanie";
        // names[9] = "Constitution";
        // names[10] = "Cyberpunk Glasses";
        // names[11] = "Pew Pew";
        // names[12] = "DJ Booth";
        // names[13] = "Doc Coat";
        // names[14] = "Dorthy Dress";
        // names[15] = "Dorthy Shoes";
        // names[16] = "Dorthy Hair";
        // names[17] = "Farmer Hat";
        // names[18] = "Gas Can";
        // names[19] = "Geisha Body";
        // names[20] = "Geisha Hair";
        // names[21] = "Goat Jersey";
        // names[22] = "Headphones";
        // names[23] = "Investor Shades";
        // names[24] = "Irie Shirt";
        // names[25] = "Jonny Utah Shirt";
        // names[26] = "Lightsaber";
        // names[27] = "Mouthstraw";
        // names[28] = "Natty Dred";
        // names[29] = "Nerd";
        // names[30] = "Peach Hair";
        // names[31] = "Potion";
        // names[32] = "Proff Glasses";
        // names[33] = "Proff Hair";
        // names[34] = "Punk Jacket";
        // names[35] = "Quaid Helmet";
        // names[36] = "Sweatsuit";
        // names[37] = "Dagger";
        // names[38] = "Zipper Jacket";
        // names[39] = "Zucco Tshirt";

        bannyverse.resolver.setTierNames(tierIds, names);

        bannyverse.resolver.setSvgBaseUri("https://bannyverse.infura-ipfs.io/");
    }
}