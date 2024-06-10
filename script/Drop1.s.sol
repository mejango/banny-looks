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
        sphinxConfig.projectName = "bannyverse-core-testnet";
        sphinxConfig.mainnets = ["ethereum", "optimism", "base", "arbitrum"];
        sphinxConfig.testnets = ["ethereum_sepolia", "optimism_sepolia", "base_sepolia", "arbitrum_sepolia"];
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

        string[] memory names = new string[](44);
        bytes32[] memory svgHashes = new bytes32[](44);
        JB721TierConfig[] memory products = new JB721TierConfig[](44);

        // Desk
        names[0] = "Work Station";
        svgHashes[0] = bytes32(0xab22e30cb6daaac109ea557a14af9b65f680d46cc563a0b25dd42483f9286bf7);
        products[0] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x5665b0c125d1bccccb78cc0ffc429e66ce41ed3bccebba51209d04636cadbd2c),
            category: 1,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Pew pew
        names[1] = "Pew Pew";
        svgHashes[1] = bytes32(0x71f6918188cd0bc9eb1d5baed9340491efb41af1d358bbeb10912a02e95323f8);
        products[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6cb06872575a04a0c4527157eb4719be10b6474d08aa2ce2a4ac5bcb0da996ea),
            category: 2,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Bandolph staff
        names[2] = "Bandolph Staff";
        svgHashes[2] = bytes32(0x790e607150e343fd457bb0cefe5fd12cd216b722dabfa19adbee1f1e537fd1c7);
        products[2] = JB721TierConfig({
            price: uint104(125 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x7206771942e806053d6ed8aa90040e53a07319e4fd1f938fc4a10879b7bd2da9),
            category: 2,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Blockchain
        names[3] = "Block Chain";
        svgHashes[3] = bytes32(0x5e609d387ea091bc8884a753ddd28dd43b8ed1243b29de6e9354ef1ab109a0b9);
        products[3] = JB721TierConfig({
            price: uint104(125 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xef6478be50575bade53e7ce4c9fb5b399643bcabed94f2111afb63e97fb9fd44),
            category: 3,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Head
        names[4] = "Astronaut Head";
        svgHashes[4] = bytes32(0x7054504d4eef582f2e3411df719fba9d90e94c2054bf48e2efa175b4f37cc1e9);
        products[4] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xe26d20762024435aedd91058ac9bc9900d719e1f7a04cace501d83a4c1f40941),
            category: 4,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Nerd
        names[5] = "Nerd Glasses";
        svgHashes[5] = bytes32(0x964356f8cbc40b81653a219d94da9d49d0bd5b745aa6bf4db16a14aa81c129ac);
        products[5] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9f76cb495fd79397cba4fe3d377a5aa2fdd63df218f3b3022c6cc8e32478b494),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Banny vision pro
        names[6] = "Banny Vision Pro";
        svgHashes[6] = bytes32(0x12702d5d843aff058610a01286446401be4175c27abaaec144d8970f99db34e2);
        products[6] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: producer,
            encodedIPFSUri: bytes32(0xf01423f9dae3de4adc7e372e6902a351e2c6193a385dde90f5baf37165914831),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: true,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cyberpunk glasses
        names[7] = "Cyberpunk Glasses";
        svgHashes[7] = bytes32(0x5930f0bb8cb34d82b88a13391bcccf936e09be535f2848ba7911b2a98615585d);
        products[7] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x325c138f1f38e5b5f90a57a248a2f5afe6af738b2adfc825cf9f413bbcf50fa1),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Investor shades
        names[8] = "Investor Shades";
        svgHashes[8] = bytes32(0x4410654936785cff70498421a8805ad2f9d5101a8c18168264ef94df671db10e);
        products[8] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x7dc7e556a7ac39c473da85165df3d094c6ed9258003fb7dc3d9a8582bcb0dc7f),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff glasses
        names[9] = "Proff Glasses";
        svgHashes[9] = bytes32(0x54004065d83ca03befdf72236331f5b532c00920613d8774ebd8edbf277c345a);
        products[9] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb06dbd64696994798dee9e00d406a649191524a95e715532f1bdebc92f00aebd),
            category: 5,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Gap tooth
        names[10] = "Gap Teeth";
        svgHashes[10] = bytes32(0x5b5a29873435b40784f64c5d9bb5d95ecebd433c57493e38f3eb816a0dd9fd7f);
        products[10] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x52815d712399165b921df61795581a8c20ad9acf3502e777e20a782b7bc11d54),
            category: 6,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy shoes
        names[11] = "Dorthy Shoes";
        svgHashes[11] = bytes32(0x70e3cd2a18392b2b6342ce7df4a6a9e3be8dbb2251d8039052353c8e31f24054);
        products[11] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb4e3055480e2d17e000feb81b3c15aabab67bd4e30c93daeb0d1af749065c34b),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut boots
        names[12] = "Astronaut Boots";
        svgHashes[12] = bytes32(0x118692cc1bcd7d9b88049b501b40d03b9df1275082ee7e01fd62ec0c1b884f4c);
        products[12] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x47aa497e9865b001dc81b029e4a9b29c5e7fbd4a0ae711a12e5ad822be3a3e53),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Flops
        names[13] = "Flops";
        svgHashes[13] = bytes32(0x4cfff364895473bd9e138859d11a0974c986ed5f0769e81023b084891a678641);
        products[13] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xaa45eb559a686dd61653a2980decb55767d053d68c45e631e3912d13fdba9be9),
            category: 7,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Astronaut Body
        names[14] = "Astronaut Suit";
        svgHashes[14] = bytes32(0xdbcfc1891ab9d56cb964f3432f867a77293352e38edca3b59b34061e46a31b83);
        products[14] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x5fbc1c58d608acd436c18e11edc72d3ae436e1a4c15d127b28a9a24879013d3c),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Sweatsuit
        names[15] = "Sweatsuit";
        svgHashes[15] = bytes32(0xfbb3a6dde059e3e3115c3e83fd675d1739ec29afa62999fa759ed878f48e9aa2);
        products[15] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 20,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x823466de69eaf605d3a62366e5e9dbd6649a71da146f791f94628d4749a2da55),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy dress
        names[16] = "Dorthy Dress";
        svgHashes[16] = bytes32(0xfc0eda6d0165d339239bfda3cf68d630949b03c588e3b6d45175c6fc8f00e289);
        products[16] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x017db86219678b824995b8556e7073d65af87212671312212365497708675c41),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha body
        names[17] = "Geisha Gown";
        svgHashes[17] = bytes32(0x5f8c77bc896a90a35580078ee7ea51460b5694aec68db3d749fd1dc0e9b05c6c);
        products[17] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xdf7d4084b087b22cc172e1df3a2b465b5386a950e9bcd53ed424014a0a86ee57),
            category: 8,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Baggies
        names[18] = "Baggies";
        svgHashes[18] = bytes32(0x2f0cab70c7d07048ccc7b6855bba39cdd95be15a109c8eaa401d9be6d503ca2a);
        products[18] = JB721TierConfig({
            price: uint104(15 * (10 ** (decimals - 1))),
            initialSupply: 30,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x745b3b4f18aab6ad0d8465d34751ca8eb5b9c267dee6ec8bf63686b508afacf3),
            category: 9,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Jonny utah shirt
        names[19] = "Jonny Utah Shirt";
        svgHashes[19] = bytes32(0xf62770cf77965461df8528baec000228c713e749b4dcc12e278b1025507dc0ff);
        products[19] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x815c7dfb119da1e3802754f8ce364caf7a8069e331e35c3f20446800579d8df8),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Doc coat
        names[20] = "Doc Coat";
        svgHashes[20] = bytes32(0x6650b989b4ad53d12fd306bf4a12f5afbca2072c3241fdcb96e434443039d1f7);
        products[20] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc77fe2f93a5a48ad7f59a3c6c40dd76317e47605fcb74b85a4c5bea160fdab6e),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Goat jersey
        names[21] = "Goat Jersey";
        svgHashes[21] = bytes32(0xcca8b9f46f75822d78e7f3125ba4832e24ffe1711f6f01d00cdccb6669f752f2);
        products[21] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 12,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x2b62afa12feb307f005902e6bec09f15f8f5d7ba09d937f1162e5d2f00c21e12),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Irie tshirt
        names[22] = "Irie Shirt";
        svgHashes[22] = bytes32(0xd26b2eaad19396b85f4ae09c702717969b72b8c63021821e0d35addd85e7bbd1);
        products[22] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x4d4b149bded92db977ac35a77bcfff72270eaee404db8751b27ec18030511d3b),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Punk jacket
        names[23] = "Punk Jacket";
        svgHashes[23] = bytes32(0x44cb972aab236c8c01afef7addb0f19a0fab02cfdc7b5065d662b53ab970f310);
        products[23] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 50,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x5ec40dc2aad2a009266337a198d4b9098cd968d08c06cdc328efd4789f974aa4),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zipper jacket
        names[24] = "Zipper Jacket";
        svgHashes[24] = bytes32(0x7177dfec617d77cf78e8393fe373b68c7bc755edd1541c0decc952e99ec80304);
        products[24] = JB721TierConfig({
            price: uint104(25 * (10 ** (decimals - 2))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xb8658c65907f280bfbd228ec384f0dfdfe55401505dc0f303d7d3d6a68a6414b),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Zucco tshirt
        names[25] = "Zucco Tshirt";
        svgHashes[25] = bytes32(0x2a69ce643e565cb4fe648dc9b03020b0749ec780748d43153ee4c6770c76adbf);
        products[25] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x04e22ea49d80f346b7a5a9013169470824f71faa7d9e0155a71f4afc3fa63f89),
            category: 10,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Club beanie
        names[26] = "Club Beanie";
        svgHashes[26] = bytes32(0x0a8d7c8ff075db0e66638bb51eea732a53641b09b39de68d1cbeafe9099f9b6e);
        products[26] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 1000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x9a29e975b191f800744d74b11c580fdd74b2db73c95426af36e28cf00d66da97),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dorthy hair
        names[27] = "Dorthy Hair";
        svgHashes[27] = bytes32(0x5f2bec3082d7039474f6cba827a3fbd4d4f8e21f22d304edfbc6de77a8b529cf);
        products[27] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x52a03dc3e983121f275cadc2d86626e0fca8a9901f3dc7d0bbee826e5d3d409d),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Farmer hat
        names[28] = "Farmer Hat";
        svgHashes[28] = bytes32(0xcf90bc8459345bcfae00796c4641c0bc8868c01d6339a54ef4d3c4fa1737cfd8);
        products[28] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc583623dc7a3e61bfc04813f8c975eba8a22aeafe3d741edff1e2c97ac520737),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Geisha hair
        names[29] = "Geisha Hair";
        svgHashes[29] = bytes32(0x17b939b04709c357480bdfa54cf2007d7898f4bf048bf12efa6cd8e3af4d711c);
        products[29] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 100,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x58f8e217cfafd0a6feff40f4822790cdc19aba5dd4d4948f4c1bd5e313c90e8d),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Headphones
        names[30] = "Headphones";
        svgHashes[30] = bytes32(0xf1850876ede53102140881e04a4a0e532ba6a08bc0fb64dee279d11c98d64dbf);
        products[30] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x3e67840649fabab6d62f92bad701a6248b77f86ea8fcd66dc88dfbcba1134d85),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Natty dread
        names[31] = "Natty Dred";
        svgHashes[31] = bytes32(0x04ae3342ce08da16f61d32e4ce7034dff0223e462afa48019b90c94afc19b939);
        products[31] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xd4724e692969066fc0b3587b8e18d1589205d1e1f133d7f9f8d63d14b6d1862f),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Peachhair
        names[32] = "Peach Hair";
        svgHashes[32] = bytes32(0xdf7b9e74c552908290a05388f905a503978a289c44ffb61e510df43f2955d435);
        products[32] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xde4c6e589f4e99cda7205236a99db750638236007b2dd03d79de1146102d7f81),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Proff hair
        names[33] = "Proff Hair";
        svgHashes[33] = bytes32(0x501769b2b47a8aedf4b328f6cf0076200df07ce2087f5e082f49e815f54595b9);
        products[33] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 200,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x766001db70e4a18e76dbbd9e4b0f9e47b5a9c4daa1a7c3727190a154daabfa1c),
            category: 11,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Catana
        names[34] = "Catana";
        svgHashes[34] = bytes32(0xbe7e7bb20da87fffa92e867bf0cd3267df180e24ba6eae7a1d434c56856ef2f5);
        products[34] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 250,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xa4d2eb02df6eb99cbbdc3603a116b3b9dcd45f865a8c8396611ea5f879deee59),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Chefs knife
        names[35] = "Chefs Knife";
        svgHashes[35] = bytes32(0x705180b5aee8e57d0a0783d22fc30dc95e3e84fac36e9d96fef96fabfa58d1f9);
        products[35] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 500,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x18abc38e7f1c5c014398f705131aac80196dcd0da2b5f02c103e1a549433e8b3),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Cheap beer
        names[36] = "Cheap Beer";
        svgHashes[36] = bytes32(0x993a2c657f43e19820f3e23677e650705d0c8c6a0ccd88a381aa54d2da7ba047);
        products[36] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xc498a98bea66a8b44297631f136a7326f7a28b882058829588979b186d06baff),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Constitution
        names[37] = "Constitution";
        svgHashes[37] = bytes32(0xaf0826d8eac1e57789077f43e6f979488da6f619f72f9f0ff50a52ebcca3bfa3);
        products[37] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x3bd1186293e2d3e4def734a669c348976e1ba0cdc628a19cd5a3b38e0bee28f9),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // DJ booth
        names[38] = "DJ Deck";
        svgHashes[38] = bytes32(0x2c9538556986d134ddec2831e768233f587b242e887df9bb359b3aefffa3c5a6);
        products[38] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 10,
            votingUnits: 0,
            reserveFrequency: 10,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x6b8bfbf33e574747b69039adfc6788101047a4593db7ea7ff4f6fa5a890e9ecf),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Gas can
        names[39] = "Gas Can";
        svgHashes[39] = bytes32(0x89808b70d019077e4f986b4a60af4ec15fc72ed022bc5e5476441d98f8ce1d1d);
        products[39] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 25,
            votingUnits: 0,
            reserveFrequency: 25,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xf11d1cea4163e0dfa2be8d60b0cd82d075fb37d969e40439df4e91db53bf7f3e),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Lightsaber
        names[40] = "Lightsaber";
        svgHashes[40] = bytes32(0xf7017a80e9fa4c3fc052a701c04374176620a8e5befa39b708a51293c4d8f406);
        products[40] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 5000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xedf8136f97347d1fee1fc14b1b9cbdb6d170a75c3860a92664c56060712567f3),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Potion
        names[41] = "Potion";
        svgHashes[41] = bytes32(0xefdbac65db3868ead1c1093ea20f0b2d77e9095567f6358e246ba160ec545e09);
        products[41] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 50,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0xbcc0c314f94ccb0f8f2717aff0b2096a28ace5b70465b5b4e106981fdbceb238),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Dagger
        names[42] = "Dagger";
        svgHashes[42] = bytes32(0xcb3bc383475808e8949861811434cfc233fa8c5b6f6d75e19371e84a25a77171);
        products[42] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 3))),
            initialSupply: 150,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x8e6b0c2a12f9bcf9c5ac4ef89b888a2ac893b153c4c68932657848e92e60f259),
            category: 12,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });
        // Mouthstraw
        names[43] = "Wheat Straw";
        svgHashes[43] = bytes32(0x112b8217bb82aebc91e80c935244dce8aa30d4d8df5f98382054b97037dc0c94);
        products[43] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 15,
            votingUnits: 0,
            reserveFrequency: 15,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(0x1d1484b4b37a882e59ab5a01c1a32528e703e15156b9bb9b5372b61fec84c0df),
            category: 13,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: false
        });

        hook.adjustTiers(products, new uint256[](0));

        uint256[] memory productIds = new uint256[](44);
        for (uint256 i; i < 44; i++) {
            productIds[i] = i + 5;
        }

        bannyverse.resolver.setSvgHashsOf(productIds, svgHashes);
        bannyverse.resolver.setProductNames(productIds, names);
        bannyverse.resolver.setSvgBaseUri("https://bannyverse.infura-ipfs.io/ipfs/");
    }
}
