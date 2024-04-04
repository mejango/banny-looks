// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@bananapus/core/script/helpers/CoreDeploymentLib.sol";
import "@bananapus/721-hook/script/helpers/Hook721DeploymentLib.sol";
import "@bananapus/suckers/script/helpers/SuckerDeploymentLib.sol";
import "@croptop/core/script/helpers/CroptopDeploymentLib.sol";
import "@rev-net/core/script/helpers/RevnetCoreDeploymentLib.sol";
import "@bananapus/buyback-hook/script/helpers/BuybackDeploymentLib.sol";

import {JBPermissionIds} from "@bananapus/permission-ids/src/JBPermissionIds.sol";
import {JBPermissionsData} from "@bananapus/core/src/structs/JBPermissionsData.sol";
import {JBConstants} from "@bananapus/core/src/libraries/JBConstants.sol";
import {JBTerminalConfig} from "@bananapus/core/src/structs/JBTerminalConfig.sol";
import {REVStageConfig} from "@rev-net/core/src/structs/REVStageConfig.sol";
import {REVConfig} from "@rev-net/core/src/structs/REVConfig.sol";
import {REVCroptopAllowedPost} from "@rev-net/core/src/structs/REVCroptopAllowedPost.sol";
import {REVBuybackPoolConfig} from "@rev-net/core/src/structs/REVBuybackPoolConfig.sol";
import {REVBuybackHookConfig} from "@rev-net/core/src/structs/REVBuybackHookConfig.sol";
import {JB721TierConfig} from "@bananapus/721-hook/src/structs/JB721TierConfig.sol";
import {BPTokenMapping} from "@bananapus/suckers/src/structs/BPTokenMapping.sol";
import {BPSuckerDeployerConfig} from "@bananapus/suckers/src/structs/BPSuckerDeployerConfig.sol";
import {REVSuckerDeploymentConfig} from "@rev-net/core/src/structs/REVSuckerDeploymentConfig.sol";
import {JBPayHookSpecification} from "@bananapus/core/src/structs/JBPayHookSpecification.sol";
import {JB721InitTiersConfig} from "@bananapus/721-hook/src/structs/JB721InitTiersConfig.sol";
import {JB721TiersHookFlags} from "@bananapus/721-hook/src/structs/JB721TiersHookFlags.sol";
import {REVDescription} from "@rev-net/core/src/structs/REVDescription.sol";
import {IJBPrices} from "@bananapus/core/src/interfaces/IJBPrices.sol";
import {IJBBuybackHook} from "@bananapus/buyback-hook/src/interfaces/IJBBuybackHook.sol";
import {REVDeploy721TiersHookConfig} from "@rev-net/core/src/structs/REVDeploy721TiersHookConfig.sol";
import {JBDeploy721TiersHookConfig} from "@bananapus/721-hook/src/structs/JBDeploy721TiersHookConfig.sol";
import {IJB721TokenUriResolver} from "@bananapus/721-hook/src/interfaces/IJB721TokenUriResolver.sol";

import {Sphinx} from "@sphinx-labs/contracts/SphinxPlugin.sol";
import {Script} from "forge-std/Script.sol";

import {Banny721TokenUriResolver} from "./../src/Banny721TokenUriResolver.sol";

struct BannyverseRevnetConfig {
    REVConfig configuration;
    JBTerminalConfig[] terminalConfigurations;
    REVBuybackHookConfig buybackHookConfiguration;
    REVSuckerDeploymentConfig suckerDeploymentConfiguration;
    REVDeploy721TiersHookConfig hookConfiguration;
    JBPayHookSpecification[] otherPayHooksSpecifications;
    uint16 extraHookMetadata;
    REVCroptopAllowedPost[] allowedPosts;
}

