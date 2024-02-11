// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IJB721TokenUriResolver} from "lib/juice-721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {IERC721} from "lib/juice-721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHook} from "lib/juice-721-hook/src/interfaces/IJB721TiersHook.sol";
import {IJB721TiersHookStore} from "lib/juice-721-hook/src/interfaces/IJB721TiersHookStore.sol";
import {JB721Tier} from "lib/juice-721-hook/src/structs/JB721Tier.sol";
import {JBIpfsDecoder} from "lib/juice-721-hook/src/libraries/JBIpfsDecoder.sol";
// @notice Banny outfit manager. Stores and shows Naked Bannys with outfits on.
contract Banny721TokenUriResolver is IJB721TokenUriResolver, Ownable {
    using Strings for uint256;

    string public constant NAKED_BANNY = '<g class="f1"><path d="M173 53h4v17h-4zm40 200h-3v-3-3h-3v-7-3h-4v-10h-3v-7-7-3h-3v-73h-4v-10h-3v-10h-3v-7h-4v-7h-3v-3h-3v-3h-4v10h4v10h3v10h3v3h4v7 3 70 3h3v7h3v20h4v7h3v3h3v3h4v4h3v3h3v-3-4z"/><path d="M253 307v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-3h-3v-3h-4v-4h-3v-6h-3v-7h-4v17h4v3h3v3h3 4v4h3v3h3v3h4v4h3v3h3v3h4v4h3v3h3v3h4v-6h-4z"/></g><g class="f2"><path d="M250 310v-3h-3v-4h-4v-3h-3v-3h-3v-4h-4v-3h-3v-3h-3v-4h-7v-3h-3v-3h-4v-17h-3v-3h-3v-4h-4v-3h-3v-3h-3v-7h-4v-20h-3v-7h-3v-73-3-7h-4v-3h-3v-10h-3v-10h-4V53h-3v4h-3v10h3v40h-3v10h-4v6h-3v14h-3v3 13h-4v44h4v16h3v14h3v13h4v10h3v7h3v3h4v3h3v4h3v3h4v3h3v4h3v3h4v3h3v7h7v7h6v3h7v3h7v4h13v3h3v3h10v-3h-3zm-103-87v-16h3v-10h-3v6h-4v17h-3v10h3v-7h4z"/><path d="M143 230h4v7h-4zm4 10h3v3h-3zm3 7h3v3h-3zm3 6h4v4h-4z"/><path d="M163 257h-6v3h3v3h3v4h4v-4-3h-4v-3z"/></g><g class="f3"><path d="M167 53h3v4h-3z"/><path d="M163 57h4v10h-4z"/><path d="M167 67h3v3h-3zm-24 130v6h4v-6h6v-44h4v-16h3v-14h3v-6h4v-10h3V97h-7v6h-3v4h-3v3h-4v3h-3v4 3h-3v3 4h-4v10h-3v16 4h-3v46h3v-6h3z"/><path d="M140 203h3v17h-3z"/><path d="M137 220h3v10h-3z"/><path d="M153 250h-3v-7h-3v-6h-4v-7h-3v10h3v7h4v6h3v4h3v-7zm-3 10h3v7h-3z"/><path d="M147 257h3v3h-3zm6 0h4v3h-4z"/><path d="M160 263v-3h-3v3 7h6v-7h-3zm-10-56v16h-3v7h3v10h3v7h4v6h6v4h7v-4-3h-3v-10h-4v-13h-3v-14h-3v-16h-4v10h-3z"/><path d="M243 313v-3h-3v-3h-10-3v-4h-7v-3h-7v-3h-6v-7h-7v-7h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v-4h-3v-3h-4v-3h-3v10h-3v3h-4v3h-3v7h3v7h4v6h3v5h4v3h6v3h3v3h4 3v3h3 4v3h3 3v4h10v3h7 7 3v3h10 3v-3h10v-3h4v-4h-14z"/></g><g class="f4"><path d="M183 130h4v7h-4z"/><path d="M180 127h3v3h-3zm-27-4h4v7h-4z"/><path d="M157 117h3v6h-3z"/><path d="M160 110h3v7h-3z"/><path d="M163 107h4v3h-4zm-3 83h3v7h-3z"/><path d="M163 187h4v3h-4zm20 0h7v3h-7z"/><path d="M180 190h3v3h-3zm10-7h3v4h-3z"/><path d="M193 187h4v6h-4zm-20 53h4v7h-4z"/><path d="M177 247h3v6h-3z"/><path d="M180 253h3v7h-3z"/><path d="M183 260h7v3h-7z"/><path d="M190 263h3v4h-3zm0-20h3v4h-3z"/><path d="M187 240h3v3h-3z"/><path d="M190 237h3v3h-3zm13 23h4v3h-4z"/><path d="M207 263h3v7h-3z"/><path d="M210 270h3v3h-3zm-10 7h3v6h-3z"/><path d="M203 283h4v7h-4z"/><path d="M207 290h6v3h-6z"/></g><g style="fill: #050505;"><path d="M133 157h4v50h-4zm0 63h4v10h-4zm27-163h3v10h-3z"/><path d="M163 53h4v4h-4z"/><path d="M167 50h10v3h-10z"/><path d="M177 53h3v17h-3z"/><path d="M173 70h4v27h-4zm-6 0h3v27h-3z"/><path d="M163 67h4v3h-4zm0 30h4v3h-4z"/><path d="M160 100h3v3h-3z"/><path d="M157 103h3v4h-3z"/><path d="M153 107h4v3h-4z"/><path d="M150 110h3v3h-3z"/><path d="M147 113h3v7h-3z"/><path d="M143 120h4v7h-4z"/><path d="M140 127h3v10h-3z"/><path d="M137 137h3v20h-3zm56-10h4v10h-4z"/><path d="M190 117h3v10h-3z"/><path d="M187 110h3v7h-3z"/><path d="M183 103h4v7h-4z"/><path d="M180 100h3v3h-3z"/><path d="M177 97h3v3h-3zm-40 106h3v17h-3zm0 27h3v10h-3zm10 30h3v7h-3z"/><path d="M150 257v-4h-3v-6h-4v-7h-3v10h3v10h4v-3h3z"/><path d="M150 257h3v3h-3z"/><path d="M163 273v-3h-6v-10h-4v7h-3v3h3v3h4v7h3v-7h3z"/><path d="M163 267h4v3h-4z"/><path d="M170 257h-3-4v3h4v7h3v-10z"/><path d="M157 253h6v4h-6z"/><path d="M153 247h4v6h-4z"/><path d="M150 240h3v7h-3z"/><path d="M147 230h3v10h-3zm13 50h3v7h-3z"/><path d="M143 223h4v7h-4z"/><path d="M147 207h3v16h-3z"/><path d="M150 197h3v10h-3zm-10 0h3v6h-3zm50 113h7v3h-7zm23 10h17v3h-17z"/><path d="M230 323h13v4h-13z"/><path d="M243 320h10v3h-10z"/><path d="M253 317h4v3h-4z"/><path d="M257 307h3v10h-3z"/><path d="M253 303h4v4h-4z"/><path d="M250 300h3v3h-3z"/><path d="M247 297h3v3h-3z"/><path d="M243 293h4v4h-4z"/><path d="M240 290h3v3h-3z"/><path d="M237 287h3v3h-3z"/><path d="M233 283h4v4h-4z"/><path d="M230 280h3v3h-3z"/><path d="M227 277h3v3h-3z"/><path d="M223 273h4v4h-4z"/><path d="M220 267h3v6h-3z"/><path d="M217 260h3v7h-3z"/><path d="M213 253h4v7h-4z"/><path d="M210 247h3v6h-3z"/><path d="M207 237h3v10h-3z"/><path d="M203 227h4v10h-4zm-40 60h4v6h-4zm24 20h3v3h-3z"/><path d="M167 293h3v5h-3zm16 14h4v3h-4z"/><path d="M170 298h4v3h-4zm10 6h3v3h-3z"/><path d="M174 301h6v3h-6zm23 12h6v4h-6z"/><path d="M203 317h10v3h-10zm-2-107v-73h-4v73h3v17h3v-17h-2z"/></g>';
    string public constant DEFAULT_LEGS = '';
    string public constant DEFAULT_CHAIN = '';
    string public constant DEFAULT_STANDARD_FACE = '';
    string public constant DEFAULT_ALIEN_FACE = '';

    uint8 public constant NAKED_CATEGORY = 0;
    uint8 public constant WORLD_CATEGORY = 1;
    uint8 public constant LEGS_CATEGORY = 2;
    uint8 public constant NECK_CATEGORY = 3;
    uint8 public constant FACE_CATEGORY = 4;
    uint8 public constant HEADGEAR_CATEGORY = 5;
    uint8 public constant SUIT_CATEGORY = 6;
    uint8 public constant RIGHT_FIST_CATEGORY = 7;
    uint8 public constant LEFT_FIST_CATEGORY = 8;

    uint8 public constant ALIEN_TIER = 1;
    string public constant ALIEN_F1 = '67d757';
    string public constant ALIEN_F2 = '30a220';
    string public constant ALIEN_F3 = '217a15';
    string public constant ALIEN_F4 = 'none';

    uint8 public constant PINK_TIER = 2;
    string public constant PINK_F1 = 'ffd8c5';
    string public constant PINK_F2 = 'ff96a9';
    string public constant PINK_F3 = 'fe588b';
    string public constant PINK_F4 = 'c92f45';

    uint8 public constant ORANGE_TIER = 3;
    string public constant ORANGE_F1 = 'f3a603';
    string public constant ORANGE_F2 = 'ff7c02';
    string public constant ORANGE_F3 = 'fd3600';
    string public constant ORANGE_F4 = 'c32e0d';

    uint8 public constant ORIGINAL_TIER = 4;
    string public constant ORIGINAL_F1 = 'ffe900';
    string public constant ORIGINAL_F2 = 'ffc700';
    string public constant ORIGINAL_F3 = 'f3a603';
    string public constant ORIGINAL_F4 = '965a1a';

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    mapping(uint256 tierId => string) svgContentsOf;

    /// @notice The outfits currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be weating attached outfits currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny with outfits attached.
    mapping(uint256 nakedBannyId => uint256[]) internal _attachedOutfitIdsOf;

    // /// @notice The outfits currently attached to each Naked Banny, owned by the naked Banny's owner.
    // /// @param nakedBannyId The ID of the naked banny wearing the outfits.
    // function outfitIdsOf(uint256 nakedBannyId) public view returns (uint256[] memory outfitIds) {
    //     // Keep a reference to the outfit IDs currently attached to the Naked Banny.
    //     uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[nakedBannyId];

    //     // Keep a reference to the owner of the Naked Banny.
    //     address ownerOfNakedBanny = IERC721(address(HOOK)).ownerOf(nakedBannyId);

    //     // Get a reference to the number of outfits are on the Naked Banny.
    //     uint256 numberOfAttachedOutfits = attachedOutfitIds.length;

    //     // Keep a reference to the attached outfit ID being iterated on.
    //     uint256 attachedOutfitId;

    //     // Keep a reference to a counter of the number of outfits being returned.
    //     uint256 counter;

    //     // Return the outfits owned by the Naked Banny's current owner.
    //     for (uint256 i; i < numberOfAttachedOutfits; i++) {
    //         // Set the outfit being iterated on.
    //         attachedOutfitId = attachedOutfitIds[i];

    //         // If the outfit is not owned by the owner of the naked banny, don't include it.
    //         if (IERC721(address(HOOK)).ownerOf(attachedOutfitId) != ownerOfNakedBanny) {
    //             continue;
    //         }

    //         // Return the outfit.
    //         outfitIds[counter++] = attachedOutfitId;
    //     }
    // }

    /// @notice Returns the SVG showing a dressed Naked Banny.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfit.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address nft, uint256 tokenId) external view returns (string memory tokenUri) {
        // Get a reference to the tier for the given token ID.
        // JB721Tier memory tier = STORE.tierOfTokenId(address(HOOK), tokenId, false);
        uint256 tierId = IJB721TiersHook(nft).STORE().tierIdOfToken(tokenId);
        
        // If this isn't a naked Banny and there's an SVG available, return the outfit SVG alone (or on an OG banny).
        // if (tier.category > 0) {
        //     // Layer the outfit SVG over outline Banny
        //     if (bytes(svgContentsOf[outfitTier.id]).length != 0) {
        //         return _layeredSvg(
        //             string.concat("<g>", _OUTLINE_BANNY, "</g>", "<g>", svgContentsOf[outfitTier.id], "</g>")
        //         );
        //     }

        //     // Fallback to returning an IPFS hash if present.
        //     return JBIpfsDecoder.decode(HOOK.baseURI(), STORE.encodedTierIPFSUriOf(address(HOOK), tokenId));
        // }

        // Layer 0 is naked banny SVG. If background is supported asset, background will be layer 0 and layer 1 will be
        // naked banny.
        // string memory svgContents = string.concat("<g>", svgContentsOf[tokenId], "</g>");
        string memory nakedBannySvg = _nakedBannySvgOf(tierId); 

        return _layeredSvg(nakedBannySvg);

        // // Get a reference to each outfit ID currently attached to the Naked Banny.
        // uint256[] memory outfitIds = outfitIdsOf(tokenId);

        // // Get a reference to the number of outfits are on the Naked Banny.
        // uint256 numberOfOutfits = outfitIds.length;

        // // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        // for (uint256 i; i < numberOfOutfits; i++) {
        //     // Add the svgOf[outfitTier.id] to the image being composed.
        //     svgContents = string.concat(svgContents, "<g>", svgContentsOf[outfitIds[i]], "</g>");
        // }

        // return _layeredSvg(svgContents);
    }

    /// @param owner The owner allowed to add SVG files that correspond to tier IDs.
    constructor(address owner) Ownable(owner) {
    }

    // /// @notice Dress your Naked Banny with outfits.
    // /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    // /// @param nakedBannyId The ID of the Naked Banny being dressed.
    // /// @param outfitIds The IDs of the outfits that'll be worn. Only one outfit per outfit category allowed at a time
    // /// and they must be passed in order.
    // function dressBannyWith(uint256 nakedBannyId, uint256[] calldata outfitIds) external {
    //     // Make sure call is being made by owner of Naked Banny.
    //     if (IERC721(address(HOOK)).ownerOf(nakedBannyId) != msg.sender) {
    //         revert();
    //     }

    //     // Keep a reference to the number of outfits being worn.
    //     uint256 numberOfOutfits = outfitIds.length;

    //     // Keep a reference to the outfit being iterated on.
    //     uint256 outfitId;

    //     // Keep a reference to the category of the last outfit iterated on.
    //     uint256 lastOutfitCategory;

    //     // Keep a reference to the tier of the outfit being iterated on.
    //     JB721Tier memory outfitTier;

    //     // Iterate through each outfit checking to see if the message sender owns them all.
    //     for (uint256 i; i < numberOfOutfits; i++) {
    //         // Set the outfit ID being iterated on.
    //         outfitId = outfitIds[i];

    //         // Check if the owner matched.
    //         if (IERC721(address(HOOK)).ownerOf(outfitId) != msg.sender) {
    //             revert();
    //         }

    //         // Get the outfit's tier.
    //         outfitTier = STORE.tierOfTokenId(address(HOOK), outfitId, false);

    //         // Make sure the category is an increment of the previous outfit's category.
    //         if (i != 0 && outfitTier.category <= lastOutfitCategory) revert();

    //         // Keep a reference to the last outfit's category.
    //         lastOutfitCategory = outfitTier.category;
    //     }

    //     // Store the outfits.
    //     _attachedOutfitIdsOf[nakedBannyId] = outfitIds;
    // }

    /// @notice The owner of this contract can store SVG files for tier IDs.
    /// @param tierId The ID of the tier having an SVG stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element or the <g></g>
    /// element. (i.e. <path
    /// .../><path .../>)
    function setSvgContentsOf(uint256 tierId, string calldata svgContents) external onlyOwner {
        svgContentsOf[tierId] = svgContents;
    }

    /// @notice Returns the standard dimension SVG containing dynamic contents and SVG metadata.
    /// @param contents The contents of the SVG
    function _layeredSvg(string memory contents) internal pure returns (string memory) {
        return string.concat(
            '<svg width="400" height="400" viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg">',
            contents,
            "</svg>"
        );
    }

    function _nakedBannySvgOf(uint256 tier) internal pure returns (string memory) {
        (string memory f1, string memory f2, string memory f3, string memory f4) = _fillsFor(tier);
        return string.concat(
            '<style>.f1 { fill: #', f1, '; }.f2 { fill: #', f2, '; }.f3 { fill: #', f3, '; }.f4 { fill: #', f4, '; }</style>', NAKED_BANNY
        );
    }

    function _manekinBannySvgOf() internal pure returns (string memory) {
        return string.concat(
            '<style>.f1 { fill: none; }.f2 { fill: none; }.f3 { fill: none; }.f4 { fill: none; }</style>', NAKED_BANNY
        );
    }

    function _fillsFor(uint256 tier) internal pure returns (string memory, string memory, string memory, string memory) {
        if (tier == ALIEN_TIER) {
            return (ALIEN_F1, ALIEN_F2, ALIEN_F3, ALIEN_F4);
        } else if (tier == PINK_TIER) {
            return (PINK_F1, PINK_F2, PINK_F3, PINK_F4);
        } else if (tier == ORANGE_TIER) {
            return (ORANGE_F1, ORANGE_F2, ORANGE_F3, ORANGE_F4);
        } else if (tier == ORIGINAL_TIER) {
            return (ORIGINAL_F1, ORIGINAL_F2, ORIGINAL_F3, ORIGINAL_F4);
        } 

        revert();
    }
}
