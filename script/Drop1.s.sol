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

        string[] memory names = new string[](42);
        bytes32[] memory svgHashes = new bytes32[](42);
        JB721TierConfig[] memory tiers = new JB721TierConfig[](42);

        // Pew pew
        names[0] = "Pew Pew";
        svgHashes[0] = bytes32(0x9a9a7fa05248ea03eccac9999a5a78260e3ac90daf57e4ad23f087cdc67e278d);
        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6228648f1b7558e6695cf90f9e4989b5380b7abb3612e52971b93d250c26ef08),
            category: 2,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Bandolph staff
        names[1] = "Bandolph Staff";
        svgHashes[1] = bytes32(0x13e12ceb2c70fddc2e7624caa6e894173b58821ca9ee1be674cc0de0925180a4);
        tiers[1] = JB721TierConfig({
            price: uint104(125 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xfd3d865205cacbcbd4647f0a37bef5548868241423e027abf64fe26afd6adbdb),
            category: 2,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Head
        names[2] = "Astronaut Head";
        svgHashes[2] = bytes32(0xa0a69e7e0f6716bf480a7080d37649dc69c6085acccf413d8975a249cc736a82);
        tiers[2] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xee42ede9007b86b2e0337a815349a72d96b2c8fcaae0e70bcabdfb9638979ff1),
            category: 4,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Nerd
        names[3] = "Nerd";
        svgHashes[3] = bytes32(0x290de079e2ce3a064bd9df6112a5cc0b9eb75dbde7f5ce7861a781bc3448752c);
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xa08efd992e3751574750ecb0f36ef4d22ca4f167ffc458d1302ffc0e99ed33a8),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Banny vision pro
        names[4] = "Banny Vision Pro";
        svgHashes[4] = bytes32(0x0ff086e31e6932fa8aaa96caed9cda9ee9397fba34fea05c10b75897668928b5);
        tiers[4] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: producer,
            encodedIPFSUri: bytes32(0x1e7d86c28080058013e8123a7b3c0054059f2171bd66ae078fdc87a8471f7428),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: true,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cyberpunk glasses
        names[5] = "Cyberpunk Glasses";
        svgHashes[5] = bytes32(0xd58f3a60146708a20e3754b3c0caf0c87af49b2748a72421bd64570cc9d0faa4);
        tiers[5] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf3dd9eceee0a9c85fb7993a2865187456c526dee44191f637ac54ee7f1a4b9c4),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Investor shades
        names[6] = "Investor Shades";
        svgHashes[6] = bytes32(0x12e659ff1444abac5c9920b5f076fac091f68c11aa9f6333aa1b713930d134e6);
        tiers[6] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6e228758145f2d86aa94146164c0b3872ae9e6d1837ea5b9a4a1e3b1dc8055a2),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff glasses
        names[7] = "Proff Glasses";
        svgHashes[7] = bytes32(0xbb79c32e117f6c426cdf9529ab91c6b1923889cf66f360a5b03d3f4c0a6a98cf);
        tiers[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x02c819a74838e483b14b459376328b711a99ad1de04d15dbd96c4f564fe8c8e5),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Mouthstraw
        names[8] = "Mouthstraw";
        svgHashes[8] = bytes32(0x96050038f06704fa0c891bab58fd0c42c21e0163ef7ece20755f0b4696649e3c);
        tiers[8] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 15,
            votingUnits: 0,
            reserveFrequency: 15,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xdd03108f94064c805f8f34bb4827d611d7ba5b08abd2d3f67727bb66c715cfcf),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Club beanie
        names[9] = "Club Beanie";
        svgHashes[9] = bytes32(0x5665e5d760e91466c4b9f094b710c26b93563846e39f08bff765ef71951d2b7b);
        tiers[9] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 1000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe47cfa6836b80adeecee131acaea60cc82e679eb6c3318f5dec7882d8e472815),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy hair
        names[10] = "Dorthy Hair";
        svgHashes[10] = bytes32(0x026c2ccff1de658376bda9bfe095ccf521b7a751c5ca1c9ef2b33585497f277d);
        tiers[10] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf8377fbe642701e36fd50d164b786de4399ec24df608096c1291d805c29b6fe5),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Farmer hat
        names[11] = "Farmer Hat";
        svgHashes[11] = bytes32(0x9a368bd3010e5a5b753766092968684d54eb44d361079fc34674df4084ab3ed5);
        tiers[11] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xde2a0e57ef2100b8c2c8b2629e27ac7a9eb8b23f5a6399996fbe4e7f191dd1fe),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha hair
        names[12] = "Geisha Hair";
        svgHashes[12] = bytes32(0xeabb735dfb47f2b4871b6591b1d28e1cf4356923205ac387df9f7193afe69407);
        tiers[12] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd92856f79509229248cb67e6d6c0c74db5e07e195e827109a8747c363dcdbfd8),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Headphones
        names[13] = "Headphones";
        svgHashes[13] = bytes32(0x1bab46e99e3c5ed6df7da8e4321bb21941c813badd48e51a24e545db2e2b8bc4);
        tiers[13] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe645ea65384470742f0a8e03871596b0e66e70cd090e1dd82aa2a3b8cfd6fb6d),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Natty dread
        names[14] = "Natty Dred";
        svgHashes[14] = bytes32(0xb93f4b85e0d09ae317d49e4fac84dd1e9750d43f6bcdde00d128e641e857d79e);
        tiers[14] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb8d50404ea95e080d341e70658ba33003d31106215b953e622423ae98c2a3565),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Peachhair
        names[15] = "Peach Hair";
        svgHashes[15] = bytes32(0xf2284429ff70d042d570e91023d32710c981fb46bb1ea8f7927138602537c94d);
        tiers[15] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xcf71366b16c874b5633c5d2cd2a6d120d64f7264dd92fb19624854bbbde4de31),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff hair
        names[16] = "Proff Hair";
        svgHashes[16] = bytes32(0x61b237118ce3d7fd12cd6aa3f9192df6c3e5c6931299c9c6cd2fb91edbfe2913);
        tiers[16] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc2d6af5d4d4c95c11053432ac0eecea67ee9005701cdd60fb984bf1953ba5d7f),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Quaid helmet
        names[17] = "Quaid Helmet";
        svgHashes[17] = bytes32(0xf6d1df810231cb8d223287bdf14055c6bce0cac2db794beb7270f66dda9c93de);
        tiers[17] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9197306147b19bfb7d866646d206abdac486a6a6f28e95320d3d2943a8d5307e),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy shoes
        names[18] = "Dorthy Shoes";
        svgHashes[18] = bytes32(0xdd1254a6beb487a0bdf37fc011e58eef403c137a0e6859b981987bb635d9773b);
        tiers[18] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x10033d2b9d9fef14513b40506abba708824bd21c6478060cc5f4c2460e253c84),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut boots
        names[19] = "Astronaut boots";
        svgHashes[19] = bytes32(0xedca629b6bc739d1d41869a36e17bd1d100557cdd9548d610459d3798bb02859);
        tiers[19] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x8a618fdc674eb8e19c2d01f84ad30775019b85b8cfe9c1725a4660445b708b3c),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Flops
        names[20] = "Flops";
        svgHashes[20] = bytes32(0x9c9340ff849440e2b68188b72379cdfd2afbdd3a80ea19cdf6dd41a0c862d0d2);
        tiers[20] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x4c43397ab86628bd2f5c8237de248755b389b25f40e5b19eab7f4db67fac0233),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Body
        names[21] = "Astronaut Body";
        svgHashes[21] = bytes32(0x8bad327f99f4097cd9a1dcbc3f6d206c1c8b3d379f57f975e6dc48f2294f9fa3);
        tiers[21] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x7da24c4c113b55a6f2b887ff50c80d84c7b39012d89f8a5e0d636d2c1c633b71),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Sweatsuit
        names[22] = "Sweatsuit";
        svgHashes[22] = bytes32(0x896b471bc6b782688b7ae9746471a81c8de450bf6a342357b0ca72fcd9aa7562);
        tiers[22] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 20,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x19a8fdf9a0c48e17fc0817ccbd9ed80c634436286a36270f14706aa3ee0cc10e),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy dress
        names[23] = "Dorthy Dress";
        svgHashes[23] = bytes32(0xe6c26fed08d83a80d1c4908e75df0360a097203d5d8274700472bc814a038aaf);
        tiers[23] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x2fb10d7ab02b817824bb11afd349242a7458db163fbf550901b21b2ca7b7e439),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha body
        names[24] = "Geisha Body";
        svgHashes[24] = bytes32(0xb64fb722b7e251657682f34fd16eeccd10aba79dabe58dd5959e5f7aa3dd6c02);
        tiers[24] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb79331e97961a8d5423f8291146687e4902e691209ffc7cf8b5b7ac16a13e311),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        names[25] = "Baggies";
        svgHashes[25] = bytes32(0x663e30b9cdb967069d5b7b45225090777acaea80064da90782cadc6460bee7e6);
        tiers[25] = JB721TierConfig({
            price: uint104(15 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x1a35d472359b3b502d6f4ff106da0d9d189ad8efe2faa89ef2a65408b2b54e99),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Jonny utah shirt
        names[26] = "Jonny Utah Shirt";
        svgHashes[26] = bytes32(0x7cdf8a81eb2c27165103c63a8e5b5d0f13eb2c88a2e9ab1fdf9234d004523f1d);
        tiers[26] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x0e2f04af1cdf42e47c7fe28203f710cb06212657dba3e3262f71e2ef9ecfb990),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Doc coat
        names[27] = "Doc Coat";
        svgHashes[27] = bytes32(0x030131d58db79fa20f4f9084b95c4969391a1c379190f569eeeed0540a5e8ab2);
        tiers[27] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xab44e8f62ec21f0f96116363116a0546277c53cd35f212be2acd927c2fae4fc0),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Goat jersey
        names[28] = "Goat Jersey";
        svgHashes[28] = bytes32(0xbe606a173568b56aa6e273f96ba55b72c0f90ec790d0db84648de38eb4ab4b91);
        tiers[28] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 12,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc16ff870dfbc2e9e2c6f91698530f50e3ba421e66acf4ae06ba0161143a3102a),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Irie tshirt
        names[29] = "Irie Shirt";
        svgHashes[29] = bytes32(0xb61f638506572b9d5ecbfa6dc8b0a5435cedd71158fe8ce96b8a3f2f3db30f37);
        tiers[29] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc1f5670d4baab267fcc311675fc1e50038fce1d62c93d50630ff70c6d2869915),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Punk jacket
        names[30] = "Punk Jacket";
        svgHashes[30] = bytes32(0xe2cb5da2aece34f50e60ba978c14a193dea85e4b3407865c931da02869d93fe3);
        tiers[30] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb819ae53f36617ea000b6af180c932e2be0933d1f50dfc0be47ef18cdabb28a2),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zipper jacket
        names[31] = "Zipper Jacket";
        svgHashes[31] = bytes32(0x143a2052476a8aeaefba850c02a0fe97799407ce43b5772805395659e8d85f27);
        tiers[31] = JB721TierConfig({
            price: uint104(25 * (10 ** (decimals - 2))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xeae02be2522537d6663a05d34e5521884904f11885dbecb3b863cfcc9d152b19),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zucco tshirt
        names[32] = "Zucco Tshirt";
        svgHashes[32] = bytes32(0xad8511155eabb8cb57331d2926c3a3ba46a2e405a759878ee658367574d57c14);
        tiers[32] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb031547afbef6c0bd81a51385279aeaed9c1c456d87eb89bb733ccb97843a1c0),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Catana
        names[33] = "Catana";
        svgHashes[33] = bytes32(0xd79a42d671da705db1543b687ca8e9b6bac42cac6ea597b564a3e1e742fe9b2f);
        tiers[33] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x132b177438d5d82738c5245bbf8ec8ec496852a5a4774311b108e0c5d8fd61b0),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Chefs knife
        names[34] = "Chefs Knife";
        svgHashes[34] = bytes32(0x035a5677d3258331a45ade7d219562683bc35fc1cf2ac4f482a68cb29d998634);
        tiers[34] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x1d140226b7a077d6c5ec0e4210f929ba2bcf043f68c479d8028fe5ace1d5bbb7),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cheap beer
        names[35] = "Cheap Beer";
        svgHashes[35] = bytes32(0xf4ecd2829fae83572b98bd5a6bdd4da45f992e089b83e59218379cb41cfd3ef9);
        tiers[35] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x5f954334d648d9d92078a5236c690d8764ef14f36ac9b44535ceb863af4ea6d7),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Constitution
        names[36] = "Constitution";
        svgHashes[36] = bytes32(0xb53ecbb9d7d616b2050a32a27fbf849f869a8c7c067f29357d974015e763d465);
        tiers[36] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x7cd053bff782c57056fb959ec875453c81d066a62e199eede927ad669eaf8aa8),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // DJ booth
        names[37] = "DJ Booth";
        svgHashes[37] = bytes32(0xe771f7c361b8a78894e8d9af58959d39169352a3bcb32607c1f6678ed331cf30);
        tiers[37] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 10,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe5b10d8c05f0d7c1cb9ade5398f56cc46adb3dbd18cde4923c2d20cf23bb73bc),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Gas can
        names[38] = "Gas Can";
        svgHashes[38] = bytes32(0x997a889659d82a52a6b1c327720c18d6120697931cd4f906698493420f837d30);
        tiers[38] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xbecef4bd845dc879155f9f7763cee76dfb2cc24a4d2caf2ff70a4e3a72c619dd),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Lightsaber
        names[39] = "Lightsaber";
        svgHashes[39] = bytes32(0xbe9c4490f821bb1eb1f64b0a5ee1cb041b139fd8718e1e2ad055d934a72e9946);
        tiers[39] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 5000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x446262f32aa23669ced760b1ffa8698eacf579ce3d13ba4d7ce56112ab44beb9),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Potion
        names[40] = "Potion";
        svgHashes[40] = bytes32(0xc42a825141fd893ce876f70935e33a7353ed7bd60c107b1b0492227cf7bc0d18);
        tiers[40] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 50,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb7caa923670e8f7f28ec0859bb0d0ec1bd9ce1e7215ede5b25887e6424390f77),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dagger
        names[41] = "Dagger";
        svgHashes[41] = bytes32(0x8e4c41ab02523b6609ad338d0c6bfb5af795bc4e34749fbde4663df315e9a471);
        tiers[41] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x7bbc0c2c2b46c0c70f103fcb7b91a2674c42e1a09b9ac9b19f9c236614f86ef0),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(tiers, new uint256[](0));

        uint256[] memory tierIds = new uint256[](42);
        for (uint256 i; i < 42; i++) {
            tierIds[i] = i + 5;
        }

        bannyverse.resolver.setSvgHashsOf(tierIds, svgHashes);
        bannyverse.resolver.setTierNames(tierIds, names);
        bannyverse.resolver.setSvgBaseUri("https://bannyverse.infura-ipfs.io/ipfs/");
    }
}
