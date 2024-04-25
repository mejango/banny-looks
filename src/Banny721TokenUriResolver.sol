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
    event SetSvgContent(uint256 indexed upc, string svgContent, address caller);
    event SetSvgHash(uint256 indexed upc, bytes32 indexed svgHash, address caller);
    event SetSvgBaseUri(string baseUri, address caller);
    event SetProductName(uint256 indexed upc, string name, address caller);

    error ASSET_IS_ALREADY_BEING_WORN();
    error HEAD_ALREADY_ADDED();
    error SUIT_ALREADY_ADDED();
    error UNRECOGNIZED_WORLD();
    error UNAUTHORIZED_NAKED_BANNY();
    error UNAUTHORIZED_WORLD();
    error UNAUTHORIZED_OUTFIT();
    error UNRECOGNIZED_CATEGORY();
    error UNRECOGNIZED_OUTFIT();
    error UNORDERED_CATEGORIES();
    error CONTENTS_ALREADY_STORED();
    error HASH_NOT_FOUND();
    error CONTENTS_MISMATCH();
    error HASH_ALREADY_STORED();
    error UNRECOGNIZED_PRODUCT();

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
    uint8 private constant _GLASSES_CATEGORY = 5;
    uint8 private constant _MOUTH_CATEGORY = 6;
    uint8 private constant _LEGS_CATEGORY = 7;
    uint8 private constant _SUIT_CATEGORY = 8;
    uint8 private constant _SUIT_BOTTOM_CATEGORY = 9;
    uint8 private constant _SUIT_TOP_CATEGORY = 10;
    uint8 private constant _HEADTOP_CATEGORY = 11;
    uint8 private constant _FIST_CATEGORY = 12;
    uint8 private constant _TOPPING_CATEGORY = 13;

    uint8 private constant ALIEN_UPC = 1;
    uint8 private constant PINK_UPC = 2;
    uint8 private constant ORANGE_UPC = 3;
    uint8 private constant ORIGINAL_UPC = 4;

    /// @notice The Naked Banny and outfit SVG hash files.
    /// @custom:param upc The universal product code that the SVG hash represent.
    mapping(uint256 upc => bytes32) public svgHashOf;

    /// @notice The base of the domain hosting the SVG files that can be lazily uploaded to the contract.
    string public svgBaseUri;

    /// @notice The name of each product.
    /// @custom:param upc The universal product code that the name belongs to.
    mapping(uint256 upc => string) internal _customProductNameOf;

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param upc The universal product code that the SVG contents represent.
    mapping(uint256 upc => string) internal _svgContentOf;

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
    mapping(uint256 worldId => uint256) internal _userOf;

    /// @notice The ID of the naked banny each outfit is being worn by.
    /// @custom:param outfitId The ID of the outfit.
    mapping(uint256 outfitId => uint256) internal _wearerOf;

    /// @notice The assets currently attached to each Naked Banny, owned by the naked Banny's owner.
    /// @param nakedBannyId The ID of the naked banny shows with the associated assets.
    /// @return worldId The world attached to the Naked Banny.
    /// @return outfitIds The outfits attached to the Naked Banny.
    function assetIdsOf(uint256 nakedBannyId) public view returns (uint256 worldId, uint256[] memory outfitIds) {
        // Keep a reference to the outfit IDs currently attached to the Naked Banny.
        outfitIds = _attachedOutfitIdsOf[nakedBannyId];

        // Add the world.
        worldId = _attachedWorldIdOf[nakedBannyId];
    }

    /// @notice Checks to see which naked banny is currently using a particular world.
    /// @param worldId The ID of the world being used.
    /// @return The ID of the naked banny using the world.
    function userOf(uint256 worldId) public view returns (uint256) {
        // Get a reference to the naked banny using the world.
        uint256 nakedBannyId = _userOf[worldId];

        // If no naked banny is wearing the outfit, or if its no longer the world attached, return 0.
        if (nakedBannyId == 0 || _attachedWorldIdOf[nakedBannyId] != worldId) return 0;

        // Return the naked banny ID.
        return nakedBannyId;
    }

    /// @notice Checks to see which naked banny is currently wearing a particular outfit.
    /// @param outfitId The ID of the outfit being worn.
    /// @return The ID of the naked banny wearing the outfit.
    function wearerOf(uint256 outfitId) public view returns (uint256) {
        // Get a reference to the naked banny wearing the outfit.
        uint256 nakedBannyId = _wearerOf[outfitId];

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
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        // If the token's product ID doesn't exist, return an empty uri.
        if (product.id == 0) return "";

        string memory contents;

        string memory extraNakedBannyMetadata = "";

        // If this isn't a Naked Banny, return the asset SVG alone (or on a manakin banny).
        if (product.category != _NAKED_CATEGORY) {
            // Keep a reference to the SVG contents.
            contents = _svgOf(hook, product.id);

            // Layer the outfit SVG over the mannequin Banny
            // Start with the mannequin SVG if we're not returning a world.
            if (bytes(contents).length != 0) {
                if (product.category != _WORLD_CATEGORY) {
                    contents = string.concat(_mannequinBannySvg(), contents);
                }
                contents = _layeredSvg(contents);
            }
        } else {
            // Compose the contents.
            contents =
                svgOf({hook: hook, tokenId: tokenId, shouldDressNakedBanny: true, shouldIncludeWorldOnNakedBanny: true});

            // Get a reference to each asset ID currently attached to the Naked Banny.
            (uint256 worldId, uint256[] memory outfitIds) = assetIdsOf(tokenId);

            // Keep a reference to the number of outfits
            uint256 numberOfOutfits = outfitIds.length;

            extraNakedBannyMetadata = '"outfitUpcs": [';

            for (uint256 i; i < numberOfOutfits; i++) {
                extraNakedBannyMetadata = string.concat(extraNakedBannyMetadata, '"', outfitIds[i].toString(), '",');
            }

            extraNakedBannyMetadata = string.concat(extraNakedBannyMetadata, '],');
            
            if (worldId != 0) extraNakedBannyMetadata = string.concat(extraNakedBannyMetadata, '"worldUpc": "', worldId.toString(), '",');
        }

        if (bytes(contents).length == 0) {
            // If the product's category is greater than the last expected category, use the default base URI of the 721
            // contract. Otherwise use the SVG URI.
            string memory baseUri = product.category > _TOPPING_CATEGORY ? IJB721TiersHook(hook).baseURI() : svgBaseUri;

            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(baseUri, IJB721TiersHook(hook).STORE().encodedTierIPFSUriOf(hook, tokenId));
        }

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                abi.encodePacked(
                    '{"name":"',
                    _fullNameOf(tokenId, product),
                    '", "productName": "',
                    _productNameOf(product.id),
                    '", "categoryName": "',
                    _categoryNameOf(product.category),
                    '", "upc": "',
                    product.id.toString(),
                    '", "category": "',
                    product.category.toString(),
                    '", "supply": "',
                    product.initialSupply.toString(),
                    '", "remaining": "',
                    product.remainingSupply.toString(),
                    '", "price": "',
                    product.price.toString(),
                    '", ',
                    extraNakedBannyMetadata,
                    '"description":"A piece of the Bannyverse","image":"data:image/svg+xml;base64,',
                    Base64.encode(abi.encodePacked(contents)),
                    '"}'
                )
            )
        );
    }

    /// @notice Returns the SVG showing either a naked banny with/without outfits and a world, or the stand alone outfit
    /// or world.
    /// @param hook The hook storing the assets.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfits in its current world if specified.
    /// @param shouldDressNakedBanny Whether the naked banny should be dressed.
    /// @param shouldIncludeWorldOnNakedBanny Whether the world should be included on the naked banny.
    /// @return svg The SVG.
    function svgOf(
        address hook,
        uint256 tokenId,
        bool shouldDressNakedBanny,
        bool shouldIncludeWorldOnNakedBanny
    )
        public
        view
        returns (string memory)
    {
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        // If the token's product doesn't exist, return an empty uri.
        if (product.id == 0) return "";

        // Compose the contents.
        string memory contents;

        // If this isn't a Naked Banny and there's an SVG available, return the asset SVG alone.
        if (product.category != _NAKED_CATEGORY) {
            // Keep a reference to the SVG contents.
            contents = _svgOf(hook, product.id);

            // Return the svg if it exists.
            return (bytes(contents).length == 0) ? "" : _layeredSvg(contents);
        }

        // Get a reference to each asset ID currently attached to the Naked Banny.
        (uint256 worldId, uint256[] memory outfitIds) = assetIdsOf(tokenId);

        // Add the world if needed.
        if (worldId != 0 && shouldIncludeWorldOnNakedBanny) contents = string.concat(contents, _svgOf(hook, worldId));

        // Start with the Naked Banny.
        contents = string.concat(contents, _nakedBannySvgOf(product.id));

        // Add eyes.
        if (product.id == ALIEN_UPC) contents = string.concat(contents, _DEFAULT_ALIEN_EYES);
        else contents = string.concat(contents, _DEFAULT_STANDARD_EYES);

        if (shouldDressNakedBanny) {
            // Get the outfit contents.
            string memory outfitContents = _outfitContentsFor({hook: hook, outfitIds: outfitIds});

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
    /// @return fullName The full name of the token.
    /// @return categoryName The name of the token's category.
    /// @return productName The name of the token's product.
    function namesOf(address hook, uint256 tokenId) public view returns (string memory, string memory, string memory) {
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        return (_fullNameOf(tokenId, product), _categoryNameOf(product.category), _productNameOf(tokenId));
    }

    /// @param owner The owner allowed to add SVG files that correspond to product IDs.
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
        if (IERC721(hook).ownerOf(nakedBannyId) != _msgSender()) revert UNAUTHORIZED_NAKED_BANNY();

        // Add the world if needed.
        if (worldId != 0) {
            // Check if the owner matched.
            if (IERC721(hook).ownerOf(worldId) != _msgSender()) revert UNAUTHORIZED_WORLD();

            // Make sure the world is not already being shown on another Naked banny.
            if (userOf(worldId) != 0) revert ASSET_IS_ALREADY_BEING_WORN();

            // Get the world's product info.
            JB721Tier memory worldProduct = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, worldId, false);

            // World must exist
            if (worldProduct.id == 0) revert UNRECOGNIZED_WORLD();

            // Store the world for the banny.
            _attachedWorldIdOf[nakedBannyId] = worldId;

            // Store the banny that's in the world.
            _userOf[worldId] = nakedBannyId;
        } else {
            _attachedWorldIdOf[nakedBannyId] = 0;
        }

        // Keep a reference to the number of outfits being worn.
        uint256 numberOfAssets = outfitIds.length;

        // Keep a reference to the outfit being iterated on.
        uint256 outfitId;

        // Keep a reference to the category of the last outfit iterated on.
        uint256 lastAssetCategory;

        // Keep a reference to the product of the outfit being iterated on.
        JB721Tier memory outfitProduct;

        bool hasHead;
        bool hasSuit;

        // Iterate through each outfit checking to see if the message sender owns them all.
        for (uint256 i; i < numberOfAssets; i++) {
            // Set the outfit ID being iterated on.
            outfitId = outfitIds[i];

            // Check if the owner matched.
            if (IERC721(hook).ownerOf(outfitId) != _msgSender()) revert UNAUTHORIZED_OUTFIT();

            // Make sure the outfit is not already being worn.
            if (wearerOf(outfitId) != 0) revert ASSET_IS_ALREADY_BEING_WORN();

            // Get the outfit's product info.
            outfitProduct = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, outfitId, false);

            // Product must exist
            if (outfitProduct.id == 0) revert UNRECOGNIZED_OUTFIT();

            // The product's category must be a known category.
            if (outfitProduct.category < _BACKSIDE_CATEGORY || outfitProduct.category > _TOPPING_CATEGORY) {
                revert UNRECOGNIZED_CATEGORY();
            }

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitProduct.category <= lastAssetCategory) revert UNORDERED_CATEGORIES();

            if (outfitProduct.category == _HEAD_CATEGORY) {
                hasHead = true;
            } else if (outfitProduct.category == _SUIT_CATEGORY) {
                hasSuit = true;
            } else if (
                (
                    outfitProduct.category == _GLASSES_CATEGORY || outfitProduct.category == _MOUTH_CATEGORY
                        || outfitProduct.category == _HEADTOP_CATEGORY
                ) && hasHead
            ) {
                revert HEAD_ALREADY_ADDED();
            } else if (
                (outfitProduct.category == _SUIT_TOP_CATEGORY || outfitProduct.category == _SUIT_BOTTOM_CATEGORY)
                    && hasSuit
            ) {
                revert SUIT_ALREADY_ADDED();
            }

            // Keep a reference to the last outfit's category.
            lastAssetCategory = outfitProduct.category;

            // Store the banny that's in the world.
            _wearerOf[outfitId] = nakedBannyId;
        }

        // Store the outfits.
        _attachedOutfitIdsOf[nakedBannyId] = outfitIds;

        emit DecorateBanny(hook, nakedBannyId, worldId, outfitIds, _msgSender());
    }

    /// @notice The owner of this contract can store SVG files for product IDs.
    /// @param upcs The universal product codes of the products having SVGs stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element.
    function setSvgContentsOf(uint256[] memory upcs, string[] calldata svgContents) external {
        uint256 numberOfProducts = upcs.length;

        uint256 upc;
        string memory svgContent;

        for (uint256 i; i < numberOfProducts; i++) {
            upc = upcs[i];
            svgContent = svgContents[i];

            // Make sure there isn't already contents for the specified universal product code.
            if (bytes(_svgContentOf[upc]).length != 0) revert CONTENTS_ALREADY_STORED();

            // Get the stored svg hash for the product.
            bytes32 svgHash = svgHashOf[upc];

            // Make sure a hash exists.
            if (svgHash == bytes32(0)) revert HASH_NOT_FOUND();

            // Make sure the content matches the hash.
            if (keccak256(abi.encodePacked(svgContent)) != svgHash) revert CONTENTS_MISMATCH();

            // Store the svg contents.
            _svgContentOf[upc] = svgContent;

            emit SetSvgContent(upc, svgContent, msg.sender);
        }
    }

    /// @notice Allows the owner of this contract to upload the hash of an svg file for a universal product code.
    /// @dev This allows anyone to lazily upload the correct svg file.
    /// @param upcs The universal product codes of the products having SVG hashes stored.
    /// @param svgHashs The svg hashes being stored, not including the parent <svg></svg> element.
    function setSvgHashsOf(uint256[] memory upcs, bytes32[] memory svgHashs) external onlyOwner {
        uint256 numberOfProducts = upcs.length;

        uint256 upc;
        bytes32 svgHash;

        for (uint256 i; i < numberOfProducts; i++) {
            upc = upcs[i];
            svgHash = svgHashs[i];

            // Make sure there isn't already contents for the specified universal product code.
            if (svgHashOf[upc] != bytes32(0)) revert HASH_ALREADY_STORED();

            // Store the svg contents.
            svgHashOf[upc] = svgHash;

            emit SetSvgHash(upc, svgHash, msg.sender);
        }
    }

    /// @notice Allows the owner to set the product's name.
    /// @param upcs The universal product codes of the products having their name stored.
    /// @param names The names of the products.
    function setProductNames(uint256[] memory upcs, string[] memory names) external onlyOwner {
        uint256 numberOfProducts = upcs.length;

        uint256 upc;
        string memory name;

        for (uint256 i; i < numberOfProducts; i++) {
            upc = upcs[i];
            name = names[i];

            _customProductNameOf[upc] = name;

            emit SetProductName(upc, name, msg.sender);
        }
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

    function _nakedBannySvgOf(uint256 upc) internal pure returns (string memory) {
        (
            string memory b1,
            string memory b2,
            string memory b3,
            string memory b4,
            string memory a1,
            string memory a2,
            string memory a3
        ) = _fillsFor(upc);
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

    function _fillsFor(uint256 upc)
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
        if (upc == ALIEN_UPC) {
            return ("67d757", "30a220", "217a15", "none", "e483ef", "dc2fef", "dc2fef");
        } else if (upc == PINK_UPC) {
            return ("ffd8c5", "ff96a9", "fe588b", "c92f45", "ffd8c5", "ff96a9", "fe588b");
        } else if (upc == ORANGE_UPC) {
            return ("f3a603", "ff7c02", "fd3600", "c32e0d", "f3a603", "ff7c02", "fd3600");
        } else if (upc == ORIGINAL_UPC) {
            return ("ffe900", "ffc700", "f3a603", "965a1a", "ffe900", "ffc700", "f3a603");
        }

        revert UNRECOGNIZED_PRODUCT();
    }

    /// @notice The SVG contents for a list of outfit IDs.
    /// @param hook The address of the hook storing the assets.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny.
    function _outfitContentsFor(
        address hook,
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
        bool hasMouth;

        // Keep a reference to the custom necklace. Needed because the custom necklace is layered differently than the default.
        string memory customNecklace;

        // Loop once more to make sure all default outfits are added.
        uint256 numberOfIterations = numberOfOutfits + 1;

        // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        for (uint256 i; i < numberOfIterations; i++) {
            // If the outfit is within the bounds of the number of outfits there are, add it normally.
            if (i < numberOfOutfits) {
                // Set the outfit ID being iterated on.
                outfitId = outfitIds[i];

                // Set the category of the outfit being iterated on.
                category = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, outfitId, false).category;
            } else {
                // Set the category to be more than all other categories to force adding defaults.
                category = _TOPPING_CATEGORY + 1;
                outfitId = 0;
            }

            if (category == _NECKLACE_CATEGORY) {
                hasNecklace = true;
                customNecklace = _svgOf(hook, outfitId);
            } else if (category > _NECKLACE_CATEGORY && !hasNecklace) {
                contents = string.concat(contents, _DEFAULT_NECKLACE);
                hasNecklace = true;
            }

            if (category == _MOUTH_CATEGORY) {
                hasMouth = true;
            } else if (category > _MOUTH_CATEGORY && !hasMouth) {
                contents = string.concat(contents, _DEFAULT_MOUTH);
                hasMouth = true;
            }

            // Add the custom necklace if needed.
            if (category > _SUIT_TOP_CATEGORY && bytes(customNecklace).length != 0) {
                contents = string.concat(contents, customNecklace);
                // Reset.
                customNecklace = "";
            }

            // Add the outfit if needed.
            if (outfitId != 0 && category != _NECKLACE_CATEGORY) {
                contents = string.concat(contents, _svgOf(hook, outfitId));
            }
        }
    }

    /// @notice The name of each token's product type.
    /// @param upc The ID of the token whose product type is being named.
    /// @return name The item's product name.
    function _productNameOf(uint256 upc) internal view returns (string memory) {
        // Get the token's name.
        if (upc == ALIEN_UPC) {
            return "Alien";
        } else if (upc == PINK_UPC) {
            return "Pink";
        } else if (upc == ORANGE_UPC) {
            return "Orange";
        } else if (upc == ORIGINAL_UPC) {
            return "Original";
        } else {
            // Get the product's name that has been uploaded.
            return _customProductNameOf[upc];
        }
    }

    /// @notice The name of each token's category.
    /// @param category The category of the token being named.
    /// @return name The token's category name.
    function _categoryNameOf(uint256 category) internal pure returns (string memory) {
        if (category == _NAKED_CATEGORY) {
            return "Naked Banny";
        } else if (category == _WORLD_CATEGORY) {
            return "World";
        } else if (category == _BACKSIDE_CATEGORY) {
            return "Backside";
        } else if (category == _LEGS_CATEGORY) {
            return "Legs";
        } else if (category == _NECKLACE_CATEGORY) {
            return "Necklace";
        } else if (category == _GLASSES_CATEGORY) {
            return "Glasses";
        } else if (category == _MOUTH_CATEGORY) {
            return "Mouth";
        } else if (category == _HEADTOP_CATEGORY) {
            return "Head top";
        } else if (category == _HEAD_CATEGORY) {
            return "Head";
        } else if (category == _SUIT_CATEGORY) {
            return "Suit";
        } else if (category == _SUIT_TOP_CATEGORY) {
            return "Suit top";
        } else if (category == _SUIT_BOTTOM_CATEGORY) {
            return "Suit bottom";
        } else if (category == _FIST_CATEGORY) {
            return "Fist";
        } else if (category == _TOPPING_CATEGORY) {
            return "Topping";
        }
        return "";
    }

    /// @notice The full name of each product, including category and inventory.
    /// @param tokenId The ID of the token being named.
    /// @param product The product of the token being named.
    /// @return name The full name.
    function _fullNameOf(uint256 tokenId, JB721Tier memory product) internal view returns (string memory name) {
        // Start with the item's name.
        name = string.concat(_productNameOf(product.id), " ");

        // Get just the token ID without the product ID included.
        uint256 rawTokenId = tokenId % _ONE_BILLION;

        // If there's a raw token id, append it to the name before appending it to the category.
        if (rawTokenId != 0) {
            name = string.concat(name, rawTokenId.toString(), "/", product.initialSupply.toString());
        } else if (product.remainingSupply == 0) {
            name = string.concat(
                name,
                " (SOLD OUT) ",
                product.remainingSupply.toString(),
                "/",
                product.initialSupply.toString(),
                " remaining"
            );
        } else {
            name = string.concat(
                name, product.remainingSupply.toString(), "/", product.initialSupply.toString(), " remaining"
            );
        }

        // Append a separator.
        name = string.concat(name, " : ");

        // Get a reference to the categorie's name.
        string memory categoryName = _categoryNameOf(product.category);

        // If there's a category name, append it.
        if (bytes(categoryName).length != 0) {
            name = string.concat(name, categoryName, " ");
        }

        // Append the product ID as a universal product code.
        name = string.concat(name, "UPC #", product.id.toString());
    }

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param upc The universal product code of the product that the SVG contents represent.
    function _svgOf(address hook, uint256 upc) internal view returns (string memory) {
        // Keep a reference to the stored scg contents.
        string memory svgContents = _svgContentOf[upc];

        if (bytes(svgContents).length != 0) return svgContents;

        return string.concat(
            '<image href="',
            JBIpfsDecoder.decode(svgBaseUri, IJB721TiersHook(hook).STORE().encodedIPFSUriOf(hook, upc)),
            '" width="400" height="400"/>'
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
