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

    /// @notice SVG data of the naked Banny used to present wearables.
    /// TODO we prolly want this to be dynamic.
    string constant private _OUTLINE_BANNY = "";

    /// @notice The 721 hook that represents the Banny collection.
    IJB721TiersHook immutable HOOK;

    /// @notice The contract storing hook's tiers.
    IJB721TiersHookStore immutable STORE;

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param tierId The ID of the tier that the SVG contents represent.
    mapping(uint256 tierId => string) svgContentsOf;

    /// @notice The outfits currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be weating attached outfits currently owned by the owner of the Naked Banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny with outfits attached.
    mapping(uint256 nakedBannyId => uint256[]) internal _attachedOutfitIdsOf;

    /// @notice The outfits currently attached to each Naked Banny, owned by the naked Banny's owner.
    /// @param nakedBannyId The ID of the naked banny wearing the outfits.
    function outfitIdsOf(uint256 nakedBannyId) public view returns (uint256[] memory outfitIds) {

        // Keep a reference to the outfit IDs currently attached to the Naked Banny.        
        uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[nakedBannyId];

        // Keep a reference to the owner of the Naked Banny.
        address ownerOfNakedBanny = IERC721(address(HOOK)).ownerOf(nakedBannyId);

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
            if (IERC721(address(HOOK)).ownerOf(attachedOutfitId) != ownerOfNakedBanny) {
                continue;
            }

            // Return the outfit.
            outfitIds[counter++] = attachedOutfitId;
        }
    }

    /// @notice Returns the SVG showing a dressed Naked Banny.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfit.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address, uint256 tokenId) external view returns (string memory tokenUri) {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory outfitTier = STORE.tierOfTokenId(address(HOOK), tokenId, false);

        // If this isn't a naked Banny and there's an SVG available, return the outfit SVG alone (or on an OG banny).
        if (outfitTier.category > 0) {
            // Layer the outfit SVG over outline Banny
            if (bytes(svgContentsOf[outfitTier.id]).length != 0) {
                return _layeredSvg(
                    tokenId, string.concat("<g>", _OUTLINE_BANNY, "</g>", "<g>", svgContentsOf[outfitTier.id], "</g>")
                );
            }

            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(HOOK.baseURI(), STORE.encodedTierIPFSUriOf(address(HOOK), tokenId));
        }

        // Layer 0 is naked banny SVG. If background is supported asset, background will be layer 0 and layer 1 will be
        // naked banny.
        string memory svgContents = string.concat("<g>", svgContentsOf[tokenId], "</g>");

        // Get a reference to each outfit ID currently attached to the Naked Banny.
        uint256[] memory outfitIds = outfitIdsOf(tokenId);

        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfOutfits = outfitIds.length;

        // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        for (uint256 i; i < numberOfOutfits; i++) {
            // Add the svgOf[outfitTier.id] to the image being composed.
            svgContents = string.concat(svgContents, "<g>", svgContentsOf[outfitIds[i]], "</g>");
        }

        return _layeredSvg(tokenId, svgContents);
    }

    /// @param hook The 721 hook that represents the Banny collection.
    /// @param owner The owner allowed to add SVG files that correspond to tier IDs.
    constructor(IJB721TiersHook hook, address owner) Ownable(owner) {
        HOOK = hook;
        STORE = hook.STORE();
    }

    /// @notice Dress your Naked Banny with outfits.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param outfitIds The IDs of the outfits that'll be worn. Only one outfit per outfit category allowed at a time
    /// and they must be passed in order.
    function dressBannyWith(uint256 nakedBannyId, uint256[] calldata outfitIds) external {
        // Make sure call is being made by owner of Naked Banny.
        if (IERC721(address(HOOK)).ownerOf(nakedBannyId) != msg.sender) {
            revert();
        }

        // Keep a reference to the number of outfits being worn.
        uint256 numberOfOutfits = outfitIds.length;

        // Keep a reference to the outfit being iterated on.
        uint256 outfitId;

        // Keep a reference to the category of the last outfit iterated on.
        uint256 lastOutfitCategory;

        // Keep a reference to the tier of the outfit being iterated on.
        JB721Tier memory outfitTier;

        // Iterate through each outfit checking to see if the message sender owns them all.
        for (uint256 i; i < numberOfOutfits; i++) {
            // Set the outfit ID being iterated on.
            outfitId = outfitIds[i];

            // Check if the owner matched.
            if (IERC721(address(HOOK)).ownerOf(outfitId) != msg.sender) {
                revert();
            }

            // Get the outfit's tier.
            outfitTier = STORE.tierOfTokenId(address(HOOK), outfitId, false);

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitTier.category <= lastOutfitCategory) revert();

            // Keep a reference to the last outfit's category.
            lastOutfitCategory = outfitTier.category;
        }

        // Store the outfits.
        _attachedOutfitIdsOf[nakedBannyId] = outfitIds;
    }

    /// @notice The owner of this contract can store SVG files for tier IDs.
    /// @param tierId The ID of the tier having an SVG stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element or the <g></g> element. (i.e. <path
    /// .../><path .../>)
    function setSvgContentsOf(uint256 tierId, string calldata svgContents) external onlyOwner {
        svgContentsOf[tierId] = svgContents;
    }

    /// @notice Returns the standard dimension SVG containing dynamic contents and SVG metadata.
    /// TODO placeholder. SVG metadata will change.
    function _layeredSvg(uint256 tokenId, string memory contents) internal pure returns (string memory) {
        return string.concat(
            "<svg width='400' height='400' viewbox='0 0 400 400' description='Token: ",
            tokenId.toString(),
            "'>",
            contents,
            "</svg>"
        );
    }
}