contract DeployScript is Script, Sphinx {
    /// @notice tracks the deployment of the core contracts for the chain we are deploying to.
    CoreDeployment core;
    /// @notice tracks the deployment of the sucker contracts for the chain we are deploying to.
    SuckerDeployment suckers;
    /// @notice tracks the deployment of the croptop contracts for the chain we are deploying to.
    CroptopDeployment croptop;
    /// @notice tracks the deployment of the revnet contracts for the chain we are deploying to.
    RevnetCoreDeployment revnet;
    /// @notice tracks the deployment of the 721 hook contracts for the chain we are deploying to.
    Hook721Deployment hook;
    /// @notice tracks the deployment of the buyback hook.
    BuybackDeployment buybackHook;

    BannyverseRevnetConfig bannyverseConfig;

    uint256 PREMINT_CHAIN_ID = 1;
    bytes32 SALT = "BANNY_VERSE";
    bytes32 SUCKER_SALT = "BANNYVERSE_SUCKER";
    bytes32 RESOLVER_SALT = "Banny721TokenUriResolver";

    address OPERATOR;
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
        // Get the deployment addresses for the nana CORE for this chain.
        // We want to do this outside of the `sphinx` modifier.
        core = CoreDeploymentLib.getDeployment(
            vm.envOr("NANA_CORE_DEPLOYMENT_PATH", string("node_modules/@bananapus/core/deployments/"))
        );
        // Get the deployment addresses for the suckers contracts for this chain.
        suckers = SuckerDeploymentLib.getDeployment(
            vm.envOr("NANA_SUCKERS_DEPLOYMENT_PATH", string("node_modules/@bananapus/suckers/deployments/"))
        );
        // Get the deployment addresses for the 721 hook contracts for this chain.
        croptop = CroptopDeploymentLib.getDeployment(
            vm.envOr("CROPTOP_CORE_DEPLOYMENT_PATH", string("node_modules/@croptop/core/deployments/"))
        );
        // Get the deployment addresses for the 721 hook contracts for this chain.
        revnet = RevnetCoreDeploymentLib.getDeployment(
            vm.envOr("REVNET_CORE_DEPLOYMENT_PATH", string("node_modules/@rev-net/core/deployments/"))
        );
        // Get the deployment addresses for the 721 hook contracts for this chain.
        hook = Hook721DeploymentLib.getDeployment(
            vm.envOr("NANA_721_DEPLOYMENT_PATH", string("node_modules/@bananapus/721-hook/deployments/"))
        );
        // Get the deployment addresses for the 721 hook contracts for this chain.
        buybackHook = BuybackDeploymentLib.getDeployment(
            vm.envOr("NANA_BUYBACK_HOOK_DEPLOYMENT_PATH", string("node_modules/@bananapus/buyback-hook/deployments/"))
        );

        // Set the operator to be this safe.
        OPERATOR = safeAddress();

        bannyverseConfig = getBannyverseRevnetConfig();

        // Perform the deployment transactions.
        deploy();
    }

    function getBannyverseRevnetConfig() internal view returns (BannyverseRevnetConfig memory){
        // Define constants
        string memory name = "Bannyverse";
        string memory symbol = "BANNY";
        string memory projectUri = "";
        string memory baseUri = "ipfs://";
        string memory contractUri = "";
        uint32 nativeCurrency = uint32(uint160(JBConstants.NATIVE_TOKEN));
        uint8 decimals = 18;
        uint256 decimalMultiplier = 10 ** decimals;
        uint24 nakedBannyCategory = 0;
        uint40 oneDay = 86_400;
        uint40 start = uint40(1710875417); // 15 minutes from now

        // The terminals that the project will accept funds through.
        JBTerminalConfig[] memory terminalConfigurations = new JBTerminalConfig[](1);
        address[] memory tokensToAccept = new address[](1);

        // Accept the chain's native currency through the multi terminal.
        tokensToAccept[0] = JBConstants.NATIVE_TOKEN;
        terminalConfigurations[0] =
            JBTerminalConfig({terminal: core.terminal, tokensToAccept: tokensToAccept});

        // The project's revnet stage configurations.
        REVStageConfig[] memory stageConfigurations = new REVStageConfig[](2);
        stageConfigurations[0] = REVStageConfig({
            startsAtOrAfter: start,
            splitRate: uint16(JBConstants.MAX_RESERVED_RATE / 2),
            initialIssuanceRate: uint112(1_000_000 * decimalMultiplier),
            priceCeilingIncreaseFrequency: oneDay,
            priceCeilingIncreasePercentage: uint32(JBConstants.MAX_DECAY_RATE / 20), // 5%
            priceFloorTaxIntensity: uint16(JBConstants.MAX_REDEMPTION_RATE / 5) // 0.2
        });
        stageConfigurations[1] = REVStageConfig({
            startsAtOrAfter: start + 86_400 * 28,
            splitRate: uint16(JBConstants.MAX_RESERVED_RATE / 2),
            initialIssuanceRate: uint112(100_000 * decimalMultiplier),
            priceCeilingIncreaseFrequency: 7 * oneDay,
            priceCeilingIncreasePercentage: uint16(JBConstants.MAX_DECAY_RATE / 100), // 1%
            priceFloorTaxIntensity: uint16(JBConstants.MAX_REDEMPTION_RATE / 2) // 0.5
        });

        // The project's revnet configuration
        REVConfig memory revnetConfiguration = REVConfig({
            description: REVDescription(name, symbol, projectUri, SALT),
            baseCurrency: nativeCurrency,
            premintTokenAmount: 80_000_000 * decimalMultiplier,
            premintChainId: PREMINT_CHAIN_ID,
            initialSplitOperator: OPERATOR,
            stageConfigurations: stageConfigurations
        });

        // The project's buyback hook configuration.
        REVBuybackPoolConfig[] memory buybackPoolConfigurations = new REVBuybackPoolConfig[](1);
        buybackPoolConfigurations[0] = REVBuybackPoolConfig({
            token: JBConstants.NATIVE_TOKEN,
            fee: 10_000,
            twapWindow: 2 days,
            twapSlippageTolerance: 9000
        });
        REVBuybackHookConfig memory buybackHookConfiguration = REVBuybackHookConfig({
            hook: buybackHook.hook,
            poolConfigurations: buybackPoolConfigurations
        });

        // The project's NFT tiers.
        JB721TierConfig[] memory tiers = new JB721TierConfig[](4);

        tiers[0] = JB721TierConfig({
            price: uint104(1 * (10 ** decimals)),
            initialSupply: 100,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: nakedBannyCategory,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[1] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 1))),
            initialSupply: 1000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: nakedBannyCategory,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[2] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 2))),
            initialSupply: 10_000,
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: nakedBannyCategory,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });
        tiers[3] = JB721TierConfig({
            price: uint104(1 * (10 ** (decimals - 4))),
            initialSupply: 999_999_999, // MAX
            votingUnits: 0,
            reserveFrequency: 0,
            reserveBeneficiary: address(0),
            encodedIPFSUri: bytes32(""),
            category: nakedBannyCategory,
            allowOwnerMint: false,
            useReserveBeneficiaryAsDefault: false,
            transfersPausable: false,
            useVotingUnits: false,
            cannotBeRemoved: true
        });

        // The project's allowed croptop posts.
        REVCroptopAllowedPost[] memory allowedPosts = new REVCroptopAllowedPost[](4);
        allowedPosts[0] = REVCroptopAllowedPost({
            category: 100,
            minimumPrice: 10 ** (decimals - 3),
            minimumTotalSupply: 10_000,
            maximumTotalSupply: 999_999_999,
            allowedAddresses: new address[](0)
        });
        allowedPosts[1] = REVCroptopAllowedPost({
            category: 101,
            minimumPrice: 10 ** (decimals - 1),
            minimumTotalSupply: 100,
            maximumTotalSupply: 999_999_999,
            allowedAddresses: new address[](0)
        });
        allowedPosts[2] = REVCroptopAllowedPost({
            category: 102,
            minimumPrice: 10 ** decimals,
            minimumTotalSupply: 10,
            maximumTotalSupply: 999_999_999,
            allowedAddresses: new address[](0)
        });
        allowedPosts[3] = REVCroptopAllowedPost({
            category: 103,
            minimumPrice: 10 ** (decimals + 2),
            minimumTotalSupply: 10,
            maximumTotalSupply: 999_999_999,
            allowedAddresses: new address[](0)
        });

        // Organize the instructions for how this project will connect to other chains.
        BPTokenMapping[] memory tokenMappings = new BPTokenMapping[](1);
        tokenMappings[0] = BPTokenMapping({
            localToken: JBConstants.NATIVE_TOKEN,
            remoteToken: JBConstants.NATIVE_TOKEN,
            minGas: 200_000,
            minBridgeAmount: 0.01 ether
        });

        // Specify the optimism sucker.
        if(address(suckers.optimismDeployer) == address(0))
            revert("Optimism sucker deployer is not configured on this network.");

        BPSuckerDeployerConfig[] memory suckerDeployerConfigurations = new BPSuckerDeployerConfig[](1);
        suckerDeployerConfigurations[0] = BPSuckerDeployerConfig({
            deployer: IBPSuckerDeployer(suckers.optimismDeployer),
            mappings: tokenMappings
        });

        // Specify all sucker deployments.
        REVSuckerDeploymentConfig memory suckerDeploymentConfiguration =
            REVSuckerDeploymentConfig({deployerConfigurations: suckerDeployerConfigurations, salt: SUCKER_SALT});

        return BannyverseRevnetConfig({
            configuration: revnetConfiguration,
            terminalConfigurations: terminalConfigurations,
            buybackHookConfiguration: buybackHookConfiguration,
            suckerDeploymentConfiguration: suckerDeploymentConfiguration,
            hookConfiguration: REVDeploy721TiersHookConfig({
                baseline721HookConfiguration: JBDeploy721TiersHookConfig({
                    name: name,
                    symbol: symbol,
                    rulesets: core.rulesets,
                    baseUri: baseUri,
                    tokenUriResolver: IJB721TokenUriResolver(address(0)), // This will be replaced once we know the address.
                    contractUri: contractUri,
                    tiersConfig: JB721InitTiersConfig({
                        tiers: tiers,
                        currency: nativeCurrency,
                        decimals: decimals,
                        prices: IJBPrices(address(0))
                    }),
                    reserveBeneficiary: address(0),
                    flags: JB721TiersHookFlags({
                        noNewTiersWithReserves: false,
                        noNewTiersWithVotes: false,
                        noNewTiersWithOwnerMinting: false,
                        preventOverspending: false
                    })
                }),
                operatorCanAdjustTiers: true,
                operatorCanUpdateMetadata: true,
                operatorCanMint: true
            }),
            otherPayHooksSpecifications: new JBPayHookSpecification[](0),
            extraHookMetadata: 0,
            allowedPosts: allowedPosts
        });
    }

    function deploy() public sphinx {
        // Deploy the Banny URI Resolver.
        Banny721TokenUriResolver resolver;
        {
            // Perform the check for the resolver..
            (address _resolver, bool _resolverIsDeployed) =
                _isDeployed(RESOLVER_SALT, type(Banny721TokenUriResolver).creationCode, abi.encode(OPERATOR, TRUSTED_FORWARDER));
            // Deploy it if it has not been deployed yet.
            resolver = !_resolverIsDeployed
                ? new Banny721TokenUriResolver{salt: RESOLVER_SALT}(OPERATOR, TRUSTED_FORWARDER)
                : Banny721TokenUriResolver(_resolver);
        }

        // Update our config with its address.
        bannyverseConfig.hookConfiguration.baseline721HookConfiguration.tokenUriResolver = resolver;

        // Mint a new project.
        uint256 _projectId = core.projects.createFor(safeAddress());

        // The permissions required to configure a revnet.
        uint256[] memory _permissions = new uint256[](6);
        _permissions[0] = JBPermissionIds.QUEUE_RULESETS;
        _permissions[1] = JBPermissionIds.DEPLOY_ERC20;
        _permissions[2] = JBPermissionIds.SET_BUYBACK_POOL;
        _permissions[3] = JBPermissionIds.SET_SPLIT_GROUPS; 
        _permissions[4] = JBPermissionIds.MAP_SUCKER_TOKEN; 
        _permissions[5] = JBPermissionIds.DEPLOY_SUCKERS; 

        // Give the permissions to the croptop deployer.
        core.permissions.setPermissionsFor(safeAddress(), JBPermissionsData({
            operator: address(revnet.croptop_deployer),
            projectId: _projectId,
            permissionIds: _permissions
        }));

        // Give the permissions to the sucker registry.
        // TODO: Check if this is actually needed. And if it is, why is it needed?
        uint256[] memory _registryPermissions = new uint256[](1);
        _registryPermissions[0] = JBPermissionIds.MAP_SUCKER_TOKEN; 
        core.permissions.setPermissionsFor(safeAddress(), JBPermissionsData({
            operator: address(suckers.registry),
            projectId: _projectId,
            permissionIds: _registryPermissions
        }));

        // Deploy the $BANNY Revnet.
        revnet.croptop_deployer.launchCroptopRevnetFor({
            revnetId: _projectId,
            configuration: bannyverseConfig.configuration,
            terminalConfigurations: bannyverseConfig.terminalConfigurations,
            buybackHookConfiguration: bannyverseConfig.buybackHookConfiguration,
            suckerDeploymentConfiguration: bannyverseConfig.suckerDeploymentConfiguration,
            hookConfiguration: bannyverseConfig.hookConfiguration,
            otherPayHooksSpecifications: bannyverseConfig.otherPayHooksSpecifications,
            extraHookMetadata: bannyverseConfig.extraHookMetadata,
            allowedPosts: bannyverseConfig.allowedPosts
        });

        // Tranfer ownership.
        core.projects.transferFrom(safeAddress(), address(revnet.croptop_deployer), _projectId);
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
