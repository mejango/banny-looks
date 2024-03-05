// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IJB721TokenUriResolver} from "@bananapus/721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {IERC721} from "@bananapus/721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHook} from "@bananapus/721-hook/src/interfaces/IJB721TiersHook.sol";
import {JB721Tier} from "@bananapus/721-hook/src/structs/JB721Tier.sol";
import {JBIpfsDecoder} from "@bananapus/721-hook/src/libraries/JBIpfsDecoder.sol";

/// @notice Banny asset manager. Stores and shows Naked Bannys in worlds with outfits on.
contract Banny721TokenUriResolver is IJB721TokenUriResolver, Ownable {
    event DecorateBanny(address indexed hook, uint256 indexed nakenBannyId, uint256 worldId, uint256[] outfitIds, address caller);
    event SetSvgContents(uint256 indexed tierId, bytes32 indexed svgHash, string svgContents, address caller);
    event SetSvgHash(uint256 indexed tierId, bytes32 indexed svgHash, address caller);
    event SetSvgBaseUri(string baseUri, address caller);

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
    error UNRECOGNIZED_TIER();

    string public constant NAKED_BANNY =
        '<g class="a1"><path d="M173 53h4v17h-4z"/></g><g class="a2"><path d="M167 57h3v10h-3z"/><path d="M169 53h4v17h-4z"/></g><g class="a3"><path d="M167 53h3v4h-3z"/><path d="M163 57h4v10h-4z"/><path d="M167 67h3v3h-3z"/></g><g class="b1"><path d="M213 253h-3v-3-3h-3v-7-3h-4v-10h-3v-7-7-3h-3v-73h-4v-10h-3v-10h-3v-7h-4v-7h-3v-3h-3v-3h-4v10h4v10h3v10h3v3h4v7 3 70 3h3v7h3v20h4v7h3v3h3v3h4v4h3v3h3v-3-4z"/><path d="M253 307v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-6h-3v-7h-4v17h4v3h3v3h3 4v4h3v3h3v3h4v4h3v3h3v3h4v4h3v3h3v3h4v-6h-4z"/></g><g class="b2"><path d="M250 310v-3h-3v-4h-4v-3h-3v-3h-3v-4h-4v-3h-3v-3h-3v-4h-7v-3h-3v-3h-4v-17h-3v-3h-3v-4h-4v-3h-3v-3h-3v-7h-4v-20h-3v-7h-3v-73-3-7h-4v-3h-3v-10h-3v-10h-4V70h-3v-3l-3 100 3-100v40h-3v10h-4v6h-3v14h-3v3 13h-4v44h4v16h3v14h3v13h4v10h3v7h3v3h4v3h3v4h3v3h4v3h3v4h3v3h4v3h3v7h7v7h6v3h7v3h7v4h13v3h3v3h10v-3h-3zm-103-87v-16h3v-10h-3v6h-4v17h-3v10h3v-7h4z"/><path d="M143 230h4v7h-4zm4 10h3v3h-3zm3 7h3v3h-3zm3 6h4v4h-4z"/><path d="M163 257h-6v3h3v3h3v4h4v-4-3h-4v-3z"/></g><g class="b3"><path d="M143 197v6h4v-6h6v-44h4v-16h3v-14h3v-6h4v-10h3V97h-7v6h-3v4h-3v3h-4v3h-3v4 3h-3v3 4h-4v10h-3v16 4h-3v46h3v-6h3z"/><path d="M140 203h3v17h-3z"/><path d="M137 220h3v10h-3z"/><path d="M153 250h-3v-7h-3v-6h-4v-7h-3v10h3v7h4v6h3v4h3v-7zm-3 10h3v7h-3z"/><path d="M147 257h3v3h-3zm6 0h4v3h-4z"/><path d="M160 263v-3h-3v3 7h6v-7h-3zm-10-56v16h-3v7h3v10h3v7h4v6h6v4h7v-4-3h-3v-10h-4v-13h-3v-14h-3v-16h-4v10h-3z"/><path d="M243 313v-3h-3v-3h-10-3v-4h-7v-3h-7v-3h-6v-7h-7v-7h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v10h-3v3h-4v3h-3v7h3v7h4v6h3v5h4v3h6v3h3v3h4 3v3h3 4v3h3 3v4h10v3h7 7 3v3h10 3v-3h10v-3h4v-4h-14z"/></g><g class="b4"><path d="M183 130h4v7h-4z"/><path d="M180 127h3v3h-3zm-27-4h4v7h-4z"/><path d="M157 117h3v6h-3z"/><path d="M160 110h3v7h-3z"/><path d="M163 107h4v3h-4zm-3 83h3v7h-3z"/><path d="M163 187h4v3h-4zm20 0h7v3h-7z"/><path d="M180 190h3v3h-3zm10-7h3v4h-3z"/><path d="M193 187h4v6h-4zm-20 53h4v7h-4z"/><path d="M177 247h3v6h-3z"/><path d="M180 253h3v7h-3z"/><path d="M183 260h7v3h-7z"/><path d="M190 263h3v4h-3zm0-20h3v4h-3z"/><path d="M187 240h3v3h-3z"/><path d="M190 237h3v3h-3zm13 23h4v3h-4z"/><path d="M207 263h3v7h-3z"/><path d="M210 270h3v3h-3zm-10 7h3v6h-3z"/><path d="M203 283h4v7h-4z"/><path d="M207 290h6v3h-6z"/></g><g class="o"><path d="M133 157h4v50h-4zm0 63h4v10h-4zm27-163h3v10h-3z"/><path d="M163 53h4v4h-4z"/><path d="M167 50h10v3h-10z"/><path d="M177 53h3v17h-3z"/><path d="M173 70h4v27h-4zm-6 0h3v27h-3z"/><path d="M163 67h4v3h-4zm0 30h4v3h-4z"/><path d="M160 100h3v3h-3z"/><path d="M157 103h3v4h-3z"/><path d="M153 107h4v3h-4z"/><path d="M150 110h3v3h-3z"/><path d="M147 113h3v7h-3z"/><path d="M143 120h4v7h-4z"/><path d="M140 127h3v10h-3z"/><path d="M137 137h3v20h-3zm56-10h4v10h-4z"/><path d="M190 117h3v10h-3z"/><path d="M187 110h3v7h-3z"/><path d="M183 103h4v7h-4z"/><path d="M180 100h3v3h-3z"/><path d="M177 97h3v3h-3zm-40 106h3v17h-3zm0 27h3v10h-3zm10 30h3v7h-3z"/><path d="M150 257v-4h-3v-6h-4v-7h-3v10h3v10h4v-3h3z"/><path d="M150 257h3v3h-3z"/><path d="M163 273v-3h-6v-10h-4v7h-3v3h3v3h4v7h3v-7h3z"/><path d="M163 267h4v3h-4z"/><path d="M170 257h-3-4v3h4v7h3v-10z"/><path d="M157 253h6v4h-6z"/><path d="M153 247h4v6h-4z"/><path d="M150 240h3v7h-3z"/><path d="M147 230h3v10h-3zm13 50h3v7h-3z"/><path d="M143 223h4v7h-4z"/><path d="M147 207h3v16h-3z"/><path d="M150 197h3v10h-3zm-10 0h3v6h-3zm50 113h7v3h-7zm23 10h17v3h-17z"/><path d="M230 323h13v4h-13z"/><path d="M243 320h10v3h-10z"/><path d="M253 317h4v3h-4z"/><path d="M257 307h3v10h-3z"/><path d="M253 303h4v4h-4z"/><path d="M250 300h3v3h-3z"/><path d="M247 297h3v3h-3z"/><path d="M243 293h4v4h-4z"/><path d="M240 290h3v3h-3z"/><path d="M237 287h3v3h-3z"/><path d="M233 283h4v4h-4z"/><path d="M230 280h3v3h-3z"/><path d="M227 277h3v3h-3z"/><path d="M223 273h4v4h-4z"/><path d="M220 267h3v6h-3z"/><path d="M217 260h3v7h-3z"/><path d="M213 253h4v7h-4z"/><path d="M210 247h3v6h-3z"/><path d="M207 237h3v10h-3z"/><path d="M203 227h4v10h-4zm-40 60h4v6h-4zm24 20h3v3h-3z"/><path d="M167 293h3v5h-3zm16 14h4v3h-4z"/><path d="M170 298h4v3h-4zm10 6h3v3h-3z"/><path d="M174 301h6v3h-6zm23 12h6v4h-6z"/><path d="M203 317h10v3h-10zm-2-107v-73h-4v73h3v17h3v-17h-2z"/></g>';
    string public constant DEFAULT_LEGS =
        '<g class="o"><path d="M187 307v-4h3v-6h-3v-4h-4v-3h-3v-3h-7v-4h-6v4h-4v3h4v27h-4v13h-3v10h-4v7h4v3h3 10 14v-3h-4v-4h-3v-3h-3v-3h-4v-7h4v-10h3v-7h3v-3h7v-3h-3zm16 10v-4h-6v17h-4v10h-3v7h3v3h4 6 4 3 14v-3h-4v-4h-7v-3h-3v-3h-3v-10h3v-7h3v-3h-10z"/></g>';
    string public constant DEFAULT_NECKLACE =
        '<g class="o"><path d="M190 173h-37v-3h-10v-4h-6v4h3v3h-3v4h6v3h10v4h37v-4h3v-3h-3v-4zm-40 4h-3v-4h3v4zm7 3v-3h3v3h-3zm6 0v-3h4v3h-4zm7 0v-3h3v3h-3zm7 0v-3h3v3h-3zm10 0h-4v-3h4v3z"/><path d="M190 170h3v3h-3z"/><path d="M193 166h4v4h-4zm0 7h4v4h-4z"/></g><g class="w"><path d="M137 170h3v3h-3zm10 3h3v4h-3zm10 4h3v3h-3zm6 0h4v3h-4zm7 0h3v3h-3zm7 0h3v3h-3zm6 0h4v3h-4zm7-4h3v4h-3z"/><path d="M193 170h4v3h-4z"/></g>';
    string public constant DEFAULT_MOUTH =
        '<g class="o"><path d="M183 160v-4h-20v4h-3v3h3v4h24v-7h-4zm-13 3v-3h10v3h-10z" fill="#ad71c8"/><path d="M170 160h10v3h-10z"/></g>';
    string public constant DEFAULT_STANDARD_EYES =
        '<g class="o"><path d="M177 140v3h6v11h10v-11h4v-3h-20z"/><path d="M153 140v3h7v8 3h7 3v-11h3v-3h-20z"/></g><g class="w"><path d="M153 143h7v4h-7z"/><path d="M157 147h3v3h-3zm20-4h6v4h-6z"/><path d="M180 147h3v3h-3z"/></g>';
    string public constant DEFAULT_ALIEN_EYES =
        '<g class="o"><path d="M190 127h3v3h-3zm3 13h4v3h-4zm-42 0h6v6h-6z"/><path d="M151 133h3v7h-3zm10 0h6v4h-6z"/><path d="M157 137h17v6h-17zm3 13h14v3h-14zm17-13h7v16h-7z"/><path d="M184 137h6v6h-6zm0 10h10v6h-10z"/><path d="M187 143h10v4h-10z"/><path d="M190 140h3v3h-3zm-6-10h3v7h-3z"/><path d="M187 130h6v3h-6zm-36 0h10v3h-10zm16 13h7v7h-7zm-10 0h7v7h-7z"/><path d="M164 147h3v3h-3zm29-20h4v6h-4z"/><path d="M194 133h3v7h-3z"/></g><g class="w"><path d="M154 133h7v4h-7z"/><path d="M154 137h3v3h-3zm10 6h3v4h-3zm20 0h3v4h-3zm3-10h7v4h-7z"/><path d="M190 137h4v3h-4z"/></g>';

    uint8 public constant NAKED_CATEGORY = 0;
    uint8 public constant WORLD_CATEGORY = 1;
    uint8 public constant LEGS_CATEGORY = 2;
    uint8 public constant NECKLACE_CATEGORY = 3;
    uint8 public constant FACE_CATEGORY = 4;
    uint8 public constant EYES_CATEGORY = 5;
    uint8 public constant MOUTH_CATEGORY = 6;
    uint8 public constant HEADGEAR_CATEGORY = 7;
    uint8 public constant SUIT_CATEGORY = 8;
    uint8 public constant RIGHT_FIST_CATEGORY = 9;
    uint8 public constant LEFT_FIST_CATEGORY = 10;
    uint8 public constant MISC_CATEGORY = 11;

    string public constant OUTLINE_1 = "050505";
    string public constant OUTLINE_2 = "808080";

    string public constant WHITE = "f9f9f9";

    uint8 public constant ALIEN_TIER = 1;
    string public constant ALIEN_BODY_1 = "67d757";
    string public constant ALIEN_BODY_2 = "30a220";
    string public constant ALIEN_BODY_3 = "217a15";
    string public constant ALIEN_BODY_4 = "none";
    string public constant ALIEN_ANTENNA_1 = "e483ef";
    string public constant ALIEN_ANTENNA_2 = "dc2fef";

    uint8 public constant PINK_TIER = 2;
    string public constant PINK_BODY_1 = "ffd8c5";
    string public constant PINK_BODY_2 = "ff96a9";
    string public constant PINK_BODY_3 = "fe588b";
    string public constant PINK_BODY_4 = "c92f45";

    uint8 public constant ORANGE_TIER = 3;
    string public constant ORANGE_BODY_1 = "f3a603";
    string public constant ORANGE_BODY_2 = "ff7c02";
    string public constant ORANGE_BODY_3 = "fd3600";
    string public constant ORANGE_BODY_4 = "c32e0d";

    uint8 public constant ORIGINAL_TIER = 4;
    string public constant ORIGINAL_BODY_1 = "ffe900";
    string public constant ORIGINAL_BODY_2 = "ffc700";
    string public constant ORIGINAL_BODY_3 = "f3a603";
    string public constant ORIGINAL_BODY_4 = "965a1a";

    /// @notice The Naked Banny and outfit SVG hash files.
    /// @custom:param tierId The ID of the tier that the SVG hash represent.
    mapping(uint256 tierId => bytes32) public svgHashOf;

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    mapping(uint256 tierId => string) private _svgContentsOf;

    /// @notice The outfits currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with outfits currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the outfits.
    mapping(uint256 nakedBannyId => uint256[]) internal _attachedOutfitIdsOf;

    /// @notice The world currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with a world currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the world.
    mapping(uint256 nakedBannyId => uint256) internal _attachedWorldIdOf;

    /// @notice The base of the domain hosting the SVG files that can be lazily uploaded to the contract.    
    string public svgBaseUri;

    /// @notice The assets currently attached to each Naked Banny, owned by the naked Banny's owner.
    /// @param hook The address of the hook storing the assets.
    /// @param nakedBannyId The ID of the naked banny shows with the associated assets.
    /// @return worldId The world attached to the Naked Banny.
    /// @return outfitIds The outfits attached to the Naked Banny.
    function assetIdsOf(
        address hook,
        uint256 nakedBannyId
    )
        public
        view
        returns (uint256 worldId, uint256[] memory outfitIds)
    {
        // Keep a reference to the outfit IDs currently attached to the Naked Banny.
        uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[nakedBannyId];

        // Keep a reference to the world ID currently attached to the Naked Banny.
        uint256 attachedWorldId = _attachedWorldIdOf[nakedBannyId];

        // Keep a reference to the owner of the Naked Banny.
        address ownerOfNakedBanny = IERC721(hook).ownerOf(nakedBannyId);

        // If the world is owned by the owner of the naked banny, return it.
        if (IERC721(hook).ownerOf(attachedWorldId) == ownerOfNakedBanny) worldId = attachedWorldId;

        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfAttachedOutfits = attachedOutfitIds.length;

        // Keep a reference to the attached outfit ID being iterated on.
        uint256 attachedOutfitId;

        // Keep a reference to a counter of the number of outfits being returned.
        uint256 counter;

        // Return the outfits owned by the Naked Banny's current owner.
        for (uint256 i; i < numberOfAttachedOutfits; i++) {
            // Set the outfit being iterated on.
            attachedOutfitId = attachedOutfitIds[i];

            // If the outfit is not owned by the owner of the naked banny, don't include it.
            if (IERC721(hook).ownerOf(attachedOutfitId) != ownerOfNakedBanny) continue;

            // Return the outfit.
            outfitIds[counter++] = attachedOutfitId;
        }
    }

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    function svgContentsOf(address hook, uint256 tierId) public view returns (string memory) {
        // Keep a reference to the stored scg contents.
        string memory svgContents = _svgContentsOf[tierId];

        if (bytes(svgContents).length != 0) return svgContents;

        return string.concat(
            '<g><image xlink:href="',
            JBIpfsDecoder.decode(
                svgBaseUri, IJB721TiersHook(hook).STORE().encodedIPFSUriOf(hook, tierId)
            ),
            '" width="400" height="400"/></g>'
        );
    }

    /// @notice Returns the SVG showing a dressed Naked Banny.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfits in its current world.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address hook, uint256 tokenId) external view returns (string memory tokenUri) {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory tier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, tokenId, false);

        // If the token's tier doesn't exist, return an empty uri.
        if (tier.id == 0) return "";

        // Compose the contents.
        string memory contents;

        // If this isn't a Naked Banny and there's an SVG available, return the asset SVG alone (or on a manakin banny).
        if (tier.category > NAKED_CATEGORY) {
            // Keep a reference to the SVG contents.
            string memory svgContents = svgContentsOf(hook, tier.id);

            // Layer the outfit SVG over the manekin Banny
            if (bytes(svgContents).length != 0) {
                // Start with the manekin SVG if we're not returning a world.
                if (tier.category != WORLD_CATEGORY) contents = _manekinBannySvg();
                // Add the asset.
                contents = string.concat(contents, svgContents);
                // Return the SVG.
                return _layeredSvg(contents);
            }

            // If the tier's category is greater than the last expected category, use the default base URI of the 721 contract. Otherwise use the SVG URI.
            string memory baseUri = tier.category > MISC_CATEGORY ? IJB721TiersHook(hook).baseURI() : svgBaseUri;

            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(
                baseUri, IJB721TiersHook(hook).STORE().encodedTierIPFSUriOf(hook, tokenId)
            );
        }

        uint256 worldId;
        uint256[] memory outfitIds;

        // Get a reference to each asset ID currently attached to the Naked Banny.
        try this.assetIdsOf(hook, tokenId) returns (uint256 _worldId, uint256[] memory _outfitIds) {
            worldId = _worldId;
            outfitIds = _outfitIds;
        } catch (bytes memory) {}

        // Add the world if needed.
        if (worldId != 0) contents = string.concat(contents, svgContentsOf(hook, worldId));

        // Start with the Naked Banny.
        contents = string.concat(contents, _nakedBannySvgOf(tier.id));

        // Get the outfit contents.
        string memory outfitContents = _outfitContentsFor({ hook: hook, nakedBannyTier: tier.id, outfitIds: outfitIds });

        // Add the outfit contents if there are any.
        if (bytes(outfitContents).length != 0) {
            contents = string.concat(contents, outfitContents);
        }

        // Return the SVG.
        return _layeredSvg(contents);
    }
    
    /// @param owner The owner allowed to add SVG files that correspond to tier IDs.
    constructor(address owner) Ownable(owner) {}

    /// @notice Dress your Naked Banny with outfits.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param hook The address of the hook storing the assets.
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
        if (IERC721(hook).ownerOf(nakedBannyId) != msg.sender) revert UNAUTHORIZED_NAKED_BANNY();

        // Add the world if needed.
        if (worldId != 0) {
            // Check if the owner matched.
            if (IERC721(hook).ownerOf(worldId) != msg.sender) revert UNAUTHORIZED_WORLD();

            // Get the world's tier.
            JB721Tier memory worldTier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, worldId, false);

            // Tier must exist
            if (worldTier.id == 0) revert UNRECOGNIZED_WORLD();

            // Store the world for the banny.
            _attachedWorldIdOf[nakedBannyId] = worldId;
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

        // Iterate through each outfit checking to see if the message sender owns them all.
        for (uint256 i; i < numberOfAssets; i++) {
            // Set the outfit ID being iterated on.
            outfitId = outfitIds[i];

            // Check if the owner matched.
            if (IERC721(hook).ownerOf(outfitId) != msg.sender) revert UNAUTHORIZED_OUTFIT();

            // Get the outfit's tier.
            outfitTier = IJB721TiersHook(hook).STORE().tierOfTokenId(hook, outfitId, false);

            // Tier must exist
            if (outfitTier.id == 0) revert UNRECOGNIZED_OUTFIT();

            // The tier's category must be a known category.
            if (outfitTier.category < LEGS_CATEGORY || outfitTier.category > MISC_CATEGORY) revert UNRECOGNIZED_CATEGORY();

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitTier.category <= lastAssetCategory) revert UNORDERED_CATEGORIES();

            // Keep a reference to the last outfit's category.
            lastAssetCategory = outfitTier.category;
        }

        // Store the outfits.
        _attachedOutfitIdsOf[nakedBannyId] = outfitIds;

        emit DecorateBanny(hook, nakedBannyId, worldId, outfitIds, msg.sender);
    } 

    /// @notice The owner of this contract can store SVG files for tier IDs.
    /// @param tierId The ID of the tier having an SVG stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element.
    function setSvgContentsOf(uint256 tierId, string calldata svgContents) external {
        // Make sure there isn't already contents for the specified tierId;
        if (bytes(_svgContentsOf[tierId]).length != 0) revert CONTENTS_ALREADY_STORED();

        // Get the stored svg hash for the tier.
        bytes32 svgHash = svgHashOf[tierId];

        // Make sure a hash exists.
        if (svgHash == bytes32(0)) revert HASH_NOT_FOUND();

        // Make sure the content matches the hash.
        if (keccak256(abi.encodePacked(svgContents)) != svgHash) revert CONTENTS_MISMATCH();

        // Store the svg contents.
        _svgContentsOf[tierId] = svgContents;

        emit SetSvgContents(tierId, svgHash, svgContents, msg.sender);
    }

    /// @notice Allows the owner of this contract to upload the hash of an svg file for a tierId.
    /// @dev This allows anyone to lazily upload the correct svg file.
    /// @param tierId The ID of the tier having an SVG hash stored.
    /// @param svgHash The svg hash being stored, not including the parent <svg></svg> element.
    function setSvgHashOf(uint256 tierId, bytes32 svgHash) external onlyOwner {
        // Make sure there isn't already contents for the specified tierId;
        if (svgHashOf[tierId] != bytes32(0)) revert HASH_ALREADY_STORED();

        // Store the svg contents.
        svgHashOf[tierId] = svgHash;

        emit SetSvgHash(tierId, svgHash, msg.sender);
    }

    /// @notice Allows the owner of this contract to specify the base of the domain hosting the SVG files.
    function setSvgBaseUriOf(string calldata baseUri) external onlyOwner {
        // Store the base URI.
        svgBaseUri = baseUri;

        emit SetSvgBaseUri(baseUri, msg.sender);
    }

    /// @notice Returns the standard dimension SVG containing dynamic contents and SVG metadata.
    /// @param contents The contents of the SVG
    function _layeredSvg(string memory contents) internal pure returns (string memory) {
        return string.concat(
            '<svg width="400" height="400" viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg"><style>.o{fill:#',
            OUTLINE_1,
            ";}.w{fill:#",
            WHITE,
            ";}></style>",
            contents,
            "</svg>"
        );
    }

    function _manekinBannySvg() internal pure returns (string memory) {
        return string.concat(
            "<style>.o{fill:",
            OUTLINE_2,
            ";}.b2{fill:none;}.b3{fill:none;}.b4{fill:none;}.a1{fill:none;}.a2{fill:none;}.a3{fill:none;}</style>",
            NAKED_BANNY
        );
        return string.concat(
            "<style>.o{fill:",
            OUTLINE_2,
            ";}.b1{fill:#",
            ORIGINAL_BODY_1,
            ";}.b2{fill:#",
            ORIGINAL_BODY_2,
            ";}.b3{fill:#",
            ORIGINAL_BODY_3,
            ";}.b4{fill:#",
            ORIGINAL_BODY_4,
            ";}.a1{fill:#",
            ORIGINAL_BODY_1,
            ";}.a2{fill:#",
            ORIGINAL_BODY_2,
            ";}.a3{fill:#",
            ORIGINAL_BODY_3,
            ";}</style>",
            NAKED_BANNY
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
            NAKED_BANNY
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
            return (
                ALIEN_BODY_1,
                ALIEN_BODY_2,
                ALIEN_BODY_3,
                ALIEN_BODY_4,
                ALIEN_ANTENNA_1,
                ALIEN_ANTENNA_2,
                ALIEN_ANTENNA_2
            );
        } else if (tier == PINK_TIER) {
            return (PINK_BODY_1, PINK_BODY_2, PINK_BODY_3, PINK_BODY_4, PINK_BODY_1, PINK_BODY_2, PINK_BODY_3);
        } else if (tier == ORANGE_TIER) {
            return (
                ORANGE_BODY_1, ORANGE_BODY_2, ORANGE_BODY_3, ORANGE_BODY_4, ORANGE_BODY_1, ORANGE_BODY_2, ORANGE_BODY_3
            );
        } else if (tier == ORIGINAL_TIER) {
            return (
                ORIGINAL_BODY_1,
                ORIGINAL_BODY_2,
                ORIGINAL_BODY_3,
                ORIGINAL_BODY_4,
                ORIGINAL_BODY_1,
                ORIGINAL_BODY_2,
                ORIGINAL_BODY_3
            );
        }

        revert UNRECOGNIZED_TIER();
    }

    /// @notice The SVG contents for a list of outfit IDs.
    /// @param hook The address of the hook storing the assets.
    /// @param nakedBannyTier The tier of the naked banny being dressed.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny.
    function _outfitContentsFor(address hook, uint256 nakedBannyTier, uint256[] memory outfitIds) internal view returns (string memory contents) {
        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfOutfits = outfitIds.length;

        // Keep a reference to the outfit ID being iterated on.
        uint256 outfitId;

        // Keep a reference to the category of the outfit being iterated on.
        uint256 category;

        // Keep a reference to if certain accessories have been added.
        bool hasLegs;
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
                category = MOUTH_CATEGORY + 1;
                outfitId = 0;
            }

            // Set default legs, necklace, and face if needed.
            if (category == LEGS_CATEGORY) {
                hasLegs = true;
            } else if (category > LEGS_CATEGORY && !hasLegs) {
                contents = string.concat(contents, DEFAULT_LEGS);
                hasLegs = true;
            }
            if (category == NECKLACE_CATEGORY) {
                hasNecklace = true;
            } else if (category > NECKLACE_CATEGORY && !hasNecklace) {
                contents = string.concat(contents, DEFAULT_NECKLACE);
                hasNecklace = true;
            }
            if (category == FACE_CATEGORY) {
                hasFace = true;
            } else if (category > FACE_CATEGORY && !hasFace) {
                if (category == EYES_CATEGORY) {
                    hasEyes = true;
                } else if (category > EYES_CATEGORY && !hasEyes) {
                    if (nakedBannyTier == ALIEN_TIER) contents = string.concat(contents, DEFAULT_ALIEN_EYES);
                    else contents = string.concat(contents, DEFAULT_STANDARD_EYES);
                    hasEyes = true;
                }
                if (category == MOUTH_CATEGORY) {
                    hasMouth = true;
                } else if (category > MOUTH_CATEGORY && !hasMouth) {
                    contents = string.concat(contents, DEFAULT_MOUTH);
                    hasMouth = true;
                }

                if (hasEyes && hasMouth && !hasFace) {
                    hasFace = true;
                }
            }

            // Add the outfit if needed.
            if (outfitId != 0) {
                contents = string.concat(contents, svgContentsOf(hook, outfitId));
            }
        }
    }
}
