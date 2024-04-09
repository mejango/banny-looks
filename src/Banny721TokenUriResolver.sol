// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Base64} from "lib/base64/base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {IJB721TokenUriResolver} from "@bananapus/721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {IERC721} from "@bananapus/721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHook} from "@bananapus/721-hook/src/interfaces/IJB721TiersHook.sol";
import {JB721Tier} from "@bananapus/721-hook/src/structs/JB721Tier.sol";
import {JBIpfsDecoder} from "@bananapus/721-hook/src/libraries/JBIpfsDecoder.sol";

/// @notice Banny asset manager. Stores and shows Naked Bannys in worlds with outfits on.
contract Banny721TokenUriResolver is IJB721TokenUriResolver, ERC2771Context, Ownable {
    using Strings for uint256;

    event DecorateBanny(
        address indexed hook, uint256 indexed nakenBannyId, uint256 worldId, uint256[] outfitIds, address caller
    );
    event SetSvgContents(uint256[] indexed tierId, string[] svgContents, address caller);
    event SetSvgHashes(uint256[] indexed tierIds, bytes32[] indexed svgHashs, address caller);
    event SetSvgBaseUri(string baseUri, address caller);
    event SetTierNames(uint256[] indexed tierIds, string[] names, address caller);

    error ASSET_IS_ALREADY_BEING_WORN();
    error HEAD_ALREADY_ADDED();
    error FACE_ALREADY_ADDED();
    error SUIT_ALREADY_ADDED();
    error ONESIE_ALREADY_ADDED();
    error UNRECOGNIZED_WORLD();
    error UNAUTHORIZED__NAKED_BANNY();
    error UNAUTHORIZED_WORLD();
    error UNAUTHORIZED_OUTFIT();
    error UNRECOGNIZED_CATEGORY();
    error UNRECOGNIZED_OUTFIT();
    error UNORDERED_CATEGORIES();
    error CONTENTS_ALREADY_STORED();
    error HASH_NOT_FOUND();
    error CONTENTS_MISMATCH();
    error HASH_ALREADY_STORED();
    error UNRECOGNIZED_TIER();

    /// @notice Just a kind reminder to our readers.
    /// @dev Used in 721 token ID generation.
    uint256 private constant _ONE_BILLION = 1_000_000_000;

    string private constant _NAKED_BANNY =
        '<g class="a1"><path d="M173 53h4v17h-4z"/></g><g class="a2"><path d="M167 57h3v10h-3z"/><path d="M169 53h4v17h-4z"/></g><g class="a3"><path d="M167 53h3v4h-3z"/><path d="M163 57h4v10h-4z"/><path d="M167 67h3v3h-3z"/></g><g class="b1"><path d="M213 253h-3v-3-3h-3v-7-3h-4v-10h-3v-7-7-3h-3v-73h-4v-10h-3v-10h-3v-7h-4v-7h-3v-3h-3v-3h-4v10h4v10h3v10h3v3h4v7 3 70 3h3v7h3v20h4v7h3v3h3v3h4v4h3v3h3v-3-4z"/><path d="M253 307v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-6h-3v-7h-4v17h4v3h3v3h3 4v4h3v3h3v3h4v4h3v3h3v3h4v4h3v3h3v3h4v-6h-4z"/></g><g class="b2"><path d="M250 310v-3h-3v-4h-4v-3h-3v-3h-3v-4h-4v-3h-3v-3h-3v-4h-7v-3h-3v-3h-4v-17h-3v-3h-3v-4h-4v-3h-3v-3h-3v-7h-4v-20h-3v-7h-3v-73-3-7h-4v-3h-3v-10h-3v-10h-4V70h-3v-3l-3 100 3-100v40h-3v10h-4v6h-3v14h-3v3 13h-4v44h4v16h3v14h3v13h4v10h3v7h3v3h4v3h3v4h3v3h4v3h3v4h3v3h4v3h3v7h7v7h6v3h7v3h7v4h13v3h3v3h10v-3h-3zm-103-87v-16h3v-10h-3v6h-4v17h-3v10h3v-7h4z"/><path d="M143 230h4v7h-4zm4 10h3v3h-3zm3 7h3v3h-3zm3 6h4v4h-4z"/><path d="M163 257h-6v3h3v3h3v4h4v-4-3h-4v-3z"/></g><g class="b3"><path d="M143 197v6h4v-6h6v-44h4v-16h3v-14h3v-6h4v-10h3V97h-7v6h-3v4h-3v3h-4v3h-3v4 3h-3v3 4h-4v10h-3v16 4h-3v46h3v-6h3z"/><path d="M140 203h3v17h-3z"/><path d="M137 220h3v10h-3z"/><path d="M153 250h-3v-7h-3v-6h-4v-7h-3v10h3v7h4v6h3v4h3v-7zm-3 10h3v7h-3z"/><path d="M147 257h3v3h-3zm6 0h4v3h-4z"/><path d="M160 263v-3h-3v3 7h6v-7h-3zm-10-56v16h-3v7h3v10h3v7h4v6h6v4h7v-4-3h-3v-10h-4v-13h-3v-14h-3v-16h-4v10h-3z"/><path d="M243 313v-3h-3v-3h-10-3v-4h-7v-3h-7v-3h-6v-7h-7v-7h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v10h-3v3h-4v3h-3v7h3v7h4v6h3v5h4v3h6v3h3v3h4 3v3h3 4v3h3 3v4h10v3h7 7 3v3h10 3v-3h10v-3h4v-4h-14z"/></g><g class="b4"><path d="M183 130h4v7h-4z"/><path d="M180 127h3v3h-3zm-27-4h4v7h-4z"/><path d="M157 117h3v6h-3z"/><path d="M160 110h3v7h-3z"/><path d="M163 107h4v3h-4zm-3 83h3v7h-3z"/><path d="M163 187h4v3h-4zm20 0h7v3h-7z"/><path d="M180 190h3v3h-3zm10-7h3v4h-3z"/><path d="M193 187h4v6h-4zm-20 53h4v7h-4z"/><path d="M177 247h3v6h-3z"/><path d="M180 253h3v7h-3z"/><path d="M183 260h7v3h-7z"/><path d="M190 263h3v4h-3zm0-20h3v4h-3z"/><path d="M187 240h3v3h-3z"/><path d="M190 237h3v3h-3zm13 23h4v3h-4z"/><path d="M207 263h3v7h-3z"/><path d="M210 270h3v3h-3zm-10 7h3v6h-3z"/><path d="M203 283h4v7h-4z"/><path d="M207 290h6v3h-6z"/></g><g class="o"><path d="M133 157h4v50h-4zm0 63h4v10h-4zm27-163h3v10h-3z"/><path d="M163 53h4v4h-4z"/><path d="M167 50h10v3h-10z"/><path d="M177 53h3v17h-3z"/><path d="M173 70h4v27h-4zm-6 0h3v27h-3z"/><path d="M163 67h4v3h-4zm0 30h4v3h-4z"/><path d="M160 100h3v3h-3z"/><path d="M157 103h3v4h-3z"/><path d="M153 107h4v3h-4z"/><path d="M150 110h3v3h-3z"/><path d="M147 113h3v7h-3z"/><path d="M143 120h4v7h-4z"/><path d="M140 127h3v10h-3z"/><path d="M137 137h3v20h-3zm56-10h4v10h-4z"/><path d="M190 117h3v10h-3z"/><path d="M187 110h3v7h-3z"/><path d="M183 103h4v7h-4z"/><path d="M180 100h3v3h-3z"/><path d="M177 97h3v3h-3zm-40 106h3v17h-3zm0 27h3v10h-3zm10 30h3v7h-3z"/><path d="M150 257v-4h-3v-6h-4v-7h-3v10h3v10h4v-3h3z"/><path d="M150 257h3v3h-3z"/><path d="M163 273v-3h-6v-10h-4v7h-3v3h3v3h4v7h3v-7h3z"/><path d="M163 267h4v3h-4z"/><path d="M170 257h-3-4v3h4v7h3v-10z"/><path d="M157 253h6v4h-6z"/><path d="M153 247h4v6h-4z"/><path d="M150 240h3v7h-3z"/><path d="M147 230h3v10h-3zm13 50h3v7h-3z"/><path d="M143 223h4v7h-4z"/><path d="M147 207h3v16h-3z"/><path d="M150 197h3v10h-3zm-10 0h3v6h-3zm50 113h7v3h-7zm23 10h17v3h-17z"/><path d="M230 323h13v4h-13z"/><path d="M243 320h10v3h-10z"/><path d="M253 317h4v3h-4z"/><path d="M257 307h3v10h-3z"/><path d="M253 303h4v4h-4z"/><path d="M250 300h3v3h-3z"/><path d="M247 297h3v3h-3z"/><path d="M243 293h4v4h-4z"/><path d="M240 290h3v3h-3z"/><path d="M237 287h3v3h-3z"/><path d="M233 283h4v4h-4z"/><path d="M230 280h3v3h-3z"/><path d="M227 277h3v3h-3z"/><path d="M223 273h4v4h-4z"/><path d="M220 267h3v6h-3z"/><path d="M217 260h3v7h-3z"/><path d="M213 253h4v7h-4z"/><path d="M210 247h3v6h-3z"/><path d="M207 237h3v10h-3z"/><path d="M203 227h4v10h-4zm-40 60h4v6h-4zm24 20h3v3h-3z"/><path d="M167 293h3v5h-3zm16 14h4v3h-4z"/><path d="M170 298h4v3h-4zm10 6h3v3h-3z"/><path d="M174 301h6v3h-6zm23 12h6v4h-6z"/><path d="M203 317h10v3h-10zm-2-107v-73h-4v73h3v17h3v-17h-2z"/></g><g class="o"><path d="M187 307v-4h3v-6h-3v-4h-4v-3h-3v-3h-7v-4h-6v4h-4v3h4v27h-4v13h-3v10h-4v7h4v3h3 10 14v-3h-4v-4h-3v-3h-3v-3h-4v-7h4v-10h3v-7h3v-3h7v-3h-3zm16 10v-4h-6v17h-4v10h-3v7h3v3h4 6 4 3 14v-3h-4v-4h-7v-3h-3v-3h-3v-10h3v-7h3v-3h-10z"/></g>';
    string private constant _DEFAULT_NECKLACE =
        '<g class="o"><path d="M190 173h-37v-3h-10v-4h-6v4h3v3h-3v4h6v3h10v4h37v-4h3v-3h-3v-4zm-40 4h-3v-4h3v4zm7 3v-3h3v3h-3zm6 0v-3h4v3h-4zm7 0v-3h3v3h-3zm7 0v-3h3v3h-3zm10 0h-4v-3h4v3z"/><path d="M190 170h3v3h-3z"/><path d="M193 166h4v4h-4zm0 7h4v4h-4z"/></g><g class="w"><path d="M137 170h3v3h-3zm10 3h3v4h-3zm10 4h3v3h-3zm6 0h4v3h-4zm7 0h3v3h-3zm7 0h3v3h-3zm6 0h4v3h-4zm7-4h3v4h-3z"/><path d="M193 170h4v3h-4z"/></g>';
    string private constant _DEFAULT_MOUTH =
        '<g class="o"><path d="M183 160v-4h-20v4h-3v3h3v4h24v-7h-4zm-13 3v-3h10v3h-10z" fill="#ad71c8"/><path d="M170 160h10v3h-10z"/></g>';
    string private constant _DEFAULT_STANDARD_EYES =
        '<g class="o"><path d="M177 140v3h6v11h10v-11h4v-3h-20z"/><path d="M153 140v3h7v8 3h7 3v-11h3v-3h-20z"/></g><g class="w"><path d="M153 143h7v4h-7z"/><path d="M157 147h3v3h-3zm20-4h6v4h-6z"/><path d="M180 147h3v3h-3z"/></g>';
    string private constant _DEFAULT_ALIEN_EYES =
        '<g class="o"><path d="M190 127h3v3h-3zm3 13h4v3h-4zm-42 0h6v6h-6z"/><path d="M151 133h3v7h-3zm10 0h6v4h-6z"/><path d="M157 137h17v6h-17zm3 13h14v3h-14zm17-13h7v16h-7z"/><path d="M184 137h6v6h-6zm0 10h10v6h-10z"/><path d="M187 143h10v4h-10z"/><path d="M190 140h3v3h-3zm-6-10h3v7h-3z"/><path d="M187 130h6v3h-6zm-36 0h10v3h-10zm16 13h7v7h-7zm-10 0h7v7h-7z"/><path d="M164 147h3v3h-3zm29-20h4v6h-4z"/><path d="M194 133h3v7h-3z"/></g><g class="w"><path d="M154 133h7v4h-7z"/><path d="M154 137h3v3h-3zm10 6h3v4h-3zm20 0h3v4h-3zm3-10h7v4h-7z"/><path d="M190 137h4v3h-4z"/></g>';

    uint8 private constant _NAKED_CATEGORY = 0;
    uint8 private constant _WORLD_CATEGORY = 1;
    uint8 private constant _BACKSIDE_CATEGORY = 2;
    uint8 private constant _NECKLACE_CATEGORY = 3;
    uint8 private constant _HEAD_CATEGORY = 4;
    uint8 private constant _FACE_CATEGORY = 5;
    uint8 private constant _FACE_EYES_CATEGORY = 6;
    uint8 private constant _FACE_MOUTH_CATEGORY = 7;
    uint8 private constant _HEADGEAR_CATEGORY = 8;
    uint8 private constant _ONESIE_CATEGORY = 9;
    uint8 private constant _SHOE_CATEGORY = 10;
    uint8 private constant _SUIT_CATEGORY = 11;
    uint8 private constant _SUIT_BOTTOM_CATEGORY = 12;
    uint8 private constant _SUIT_TOP_CATEGORY = 13;
    uint8 private constant _FIST_CATEGORY = 14;
    uint8 private constant _TOPPING_CATEGORY = 15;

    uint8 private constant ALIEN_TIER = 1;
    uint8 private constant PINK_TIER = 2;
    uint8 private constant ORANGE_TIER = 3;
    uint8 private constant ORIGINAL_TIER = 4;

    /// @notice The Naked Banny and outfit SVG hash files.
    /// @custom:param tierId The ID of the tier that the SVG hash represent.
    mapping(uint256 tierId => bytes32) public svgHashOf;

    /// @notice The base of the domain hosting the SVG files that can be lazily uploaded to the contract.
    string public svgBaseUri;

    /// @notice The name of each tier.
    /// @custom:param tierId The ID of the tier that the name belongs to.
    mapping(uint256 tierId => string) private _tierNameOf;

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    mapping(uint256 tierId => string) private _svgContentOf;

    /// @notice The outfits currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with outfits currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the outfits.
    mapping(uint256 nakedBannyId => uint256[]) internal _attachedOutfitIdsOf;

    /// @notice The world currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with a world currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the world.
    mapping(uint256 nakedBannyId => uint256) internal _attachedWorldIdOf;

    /// @notice The ID of the naked banny each world is being used by.
    /// @custom:param worldId The ID of the world.
    mapping(uint256 worldId => uint256) internal _worldIsBeingUsedBy;

    /// @notice The ID of the naked banny each outfit is being worn by.
    /// @custom:param outfitId The ID of the outfit.
    mapping(uint256 outfitId => uint256) internal _outfitIsBeingWornBy;

    /// @notice The assets currently attached to each Naked Banny, owned by the naked Banny's owner.
    /// @param nakedBannyId The ID of the naked banny shows with the associated assets.
    /// @return worldId The world attached to the Naked Banny.
    /// @return outfitIds The outfits attached to the Naked Banny.
    function assetIdsOf(uint256 nakedBannyId) public view returns (uint256 worldId, uint256[] memory outfitIds) {
        // Keep a reference to the outfit IDs currently attached to the Naked Banny.
        uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[nakedBannyId];

        // Add the world.
        worldId = _attachedWorldIdOf[nakedBannyId];

        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfAttachedOutfits = attachedOutfitIds.length;

        // Keep a reference to the attached outfit ID being iterated on.
        uint256 attachedOutfitId;

        // Keep a reference to a counter of the number of outfits being returned.
        uint256 counter;

        // Return the outfits attached.
        for (uint256 i; i < numberOfAttachedOutfits; i++) {
            // Set the outfit being iterated on.
            attachedOutfitId = attachedOutfitIds[i];

            // Return the outfit.
            outfitIds[counter++] = attachedOutfitId;
        }
    }

    /// @notice Checks to see which naked banny is currently using a particular world.
    /// @param worldId The ID of the world being used.
    /// @return The ID of the naked banny using the world.
    function worldIsBeingUsedBy(uint256 worldId) public view returns (uint256) {
        // Get a reference to the naked banny using the world.
        uint256 nakedBannyId = _worldIsBeingUsedBy[worldId];

        // If no naked banny is wearing the outfit, or if its no longer the world attached, return 0.
        if (nakedBannyId == 0 || _attachedWorldIdOf[nakedBannyId] != worldId) return 0;

        // Return the naked banny ID.
        return nakedBannyId;
    }

    /// @notice Checks to see which naked banny is currently wearing a particular outfit.
    /// @param outfitId The ID of the outfit being worn.
    /// @return The ID of the naked banny wearing the outfit.
    function outfitIsBeingWornBy(uint256 outfitId) public view returns (uint256) {
        // Get a reference to the naked banny wearing the outfit.
        uint256 nakedBannyId = _outfitIsBeingWornBy[outfitId];

        // If no naked banny is wearing the outfit, return 0.
        if (nakedBannyId == 0) return 0;

        // Keep a reference to the outfit IDs currently attached to a naked banny.
        uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[nakedBannyId];

        // Keep a reference to the number of outfit IDs currently attached.
        uint256 numberOfAttachedOutfitIds = attachedOutfitIds.length;
        for (uint256 i; i < numberOfAttachedOutfitIds; i++) {
            // If the outfit is still attached, return the naked banny ID.
            if (attachedOutfitIds[i] == outfitId) return nakedBannyId;
        }

        // If the outfit is no longer attached, return 0.
        return 0;
    }

    /// @notice Returns the SVG showing a dressed Naked Banny in a world.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfits in its current world.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address hook, uint256 tokenId) external view returns (string memory) {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory tier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        // If the token's tier doesn't exist, return an empty uri.
        if (tier.id == 0) return "";

        string memory contents;

        // If this isn't a Naked Banny, return the asset SVG alone (or on a manakin banny).
        if (tier.category > _NAKED_CATEGORY) {
            // Keep a reference to the SVG contents.
            contents = _svgOf(hook, tier.id);

            // Layer the outfit SVG over the mannequin Banny
            // Start with the mannequin SVG if we're not returning a world.
            if (bytes(contents).length != 0) {
                if (tier.category != _WORLD_CATEGORY) {
                    contents = string.concat(_mannequinBannySvg(), contents);
                }
                contents = _layeredSvg(contents);
            }
        } else {
            // Compose the contents.
            contents = bannySvgOf({hook: hook, tokenId: tokenId, shouldBeDressed: true, shouldIncludeWorld: true});
        }

        if (bytes(contents).length == 0) {
            // If the tier's category is greater than the last expected category, use the default base URI of the 721
            // contract. Otherwise use the SVG URI.
            string memory baseUri = tier.category > _TOPPING_CATEGORY ? IJB721TiersHook(hook).baseURI() : svgBaseUri;

            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(baseUri, IJB721TiersHook(hook).STORE().encodedTierIPFSUriOf(hook, tokenId));
        }

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                abi.encodePacked(
                    '{"name":"',
                    _nameOf(tokenId, tier.id, tier.category),
                    '", "id": "',
                    tier.id.toString(),
                    '","description":"A piece of the Bannyverse","image":"data:image/svg+xml;base64,',
                    Base64.encode(abi.encodePacked(contents)),
                    '"}'
                )
            )
        );
    }

    /// @notice Returns the SVG showing a dressed Naked Banny.
    /// @param hook The hook storing the assets.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfits in its current world.
    /// @return bannySvg The SVG.
    function bannySvgOf(
        address hook,
        uint256 tokenId,
        bool shouldBeDressed,
        bool shouldIncludeWorld
    )
        public
        view
        returns (string memory)
    {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory tier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        // If the token's tier doesn't exist, return an empty uri.
        if (tier.id == 0) return "";

        // Compose the contents.
        string memory contents;

        // If this isn't a Naked Banny and there's an SVG available, return the asset SVG alone (or on a manakin banny).
        if (tier.category > _NAKED_CATEGORY) {
            // Keep a reference to the SVG contents.
            contents = _svgOf(hook, tier.id);

            if (bytes(contents).length == 0) return "";

            // Return the SVG.
            return _layeredSvg(contents);
        }

        uint256 worldId;
        uint256[] memory outfitIds;

        // Get a reference to each asset ID currently attached to the Naked Banny.
        try this.assetIdsOf(tokenId) returns (uint256 _worldId, uint256[] memory _outfitIds) {
            worldId = _worldId;
            outfitIds = _outfitIds;
        } catch (bytes memory) {}

        // Add the world if needed.
        if (worldId != 0 && shouldIncludeWorld) contents = string.concat(contents, _svgOf(hook, worldId));

        // Start with the Naked Banny.
        contents = string.concat(contents, _nakedBannySvgOf(tier.id));

        if (shouldBeDressed) {
            // Get the outfit contents.
            string memory outfitContents =
                _outfitContentsFor({hook: hook, nakedBannyTier: tier.id, outfitIds: outfitIds});

            // Add the outfit contents if there are any.
            if (bytes(outfitContents).length != 0) {
                contents = string.concat(contents, outfitContents);
            }
        }

        // Return the SVG contents.
        return _layeredSvg(contents);
    }

    /// @notice Returns the name of the token.
    /// @param hook The hook storing the assets.
    /// @param tokenId The ID of the token to show.
    /// @return The name of the token.
    function nameOf(address hook, uint256 tokenId) public view returns (string memory) {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory tier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        return _nameOf(tokenId, tier.id, tier.category);
    }

    /// @param owner The owner allowed to add SVG files that correspond to tier IDs.
    /// @param trustedForwarder The trusted forwarder for the ERC2771Context.
    constructor(address owner, address trustedForwarder) Ownable(owner) ERC2771Context(trustedForwarder) {}

    /// @notice Dress your Naked Banny with outfits.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param hook The hook storing the assets.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param worldId The ID of the world that'll be associated with the specified banny.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny. Only one outfit per
    /// outfit category allowed at a time
    /// and they must be passed in order.
    function decorateBannyWith(
        address hook,
        uint256 nakedBannyId,
        uint256 worldId,
        uint256[] calldata outfitIds
    )
        external
    {
        // Make sure call is being made by owner of Naked Banny.
        if (IERC721(hook).ownerOf(nakedBannyId) != _msgSender()) revert UNAUTHORIZED__NAKED_BANNY();

        // Add the world if needed.
        if (worldId != 0) {
            // Check if the owner matched.
            if (IERC721(hook).ownerOf(worldId) != _msgSender()) revert UNAUTHORIZED_WORLD();

            // Make sure the world is not already being shown on another Naked banny.
            if (worldIsBeingUsedBy(worldId) != 0) revert ASSET_IS_ALREADY_BEING_WORN();

            // Get the world's tier.
            JB721Tier memory worldTier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, worldId, false);

            // Tier must exist
            if (worldTier.id == 0) revert UNRECOGNIZED_WORLD();

            // Store the world for the banny.
            _attachedWorldIdOf[nakedBannyId] = worldId;

            // Store the banny that's in the world.
            _worldIsBeingUsedBy[worldId] = nakedBannyId;
        } else {
            _attachedWorldIdOf[nakedBannyId] = 0;
        }

        // Keep a reference to the number of outfits being worn.
        uint256 numberOfAssets = outfitIds.length;

        // Keep a reference to the outfit being iterated on.
        uint256 outfitId;

        // Keep a reference to the category of the last outfit iterated on.
        uint256 lastAssetCategory;

        // Keep a reference to the tier of the outfit being iterated on.
        JB721Tier memory outfitTier;

        bool hasHead;
        bool hasFace;
        bool hasOnesie;
        bool hasSuit;

        // Iterate through each outfit checking to see if the message sender owns them all.
        for (uint256 i; i < numberOfAssets; i++) {
            // Set the outfit ID being iterated on.
            outfitId = outfitIds[i];

            // Check if the owner matched.
            if (IERC721(hook).ownerOf(outfitId) != _msgSender()) revert UNAUTHORIZED_OUTFIT();

            // Make sure the outfit is not already being worn.
            if (outfitIsBeingWornBy(outfitId) != 0) revert ASSET_IS_ALREADY_BEING_WORN();

            // Get the outfit's tier.
            outfitTier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, outfitId, false);

            // Tier must exist
            if (outfitTier.id == 0) revert UNRECOGNIZED_OUTFIT();

            // The tier's category must be a known category.
            if (outfitTier.category < _BACKSIDE_CATEGORY || outfitTier.category > _TOPPING_CATEGORY) {
                revert UNRECOGNIZED_CATEGORY();
            }

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitTier.category <= lastAssetCategory) revert UNORDERED_CATEGORIES();

            if (outfitTier.category == _HEAD_CATEGORY) {
                hasHead = true;
            } else if (outfitTier.category == _FACE_CATEGORY) {
                hasFace = true;
            } else if (outfitTier.category == _SUIT_CATEGORY) {
                hasSuit = true;
            } else if (outfitTier.category == _ONESIE_CATEGORY) {
                hasOnesie = true;
            } else if (
                (
                    outfitTier.category == _SUIT_CATEGORY || outfitTier.category == _SUIT_TOP_CATEGORY
                        || outfitTier.category == _SUIT_BOTTOM_CATEGORY || outfitTier.category == _SHOE_CATEGORY
                ) && hasOnesie
            ) {
                revert ONESIE_ALREADY_ADDED();
            } else if (
                (
                    outfitTier.category == _FACE_CATEGORY || outfitTier.category == _FACE_EYES_CATEGORY
                        || outfitTier.category == _FACE_MOUTH_CATEGORY || outfitTier.category == _HEADGEAR_CATEGORY
                ) && hasHead
            ) {
                revert HEAD_ALREADY_ADDED();
            } else if (
                (outfitTier.category == _FACE_EYES_CATEGORY || outfitTier.category == _FACE_MOUTH_CATEGORY) && hasFace
            ) {
                revert FACE_ALREADY_ADDED();
            } else if (
                (outfitTier.category == _SUIT_TOP_CATEGORY || outfitTier.category == _SUIT_BOTTOM_CATEGORY) && hasSuit
            ) {
                revert SUIT_ALREADY_ADDED();
            }

            // Keep a reference to the last outfit's category.
            lastAssetCategory = outfitTier.category;

            // Store the banny that's in the world.
            _outfitIsBeingWornBy[outfitId] = nakedBannyId;
        }

        // Store the outfits.
        _attachedOutfitIdsOf[nakedBannyId] = outfitIds;

        emit DecorateBanny(hook, nakedBannyId, worldId, outfitIds, _msgSender());
    }

    /// @notice The owner of this contract can store SVG files for tier IDs.
    /// @param tierIds The IDs of the tiers having SVGs stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element.
    function setSvgContentsOf(uint256[] memory tierIds, string[] calldata svgContents) external {
        uint256 numberOfTiers = tierIds.length;

        uint256 tierId;
        string memory svgContent;

        for (uint256 i; i < numberOfTiers; i++) {
            tierId = tierIds[i];
            svgContent = svgContents[i];

            // Make sure there isn't already contents for the specified tierId;
            if (bytes(_svgContentOf[tierId]).length != 0) revert CONTENTS_ALREADY_STORED();

            // Get the stored svg hash for the tier.
            bytes32 svgHash = svgHashOf[tierId];

            // Make sure a hash exists.
            if (svgHash == bytes32(0)) revert HASH_NOT_FOUND();

            // Make sure the content matches the hash.
            if (keccak256(abi.encodePacked(svgContent)) != svgHash) revert CONTENTS_MISMATCH();

            // Store the svg contents.
            _svgContentOf[tierId] = svgContent;
        }

        emit SetSvgContents(tierIds, svgContents, msg.sender);
    }

    /// @notice Allows the owner of this contract to upload the hash of an svg file for a tierId.
    /// @dev This allows anyone to lazily upload the correct svg file.
    /// @param tierIds The IDs of the tiers having SVG hashes stored.
    /// @param svgHashs The svg hashes being stored, not including the parent <svg></svg> element.
    function setSvgHashsOf(uint256[] memory tierIds, bytes32[] memory svgHashs) external onlyOwner {
        uint256 numberOfTiers = tierIds.length;

        uint256 tierId;
        bytes32 svgHash;

        for (uint256 i; i < numberOfTiers; i++) {
            tierId = tierIds[i];
            svgHash = svgHashs[i];

            // Make sure there isn't already contents for the specified tierId;
            if (svgHashOf[tierId] != bytes32(0)) revert HASH_ALREADY_STORED();

            // Store the svg contents.
            svgHashOf[tierId] = svgHash;
        }
        emit SetSvgHashes(tierIds, svgHashs, msg.sender);
    }

    /// @notice Allows the owner to set the tier's name.
    /// @param tierIds The IDs of the tiers having their name stored.
    /// @param names The names of the tiers.
    function setTierNames(uint256[] memory tierIds, string[] memory names) external onlyOwner {
        uint256 numberOfTiers = tierIds.length;

        uint256 tierId;
        string memory name;

        for (uint256 i; i < numberOfTiers; i++) {
            tierId = tierIds[i];
            name = names[i];

            _tierNameOf[tierId] = name;
        }
        emit SetTierNames(tierIds, names, msg.sender);
    }

    /// @notice Allows the owner of this contract to specify the base of the domain hosting the SVG files.
    function setSvgBaseUri(string calldata baseUri) external onlyOwner {
        // Store the base URI.
        svgBaseUri = baseUri;

        emit SetSvgBaseUri(baseUri, msg.sender);
    }

    /// @notice Returns the standard dimension SVG containing dynamic contents and SVG metadata.
    /// @param contents The contents of the SVG
    function _layeredSvg(string memory contents) internal pure returns (string memory) {
        return string.concat(
            '<svg width="400" height="400" viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg"><style>.o{fill:#050505;}.w{fill:#f9f9f9;}</style>',
            contents,
            "</svg>"
        );
    }

    function _mannequinBannySvg() internal pure returns (string memory) {
        return string.concat(
            "<style>.o{fill:#808080;}.b2{fill:none;}.b3{fill:none;}.b4{fill:none;}.a1{fill:none;}.a2{fill:none;}.a3{fill:none;}</style>",
            _NAKED_BANNY
        );
    }

    function _nakedBannySvgOf(uint256 tier) internal pure returns (string memory) {
        (
            string memory b1,
            string memory b2,
            string memory b3,
            string memory b4,
            string memory a1,
            string memory a2,
            string memory a3
        ) = _fillsFor(tier);
        return string.concat(
            "<style>.b1{fill:#",
            b1,
            ";}.b2{fill:#",
            b2,
            ";}.b3{fill:#",
            b3,
            ";}.b4{fill:#",
            b4,
            ";}.a1{fill:#",
            a1,
            ";}.a2{fill:#",
            a2,
            ";}.a3{fill:#",
            a3,
            ";}</style>",
            _NAKED_BANNY
        );
    }

    function _fillsFor(uint256 tier)
        internal
        pure
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        if (tier == ALIEN_TIER) {
            return ("67d757", "30a220", "217a15", "none", "e483ef", "dc2fef", "dc2fef");
        } else if (tier == PINK_TIER) {
            return ("ffd8c5", "ff96a9", "fe588b", "c92f45", "ffd8c5", "ff96a9", "fe588b");
        } else if (tier == ORANGE_TIER) {
            return ("f3a603", "ff7c02", "fd3600", "c32e0d", "f3a603", "ff7c02", "fd3600");
        } else if (tier == ORIGINAL_TIER) {
            return ("ffe900", "ffc700", "f3a603", "965a1a", "ffe900", "ffc700", "f3a603");
        }

        revert UNRECOGNIZED_TIER();
    }

    /// @notice The SVG contents for a list of outfit IDs.
    /// @param hook The address of the hook storing the assets.
    /// @param nakedBannyTier The tier of the naked banny being dressed.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny.
    function _outfitContentsFor(
        address hook,
        uint256 nakedBannyTier,
        uint256[] memory outfitIds
    )
        internal
        view
        returns (string memory contents)
    {
        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfOutfits = outfitIds.length;

        // Keep a reference to the outfit ID being iterated on.
        uint256 outfitId;

        // Keep a reference to the category of the outfit being iterated on.
        uint256 category;

        // Keep a reference to if certain accessories have been added.
        bool hasNecklace;
        bool hasFace;
        bool hasEyes;
        bool hasMouth;

        // If there are less than 3 outfits, loop once more to make sure all default outfits are added.
        uint256 numberOfIterations = numberOfOutfits < 3 ? numberOfOutfits + 1 : numberOfOutfits;

        // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        for (uint256 i; i < numberOfIterations; i++) {
            // If the outfit is within the bounds of the number of outfits there are, add it normally.
            if (i < numberOfOutfits) {
                // Set the outfit ID being iterated on.
                outfitId = outfitIds[i];

                // Set the category of the outfit being iterated on.
                category = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, outfitId, false).category;
            } else {
                // Set the category to be greater than the last default category.
                category = _FACE_MOUTH_CATEGORY + 1;
                outfitId = 0;
            }

            if (category == _NECKLACE_CATEGORY) {
                hasNecklace = true;
            } else if (category > _NECKLACE_CATEGORY && !hasNecklace) {
                contents = string.concat(contents, _DEFAULT_NECKLACE);
                hasNecklace = true;
            }
            if (category == _FACE_CATEGORY) {
                hasFace = true;
            } else if (category > _FACE_CATEGORY && !hasFace) {
                if (category == _FACE_EYES_CATEGORY) {
                    hasEyes = true;
                } else if (category > _FACE_EYES_CATEGORY && !hasEyes) {
                    if (nakedBannyTier == ALIEN_TIER) contents = string.concat(contents, _DEFAULT_ALIEN_EYES);
                    else contents = string.concat(contents, _DEFAULT_STANDARD_EYES);
                    hasEyes = true;
                }
                if (category == _FACE_MOUTH_CATEGORY) {
                    hasMouth = true;
                } else if (category > _FACE_MOUTH_CATEGORY && !hasMouth) {
                    contents = string.concat(contents, _DEFAULT_MOUTH);
                    hasMouth = true;
                }

                if (hasEyes && hasMouth && !hasFace) {
                    hasFace = true;
                }
            }

            // Add the outfit if needed.
            if (outfitId != 0) {
                contents = string.concat(contents, _svgOf(hook, outfitId));
            }
        }
    }

    /// @notice The name of each tier.
    function _nameOf(uint256 tokenId, uint256 tierId, uint256 category) public view returns (string memory) {
        // Get just the token ID without the tier ID included.
        uint256 rawTokenId = tokenId % _ONE_BILLION;

        if (tierId == ALIEN_TIER) {
            return string.concat("Alien Naked Banny ", tokenId.toString());
        } else if (tierId == PINK_TIER) {
            return string.concat("Pink Naked Banny ", tokenId.toString());
        } else if (tierId == ORANGE_TIER) {
            return string.concat("Orange Naked Banny ", tokenId.toString());
        } else if (tierId == ORIGINAL_TIER) {
            return string.concat("Original Naked Banny ", tokenId.toString());
        } else {
            string memory name = _tierNameOf[tierId];

            // If there is a token ID, add it to the name.
            if (rawTokenId != 0) {
                if (bytes(name).length == 0) name = rawTokenId.toString();
                else name = string.concat(name, " #", rawTokenId.toString());
            }

            if (category == _WORLD_CATEGORY) {
                return string.concat("World: ", name);
            } else if (category == _BACKSIDE_CATEGORY) {
                return string.concat("Backside: ", name);
            } else if (category == _SHOE_CATEGORY) {
                return string.concat("Shoe: ", name);
            } else if (category == _NECKLACE_CATEGORY) {
                return string.concat("Necklace: ", name);
            } else if (category == _FACE_CATEGORY) {
                return string.concat("Face: ", name);
            } else if (category == _FACE_EYES_CATEGORY) {
                return string.concat("Eyes: ", name);
            } else if (category == _FACE_MOUTH_CATEGORY) {
                return string.concat("Mouth: ", name);
            } else if (category == _HEADGEAR_CATEGORY) {
                return string.concat("Hair: ", name);
            } else if (category == _HEAD_CATEGORY) {
                return string.concat("Head: ", name);
            } else if (category == _SUIT_CATEGORY) {
                return string.concat("Suit: ", name);
            } else if (category == _SUIT_TOP_CATEGORY) {
                return string.concat("Suit top: ", name);
            } else if (category == _SUIT_BOTTOM_CATEGORY) {
                return string.concat("Suit bottom: ", name);
            } else if (category == _FIST_CATEGORY) {
                return string.concat("Fist: ", name);
            } else if (category == _TOPPING_CATEGORY) {
                return string.concat("Topping: ", name);
            }
            return "";
        }
    }

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    function _svgOf(address hook, uint256 tierId) private view returns (string memory) {
        // Keep a reference to the stored scg contents.
        string memory svgContents = _svgContentOf[tierId];

        if (bytes(svgContents).length != 0) return svgContents;

        return string.concat(
            '<g><image href="',
            JBIpfsDecoder.decode(svgBaseUri, IJB721TiersHook(hook).STORE().encodedIPFSUriOf(hook, tierId)),
            '" width="400" height="400"/></g>'
        );
    }

    //*********************************************************************//
    // ---------------------- internal transactions ---------------------- //
    //*********************************************************************//

    /// @notice Returns the sender, prefered to use over `msg.sender`
    /// @return sender the sender address of this call.
    function _msgSender() internal view override(ERC2771Context, Context) returns (address sender) {
        return ERC2771Context._msgSender();
    }

    /// @notice Returns the calldata, prefered to use over `msg.data`
    /// @return calldata the `msg.data` of this call
    function _msgData() internal view override(ERC2771Context, Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    /// @dev ERC-2771 specifies the context as being a single address (20 bytes).
    function _contextSuffixLength() internal view virtual override(ERC2771Context, Context) returns (uint256) {
        return super._contextSuffixLength();
    }
}
