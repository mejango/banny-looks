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

        // Sweatsuit
        names[0] = "Sweatsuit";
        svgHashes[0] = bytes32(0x6381dd96e0bf909f669984648a353b096aa260394933c5db6a960046110386b7);
        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 20,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x57340ff766ac33856e36742e9f50a2e3acb94c9075b4fc645a5b0416cb3b2050),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy dress
        names[1] = "Dorthy Dress";
        svgHashes[1] = bytes32(0x6e2c3c803fd2faa857cbe641071c038ca4b1c4742b0be7f58a5290efd7aa72f9);
        tiers[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x52d8a9562651c1c6d3afc693aec5deee156c0cf0bd606c53be1eb6a5d1734135),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha body
        names[2] = "Geisha Body";
        svgHashes[2] = bytes32(0x945d121df5de0697be72bcd378392aa1bb5689c6ba3df1a67fe1c337602493be);
        tiers[2] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xeda629ccb05c28b7ffbd274499d52132c40cd866dc77b5b349ca837fc7340607),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        names[3] = "Baggies";
        svgHashes[3] = bytes32(0xc9a3b7f6c641966285e345d12a68fb6d962b0e62f5b10398f206ad0282ca31cd);
        tiers[3] = JB721TierConfig({
            price: uint104(15 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc9a3b7f6c641966285e345d12a68fb6d962b0e62f5b10398f206ad0282ca31cd),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Jonny utah shirt
        names[4] = "Jonny Utah Shirt";
        svgHashes[4] = bytes32(0x773605e3d0ab2236b5780f22a64783bbc0b938445a1d41f76955ebcd21dae42c);
        tiers[4] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x4291eee6b32443c1df6b38dc1fb2e9fac00acdda0156d4a167f67d622c8fa1ed),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Doc coat
        names[5] = "Doc Coat";
        svgHashes[5] = bytes32(0x52d8a9562651c1c6d3afc693aec5deee156c0cf0bd606c53be1eb6a5d1734135);
        tiers[5] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x56f93601fe3818f09fbac468c37d823d08787a6998080e9a2688c0721af4c3e6),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Goat jersey
        names[6] = "Goat Jersey";
        svgHashes[6] = bytes32(0x61d5b8b66e0b5f6cedbb496f58a03ad6381fce70b9ee2d20017668468352d52c);
        tiers[6] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 12,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x0e3badd2c4df330aa41fe44ac4c1fde418879072326d0bb653bc109f60f4a72c),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Irie tshirt
        names[7] = "Irie Shirt";
        svgHashes[7] = bytes32(0x4291eee6b32443c1df6b38dc1fb2e9fac00acdda0156d4a167f67d622c8fa1ed);
        tiers[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x80fd71363a83c0e69ef58b647447b91ac765ab091a4d015397552a2414148099),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Punk jacket
        names[8] = "Punk Jacket";
        svgHashes[8] = bytes32(0xf27e9ad443d3f461fad933a1fac00eb1b0dd2e37ef6a0e05712b3bf75068c117);
        tiers[8] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x227a244f9e0857a0e1acffc80fefca06759323f856e0e19bf6bd39b48a034efc),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(tiers, new uint256[](0));

        uint256[] memory tierIds = new uint256[](9);
        for (uint256 i; i < 9; i++) {
          tierIds[i] = i + 23;
        }

        bannyverse.resolver.setSvgHashsOf(tierIds, svgHashes);
        bannyverse.resolver.setTierNames(tierIds, names);
        bannyverse.resolver.setSvgBaseUri("https://bannyverse.infura-ipfs.io/ipfs/");
    }
}
