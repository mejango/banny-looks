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

        string[] memory names = new string[](43);
        bytes32[] memory svgHashes = new bytes32[](43);
        JB721TierConfig[] memory tiers = new JB721TierConfig[](43);

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
        names[3] = "Nerd Glasses";
        svgHashes[3] = bytes32(0xedd5463390ba18e320374b3a7c2405a98c6752a4cfc10f1edc7389de636590d0);
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x0f7ceb1fe1e599c83a60ec3be7a8f7c553ca206e134b2f9bf3545cbeb6e794a7),
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
            category: 5,
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
            category: 5,
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
            category: 5,
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
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Gap tooth
        names[8] = "Gap tooth";
        svgHashes[8] = bytes32(0xcb30782c0fc8732cf9beee782666bfe80486c933b19b5751a0ad1e77a8a1284c);
        tiers[8] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x04e77c576ab3c1b6532f308226bf713773fe6929138a40fab634abaec0bc6a97),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy shoes
        names[9] = "Dorthy Shoes";
        svgHashes[9] = bytes32(0x83eef42ebf5df52d40a8ea913b1ad986f45351460f6febce394ae4853c134686);
        tiers[9] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xef96aab31bf296788a66569d1da4df9a34cf2c2bf29f84ec6bf04282be19e71b),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut boots
        names[10] = "Astronaut boots";
        svgHashes[10] = bytes32(0xe3fc13e93b0d570faa6e42e6d81898fe223f45eee4e23a5f66f03f636318c398);
        tiers[10] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x4ee367dc00f3dbe5682f730405ddcb4dabfc4c8a7801a4143e16d298116ba1f5),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Flops
        names[11] = "Flops";
        svgHashes[11] = bytes32(0x9c9340ff849440e2b68188b72379cdfd2afbdd3a80ea19cdf6dd41a0c862d0d2);
        tiers[11] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x4c43397ab86628bd2f5c8237de248755b389b25f40e5b19eab7f4db67fac0233),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Body
        names[12] = "Astronaut Body";
        svgHashes[12] = bytes32(0x4b88d7666c4bd78638142a3de0d606b037b68b0c14fccc9ab725596f425d77a3);
        tiers[12] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9d3859ef0aad4c149d41ba0d393ba52c0514ff12f58a145b9c6d3715953b3f41),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Sweatsuit
        names[13] = "Sweatsuit";
        svgHashes[13] = bytes32(0x896b471bc6b782688b7ae9746471a81c8de450bf6a342357b0ca72fcd9aa7562);
        tiers[13] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 20,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x19a8fdf9a0c48e17fc0817ccbd9ed80c634436286a36270f14706aa3ee0cc10e),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy dress
        names[14] = "Dorthy Dress";
        svgHashes[14] = bytes32(0xe6c26fed08d83a80d1c4908e75df0360a097203d5d8274700472bc814a038aaf);
        tiers[14] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x2fb10d7ab02b817824bb11afd349242a7458db163fbf550901b21b2ca7b7e439),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha body
        names[15] = "Geisha Body";
        svgHashes[15] = bytes32(0xb64fb722b7e251657682f34fd16eeccd10aba79dabe58dd5959e5f7aa3dd6c02);
        tiers[15] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb79331e97961a8d5423f8291146687e4902e691209ffc7cf8b5b7ac16a13e311),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        names[16] = "Baggies";
        svgHashes[16] = bytes32(0x663e30b9cdb967069d5b7b45225090777acaea80064da90782cadc6460bee7e6);
        tiers[16] = JB721TierConfig({
            price: uint104(15 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x1a35d472359b3b502d6f4ff106da0d9d189ad8efe2faa89ef2a65408b2b54e99),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Jonny utah shirt
        names[17] = "Jonny Utah Shirt";
        svgHashes[17] = bytes32(0x7cdf8a81eb2c27165103c63a8e5b5d0f13eb2c88a2e9ab1fdf9234d004523f1d);
        tiers[17] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x0e2f04af1cdf42e47c7fe28203f710cb06212657dba3e3262f71e2ef9ecfb990),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Doc coat
        names[18] = "Doc Coat";
        svgHashes[18] = bytes32(0x030131d58db79fa20f4f9084b95c4969391a1c379190f569eeeed0540a5e8ab2);
        tiers[18] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xab44e8f62ec21f0f96116363116a0546277c53cd35f212be2acd927c2fae4fc0),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Goat jersey
        names[19] = "Goat Jersey";
        svgHashes[19] = bytes32(0xbe606a173568b56aa6e273f96ba55b72c0f90ec790d0db84648de38eb4ab4b91);
        tiers[19] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 12,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc16ff870dfbc2e9e2c6f91698530f50e3ba421e66acf4ae06ba0161143a3102a),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Irie tshirt
        names[20] = "Irie Shirt";
        svgHashes[20] = bytes32(0xb61f638506572b9d5ecbfa6dc8b0a5435cedd71158fe8ce96b8a3f2f3db30f37);
        tiers[20] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc1f5670d4baab267fcc311675fc1e50038fce1d62c93d50630ff70c6d2869915),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Punk jacket
        names[21] = "Punk Jacket";
        svgHashes[21] = bytes32(0xe2cb5da2aece34f50e60ba978c14a193dea85e4b3407865c931da02869d93fe3);
        tiers[21] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb819ae53f36617ea000b6af180c932e2be0933d1f50dfc0be47ef18cdabb28a2),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zipper jacket
        names[22] = "Zipper Jacket";
        svgHashes[22] = bytes32(0x143a2052476a8aeaefba850c02a0fe97799407ce43b5772805395659e8d85f27);
        tiers[22] = JB721TierConfig({
            price: uint104(25 * (10 ** (decimals - 2))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xeae02be2522537d6663a05d34e5521884904f11885dbecb3b863cfcc9d152b19),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zucco tshirt
        names[23] = "Zucco Tshirt";
        svgHashes[23] = bytes32(0xad8511155eabb8cb57331d2926c3a3ba46a2e405a759878ee658367574d57c14);
        tiers[23] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb031547afbef6c0bd81a51385279aeaed9c1c456d87eb89bb733ccb97843a1c0),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Club beanie
        names[24] = "Club Beanie";
        svgHashes[24] = bytes32(0x5665e5d760e91466c4b9f094b710c26b93563846e39f08bff765ef71951d2b7b);
        tiers[24] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 1000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe47cfa6836b80adeecee131acaea60cc82e679eb6c3318f5dec7882d8e472815),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy hair
        names[25] = "Dorthy Hair";
        svgHashes[25] = bytes32(0x026c2ccff1de658376bda9bfe095ccf521b7a751c5ca1c9ef2b33585497f277d);
        tiers[25] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf8377fbe642701e36fd50d164b786de4399ec24df608096c1291d805c29b6fe5),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Farmer hat
        names[26] = "Farmer Hat";
        svgHashes[26] = bytes32(0x9a368bd3010e5a5b753766092968684d54eb44d361079fc34674df4084ab3ed5);
        tiers[26] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xde2a0e57ef2100b8c2c8b2629e27ac7a9eb8b23f5a6399996fbe4e7f191dd1fe),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha hair
        names[27] = "Geisha Hair";
        svgHashes[27] = bytes32(0xeabb735dfb47f2b4871b6591b1d28e1cf4356923205ac387df9f7193afe69407);
        tiers[27] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd92856f79509229248cb67e6d6c0c74db5e07e195e827109a8747c363dcdbfd8),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Headphones
        names[28] = "Headphones";
        svgHashes[28] = bytes32(0x1bab46e99e3c5ed6df7da8e4321bb21941c813badd48e51a24e545db2e2b8bc4);
        tiers[28] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe645ea65384470742f0a8e03871596b0e66e70cd090e1dd82aa2a3b8cfd6fb6d),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Natty dread
        names[29] = "Natty Dred";
        svgHashes[29] = bytes32(0xb93f4b85e0d09ae317d49e4fac84dd1e9750d43f6bcdde00d128e641e857d79e);
        tiers[29] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb8d50404ea95e080d341e70658ba33003d31106215b953e622423ae98c2a3565),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Peachhair
        names[30] = "Peach Hair";
        svgHashes[30] = bytes32(0xf2284429ff70d042d570e91023d32710c981fb46bb1ea8f7927138602537c94d);
        tiers[30] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xcf71366b16c874b5633c5d2cd2a6d120d64f7264dd92fb19624854bbbde4de31),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff hair
        names[31] = "Proff Hair";
        svgHashes[31] = bytes32(0x61b237118ce3d7fd12cd6aa3f9192df6c3e5c6931299c9c6cd2fb91edbfe2913);
        tiers[31] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc2d6af5d4d4c95c11053432ac0eecea67ee9005701cdd60fb984bf1953ba5d7f),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Quaid helmet
        names[32] = "Quaid Helmet";
        svgHashes[32] = bytes32(0xf6d1df810231cb8d223287bdf14055c6bce0cac2db794beb7270f66dda9c93de);
        tiers[32] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9197306147b19bfb7d866646d206abdac486a6a6f28e95320d3d2943a8d5307e),
            category: 11,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
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
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Mouthstraw
        names[42] = "Mouthstraw";
        svgHashes[42] = bytes32(0xf20d8f8fe7a026f98aa9181ba0242d010429cd0cd1542fa8a5f218f5c47a4a38);
        tiers[42] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 15,
            votingUnits: 0,
            reserveFrequency: 15,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf5377b3fe2fef80802eeeea046877640d654c2922df91c141e7cfe53e600c431),
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
