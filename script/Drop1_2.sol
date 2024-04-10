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
        bannyverse =
            BannyverseDeploymentLib.getDeployment(vm.envOr("BANNYVERSE_CORE_DEPLOYMENT_PATH", string("deployments/")));

        // Get the hook address by using the deployer.
        hook = JB721TiersHook(address(revnet.croptop_deployer.payHookSpecificationsOf(bannyverse.revnetId)[0].hook));
        deploy();
    }

    function deploy() public sphinx {
        address producer = safeAddress();
        uint256 decimals = 18;

        string[] memory names = new string[](9);
        bytes32[] memory svgHashes = new bytes32[](9);
        JB721TierConfig[] memory tiers = new JB721TierConfig[](9);

        // Farmer hat
        names[0] = "Farmer Hat";
        svgHashes[0] = bytes32(0xa49c14447402b7c5e7542b515e2d8626d92c03ec528727d95904cbcfe36a0e30);
        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd7de6178afca3caac5358152172f9aa72467ab63c000cd13a953dfa4d2251ed3),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha hair
        names[1] = "Geisha Hair";
        svgHashes[1] = bytes32(0x0e3badd2c4df330aa41fe44ac4c1fde418879072326d0bb653bc109f60f4a72c);
        tiers[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x945d121df5de0697be72bcd378392aa1bb5689c6ba3df1a67fe1c337602493be),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Headphones
        names[2] = "Headphones";
        svgHashes[2] = bytes32(0xc5a88a1a769d3c44d7ae43ca2bea33911aa2e9fb28bf2a0b3f14563b79d31039);
        tiers[2] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x61d5b8b66e0b5f6cedbb496f58a03ad6381fce70b9ee2d20017668468352d52c),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Natty dread
        names[3] = "Natty Dred";
        svgHashes[3] = bytes32(0xd582b8bb3dff885efd6c4c15418e8fcaed10d97bf0a4b8e58e4fb07fb550c969);
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6c2081c821d5514a3c49cc5f0c3a4b4fb93607808b23814f4950cba9370e8a9f),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Peachhair
        names[4] = "Peach Hair";
        svgHashes[4] = bytes32(0xc3ad10afe4e2836882501666642c3d45ae5e5b214fd9167221bfe95a42fbc5c6);
        tiers[4] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x035a3585ec319463ec6a1a172308b3555d109805bd37d004e5f946044d21a4e8),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff hair
        names[5] = "Proff Hair";
        svgHashes[5] = bytes32(0x227a244f9e0857a0e1acffc80fefca06759323f856e0e19bf6bd39b48a034efc);
        tiers[5] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x858b5b740b509d8c4cc22f3c45c5e9cbb0bfc056655f73f940e19bc5c5063010),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Quaid helmet
        names[6] = "Quaid Helmet";
        svgHashes[6] = bytes32(0x57340ff766ac33856e36742e9f50a2e3acb94c9075b4fc645a5b0416cb3b2050);
        tiers[6] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf27e9ad443d3f461fad933a1fac00eb1b0dd2e37ef6a0e05712b3bf75068c117),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Body
        names[7] = "Astronaut Body";
        svgHashes[7] = bytes32(0xadb4f498b101bdfd65030fb597f7f2817d908f034ba25581ca11f8408cc3770a);
        tiers[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xadb4f498b101bdfd65030fb597f7f2817d908f034ba25581ca11f8408cc3770a),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy shoes
        names[8] = "Dorthy Shoes";
        svgHashes[8] = bytes32(0xd7de6178afca3caac5358152172f9aa72467ab63c000cd13a953dfa4d2251ed3);
        tiers[8] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6e2c3c803fd2faa857cbe641071c038ca4b1c4742b0be7f58a5290efd7aa72f9),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(tiers, new uint256[](0));

        uint256[] memory tierIds = new uint256[](9);
        for (uint256 i; i < 9; i++) {
          tierIds[i] = i + 14;
        }

        bannyverse.resolver.setSvgHashsOf(tierIds, svgHashes);
        bannyverse.resolver.setTierNames(tierIds, names);
    }
}
