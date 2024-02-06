// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, stdJson} from "lib/forge-std/src/Script.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {JBConstants} from "lib/juice-contracts-v4/src/libraries/JBConstants.sol";
import {JBTerminalConfig} from "lib/juice-contracts-v4/src/structs/JBTerminalConfig.sol";
import {JBPayHookSpecification} from "lib/juice-contracts-v4/src/structs/JBPayHookSpecification.sol";
import {IJBTerminal} from "lib/juice-contracts-v4/src/interfaces/terminal/IJBTerminal.sol";
import {IJBRulesets} from "lib/juice-contracts-v4/src/interfaces/IJBRulesets.sol";
import {IJBPrices} from "lib/juice-contracts-v4/src/interfaces/IJBPrices.sol";
import {IJBBuybackHook} from "lib/juice-buyback/src/interfaces/IJBBuybackHook.sol";
import {IJB721TiersHook} from "lib/juice-721-hook/src/interfaces/IJB721TiersHook.sol";
import {IJB721TiersHookStore} from "lib/juice-721-hook/src/interfaces/IJB721TiersHookStore.sol";
import {IJB721TokenUriResolver} from "lib/juice-721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {JB721TierConfig} from "lib/juice-721-hook/src/structs/JB721TierConfig.sol";
import {JB721TiersHookFlags} from "lib/juice-721-hook/src/structs/JB721TiersHookFlags.sol";
import {JB721InitTiersConfig} from "lib/juice-721-hook/src/structs/JB721InitTiersConfig.sol";
import {JBDeploy721TiersHookConfig} from "lib/juice-721-hook/src/structs/JBDeploy721TiersHookConfig.sol";
import {REVStageConfig} from "lib/revnet-contracts/src/structs/REVStageConfig.sol";
import {REVBuybackHookConfig} from "lib/revnet-contracts/src/structs/REVBuybackHookConfig.sol";
import {REVDeploy721TiersHookConfig} from "lib/revnet-contracts/src/structs/REVDeploy721TiersHookConfig.sol";
import {REVBuybackPoolConfig} from "lib/revnet-contracts/src/structs/REVBuybackPoolConfig.sol";
import {REVConfig} from "lib/revnet-contracts/src/structs/REVConfig.sol";
import {REVCroptopDeployer} from "lib/revnet-contracts/src/REVCroptopDeployer.sol";
import {AllowedPost} from "lib/croptop-contracts/src/CroptopPublisher.sol";
import {Banny721TokenUriResolver} from "src/Banny721TokenUriResolver.sol";

