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
        sphinxConfig.projectName = "bannyverse-core";
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

        // The project's NFT tiers.
        JB721TierConfig[] memory tiers = new JB721TierConfig[](10);

        // Banny vision pro
        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: producer,
            encodedIPFSUri: bytes32(0x0b976fd6faacf732b33b59a4286997c15ce6ea28cb5058393fef83ff56b88ada),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: true,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cyberpunk glasses
        tiers[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc1ff2dfb5a2874e2c29a08c4c368f546627575b9761ddbb3a72582c3c41fa59a),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Investor shades
        tiers[2] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc5a88a1a769d3c44d7ae43ca2bea33911aa2e9fb28bf2a0b3f14563b79d31039),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Nerd
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd582b8bb3dff885efd6c4c15418e8fcaed10d97bf0a4b8e58e4fb07fb550c969),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff glasses
        tiers[4] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9f014b202de86447ab15ed58204869bbb0cbe43c3f6e7797e8864d63513ed7d1),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Mouthstraw
        tiers[5] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 15,
            votingUnits: 0,
            reserveFrequency: 15,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xbc0593966b22f3621df9b124eacb2642a0bad60b4207be4236a9dd4922afa1bd),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Club beanie
        tiers[6] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 1_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd7f2442faeb9a2221a290a9ec71291fb0296e7deb9e0cc78ef5dd3b215407bff),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy hair
        tiers[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x60ca58d9e671bd835a73546ae7525b17554a3c11f4e25d9d384b3708f3f9b6f8),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Farmer hat
        tiers[8] = JB721TierConfig({
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
        tiers[9] = JB721TierConfig({
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

        hook.adjustTiers(tiers, new uint256[](0));
    }
}
