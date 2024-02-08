// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "lib/revnet-contracts/src/REVCroptopDeployer.sol";

import {JBPayHookSpecification, IJBPayHook} from "lib/juice-contracts-v4/src/structs/JBPayHookSpecification.sol";
import {JBPermissionIds} from "lib/juice-contracts-v4/src/libraries/JBPermissionIds.sol";

contract REVCroptopSuckerDeployer is REVCroptopDeployer {
    address immutable SUCKER_DEPLOYER;

    constructor(
        IJBController controller,
        IJB721TiersHookDeployer hookDeployer,
        CroptopPublisher publisher,
        address suckerDeployer
    ) REVCroptopDeployer(controller, hookDeployer, publisher) {
        SUCKER_DEPLOYER = suckerDeployer;
    }

    function deployCroptopSuckerRevnetFor(
        string memory name,
        string memory symbol,
        string memory projectUri,
        REVConfig memory configuration,
        JBTerminalConfig[] memory terminalConfigurations,
        REVBuybackHookConfig memory buybackHookConfiguration,
        REVDeploy721TiersHookConfig memory hookConfiguration,
        uint16 extraHookMetadata,
        AllowedPost[] memory allowedPosts,
        SuckerTokenConfig[] calldata suckerTokenConfig,
        bool autoSuck,
        bytes32 suckerSalt
    ) public returns (uint256 revnetId) {
        // 
        revnetId = CONTROLLER.PROJECTS().count() + 1;
        // Create the sucker.
        address _sucker = BPSuckerDeployer(SUCKER_DEPLOYER).createForSender(
            revnetId,
            keccak256(abi.encode(msg.sender, suckerSalt))
        );

        // Add the sucker to the payhooks.
        JBPayHookSpecification[] memory _payHooks;
        if(autoSuck) {
            _payHooks = new JBPayHookSpecification[](1);
            _payHooks[0] = JBPayHookSpecification({
                hook: IJBPayHook(_sucker),
                amount: 0,
                metadata: bytes('')
            });
        }
        
        // Create the project and make sure it receives the ID we expected it to receive.
        assert(
            revnetId == 
            deployCroptopRevnetFor({
                name: name,
                symbol: symbol,
                projectUri: projectUri,
                configuration: configuration,
                terminalConfigurations: terminalConfigurations,
                buybackHookConfiguration: buybackHookConfiguration,
                hookConfiguration: hookConfiguration,
                otherPayHooksSpecifications: _payHooks,
                extraHookMetadata: extraHookMetadata,
                allowedPosts: allowedPosts
            })
        );

        // Configure the tokens.
        for(uint256 _i; _i < suckerTokenConfig.length; _i++) {
            // Configure the sucker.
            BPSucker(_sucker).configureToken(
                suckerTokenConfig[_i].localToken,
                BPTokenConfig({
                    remoteToken: suckerTokenConfig[_i].remoteToken,
                    minGas: suckerTokenConfig[_i].minGas,
                    minBridgeAmount: suckerTokenConfig[_i].minBridgeAmount 
                }));
        }

        // Give the sucker mint permissions, so it can burn and mint.
        uint256[] memory _permissions = new uint256[](1);
        _permissions[0] = JBPermissionIds.MINT_TOKENS;
        IJBPermissioned(address(CONTROLLER)).PERMISSIONS().setPermissionsFor({
            account: address(this),
            permissionsData: JBPermissionsData({
                operator: address(_sucker),
                projectId: revnetId,
                permissionIds: _permissions
            })
        });
    }
}

interface BPSuckerDeployer {
    function createForSender(
        uint256 _localProjectId,
        bytes32 _salt
    ) external returns (address);
}

struct SuckerTokenConfig {
    address localToken;
    address remoteToken;
    uint32 minGas;
    uint256 minBridgeAmount;
}

struct BPTokenConfig {
    uint32 minGas;
    address remoteToken;
    uint256 minBridgeAmount;
}

interface BPSucker {
    function configureToken(address _token, BPTokenConfig calldata _config) external;
}