contract Deploy is Script {
    function run() public {
        uint256 chainId = block.chainid;
        address producer;
        string memory chain;
        // Ethereun Mainnet
        if (chainId == 1) {
            chain = "1";
            // Ethereum Sepolia
        } else if (chainId == 11_155_111) {
            chain = "11155111";
            // Optimism Mainnet
        } else if (chainId == 420) {
            chain = "420";
            // Optimism Sepolia
        } else if (chainId == 11_155_420) {
            chain = "11155420";
            // Polygon Mainnet
        } else if (chainId == 137) {
            chain = "137";
            // Polygon Mumbai
        } else if (chainId == 80_001) {
            chain = "80001";
        } else {
            revert("Invalid RPC / no juice contracts deployed on this network");
        }

        address multiTerminalAddress = _getDeploymentAddress(
            string.concat("lib/juice-contracts-v4/broadcast/Deploy.s.sol/", chain, "/run-latest.json"),
            "JBMultiTerminal"
        );

        address rulesetsAddress = _getDeploymentAddress(
            string.concat("lib/juice-contracts-v4/broadcast/Deploy.s.sol/", chain, "/run-latest.json"), "JBRulesets"
        );

        address buybackHookAddress = _getDeploymentAddress(
            string.concat("lib/juice-buyback/broadcast/Deploy.s.sol/", chain, "/run-latest.json"), "JBBuybackHook"
        );

        address nftHookAddress = _getDeploymentAddress(
            string.concat("lib/juice-721-hook/broadcast/Deploy.s.sol/", chain, "/run-latest.json"), "JB721TiersHook"
        );

        address hookStoreAddress = _getDeploymentAddress(
            string.concat("lib/juice-721-hook/broadcast/Deploy.s.sol/", chain, "/run-latest.json"),
            "JB721TiersHookStore"
        );

        address revCroptopDeployerAddress = _getDeploymentAddress(
            string.concat("lib/revnet-contracts/broadcast/Deploy.s.sol/", chain, "/run-latest.json"),
            "REVCroptopDeployer"
        );

        string memory name = "Bannyverse";
        string memory symbol = "$BANNY";
        string memory projectUri = "";
        string memory baseUri = "ipfs://";
        string memory contractUri = "";
        uint32 nativeCurrency = uint32(uint160(JBConstants.NATIVE_TOKEN));
        uint8 decimals = 18;
        uint256 decimalMultiplier = 10 ** decimals;
        uint40 oneDay = 86_400;

        JBTerminalConfig[] memory terminalConfigurations = new JBTerminalConfig[](1);
        address[] memory tokensToAccept = new address[](1);
        tokensToAccept[0] = JBConstants.NATIVE_TOKEN;
        terminalConfigurations[0] =
            JBTerminalConfig({terminal: IJBTerminal(multiTerminalAddress), tokensToAccept: tokensToAccept});
        REVStageConfig[] memory stageConfigurations = new REVStageConfig[](2);
        uint40 start = uint40(block.timestamp);
        stageConfigurations[0] = REVStageConfig({
            startsAtOrAfter: start,
            operatorSplitRate: uint16(JBConstants.MAX_RESERVED_RATE / 2),
            initialIssuanceRate: uint112(1_000_000 * decimalMultiplier),
            priceCeilingIncreaseFrequency: oneDay,
            priceCeilingIncreasePercentage: uint32(JBConstants.MAX_DECAY_RATE / 20), // 5%
            priceFloorTaxIntensity: uint16(JBConstants.MAX_REDEMPTION_RATE / 5) // 0.2
        });
        stageConfigurations[1] = REVStageConfig({
            startsAtOrAfter: start + 86_400 * 28,
            operatorSplitRate: uint16(JBConstants.MAX_RESERVED_RATE / 2),
            initialIssuanceRate: uint112(100_000 * decimalMultiplier),
            priceCeilingIncreaseFrequency: 7 * oneDay,
            priceCeilingIncreasePercentage: uint16(JBConstants.MAX_DECAY_RATE / 100), // 1%
            priceFloorTaxIntensity: uint16(JBConstants.MAX_REDEMPTION_RATE / 2) // 0.5
        });
        REVConfig memory revnetConfiguration = REVConfig({
            baseCurrency: nativeCurrency,
            premintTokenAmount: 80_000_000 * decimalMultiplier,
            initialOperator: producer,
            stageConfigurations: stageConfigurations
        });
        REVBuybackPoolConfig[] memory buybackPoolConfigurations = new REVBuybackPoolConfig[](1);
        buybackPoolConfigurations[0] = REVBuybackPoolConfig({
            token: JBConstants.NATIVE_TOKEN,
            fee: 500, //TODO
            twapWindow: 0, // TODO
            twapSlippageTolerance: 0 // TODO
        });

        REVBuybackHookConfig memory buybackHookConfiguration = REVBuybackHookConfig({
            hook: IJBBuybackHook(buybackHookAddress),
            poolConfigurations: buybackPoolConfigurations
        });

        JB721TierConfig[] memory tiers = new JB721TierConfig[](4);
        tiers[0] = JB721TierConfig({
            price: uint104(1 * decimalMultiplier),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: 0,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[1] = JB721TierConfig({
            price: uint104(1 * decimalMultiplier),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: 0,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[2] = JB721TierConfig({
            price: uint104(1 * decimalMultiplier),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: 0,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[3] = JB721TierConfig({
            price: uint104(1 * decimalMultiplier),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: 0,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });

        AllowedPost[] memory allowedPosts = new AllowedPost[](1);
        allowedPosts[0] = AllowedPost({
            nft: nftHookAddress,
            category: 100,
            minimumPrice: 10 ** 16,
            minimumTotalSupply: 10,
            maximumTotalSupply: 0,
            allowedAddresses: new address[](0)
        });

        vm.startBroadcast();

        // Deploy the Banny URI Resolver.
        Banny721TokenUriResolver resolver = new Banny721TokenUriResolver(IJB721TiersHook(nftHookAddress), msg.sender);

        // Deploy the $BANNY Revnet.
        REVCroptopDeployer(revCroptopDeployerAddress).deployCroptopRevnetFor({
            name: name,
            symbol: symbol,
            projectUri: projectUri,
            configuration: revnetConfiguration,
            terminalConfigurations: terminalConfigurations,
            buybackHookConfiguration: buybackHookConfiguration,
            hookConfiguration: REVDeploy721TiersHookConfig({
                baseline721HookConfiguration: JBDeploy721TiersHookConfig({
                    name: name,
                    symbol: symbol,
                    rulesets: IJBRulesets(rulesetsAddress),
                    baseUri: baseUri,
                    tokenUriResolver: IJB721TokenUriResolver(address(resolver)),
                    contractUri: contractUri,
                    tiersConfig: JB721InitTiersConfig({
                        tiers: tiers,
                        currency: nativeCurrency,
                        decimals: decimals,
                        prices: IJBPrices(address(0))
                    }),
                    reserveBeneficiary: address(0),
                    store: IJB721TiersHookStore(hookStoreAddress),
                    flags: JB721TiersHookFlags({
                        noNewTiersWithReserves: false,
                        noNewTiersWithVotes: false,
                        noNewTiersWithOwnerMinting: false,
                        preventOverspending: false
                    })
                }),
                owner: producer
            }),
            otherPayHooksSpecifications: new JBPayHookSpecification[](0),
            extraHookMetadata: 0,
            allowedPosts: allowedPosts
        });

        vm.stopBroadcast();
    }

    /// @notice Get the address of a contract that was deployed by the Deploy script.
    /// @dev Reverts if the contract was not found.
    /// @param path The path to the deployment file.
    /// @param contractName The name of the contract to get the address of.
    /// @return The address of the contract.
    function _getDeploymentAddress(string memory path, string memory contractName) internal view returns (address) {
        string memory deploymentJson = vm.readFile(path);
        uint256 nOfTransactions = stdJson.readStringArray(deploymentJson, ".transactions").length;

        for (uint256 i = 0; i < nOfTransactions; i++) {
            string memory currentKey = string.concat(".transactions", "[", Strings.toString(i), "]");
            string memory currentContractName =
                stdJson.readString(deploymentJson, string.concat(currentKey, ".contractName"));

            if (keccak256(abi.encodePacked(currentContractName)) == keccak256(abi.encodePacked(contractName))) {
                return stdJson.readAddress(deploymentJson, string.concat(currentKey, ".contractAddress"));
            }
        }

        revert(string.concat("Could not find contract with name '", contractName, "' in deployment file '", path, "'"));
    }
}
