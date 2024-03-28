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
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        tiers[2] = JB721TierConfig({
            price: uint104(15 * 1 ** (decimals - 1)),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32("0x02e7e97b235567a77cd029baaad84bdebae9649ac431c9631e7fb56e17b76a40"),
            category: 9,
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
            category: 9,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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