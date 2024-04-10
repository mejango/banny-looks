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

        // Astr
        // Zipper jacket
        names[0] = "Zipper Jacket";
        svgHashes[0] = bytes32(0xe8a6364935ae91b7ec87db765b3d6d14723a54f4413cafdc6ade2140a24b2ddc);
        tiers[0] = JB721TierConfig({
            price: uint104(25 * (10 ** (decimals - 2))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe8a6364935ae91b7ec87db765b3d6d14723a54f4413cafdc6ade2140a24b2ddc),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zucco tshirt
        names[1] = "Zucco Tshirt";
        svgHashes[1] = bytes32(0x8e21fe91a6b4756e70e006cebfce662ab8861b4a62af8aaed83d35e57956b1dc);
        tiers[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x8e21fe91a6b4756e70e006cebfce662ab8861b4a62af8aaed83d35e57956b1dc),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Bandolph staff
        names[2] = "Bandolph Staff";
        svgHashes[2] = bytes32(0xdc278de8567be400acb8d95a5a8bdb921f1802bac54b53637f2ac3edd057d087);
        tiers[2] = JB721TierConfig({
            price: uint104(125 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xdc278de8567be400acb8d95a5a8bdb921f1802bac54b53637f2ac3edd057d087),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Catana
        names[3] = "Catana";
        svgHashes[3] = bytes32(0xd1982a45f353111302f371e1b2b6a0edb2b2413b5fc38e4b406e856e85e842f7);
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd1982a45f353111302f371e1b2b6a0edb2b2413b5fc38e4b406e856e85e842f7),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Chefs knife
        names[4] = "Chefs Knife";
        svgHashes[4] = bytes32(0x777c052bb6782e66234c1c847e6cb88e675301629949c968de4aa304401e9ca9);
        tiers[4] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x777c052bb6782e66234c1c847e6cb88e675301629949c968de4aa304401e9ca9),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cheap beer
        names[5] = "Cheap Beer";
        svgHashes[5] = bytes32(0xba6aacfc67494db3d1b21f812d72fc59d8f6eb5df7102221f4238c43ac8db0d8);
        tiers[5] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xba6aacfc67494db3d1b21f812d72fc59d8f6eb5df7102221f4238c43ac8db0d8),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Constitution
        names[6] = "Constitution";
        svgHashes[6] = bytes32(0x40fca04e7a981777cb61cdaa65eb0972ef5ec5fac36d0812143b7938d0d454f2);
        tiers[6] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x40fca04e7a981777cb61cdaa65eb0972ef5ec5fac36d0812143b7938d0d454f2),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Pew pew
        names[7] = "Pew Pew";
        svgHashes[7] = bytes32(0x074d00adc03e38fbb16fade19890729547b155f7c3e72f14a4136a0de62d0885);
        tiers[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x074d00adc03e38fbb16fade19890729547b155f7c3e72f14a4136a0de62d0885),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // DJ booth
        names[8] = "DJ Booth";
        svgHashes[8] = bytes32(0x56f93601fe3818f09fbac468c37d823d08787a6998080e9a2688c0721af4c3e6);
        tiers[8] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 10,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb2657b0e4c127a9c8da0dca6381d3c9584beaac5c2da15d2cf1ce053478227f9),
            category: 14,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(tiers, new uint256[](0));

        uint256[] memory tierIds = new uint256[](9);
        for (uint256 i; i < 9; i++) {
          tierIds[i] = i + 32;
        }

        bannyverse.resolver.setSvgHashsOf(tierIds, svgHashes);
        bannyverse.resolver.setTierNames(tierIds, names);
        bannyverse.resolver.setSvgBaseUri("https://bannyverse.infura-ipfs.io/ipfs/");
    }
}
