// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IJB721TokenUriResolver} from "lib/juice-721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {IERC721} from "lib/juice-721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHook} from "lib/juice-721-hook/src/interfaces/IJB721TiersHook.sol";
import {IJB721TiersHookStore} from "lib/juice-721-hook/src/interfaces/IJB721TiersHookStore.sol";
import {JB721Tier} from "lib/juice-721-hook/src/structs/JB721Tier.sol";
import {JBIpfsDecoder} from "lib/juice-721-hook/src/libraries/JBIpfsDecoder.sol";

// @notice Banny outfit manager. Stores and shows Naked Bannys with outfits on.
contract Banny721TokenUriResolver is IJB721TokenUriResolver, Ownable {

    /// @notice The 721 hook that represents the Banny collection. 
    IJB721TiersHook immutable HOOK; 

    /// @notice The contract storing hook's tiers.
    IJB721TiersHookStore immutable STORE; 
    
    /// @notice The outfits currently attached to each Naked Banny.
    mapping(uint256 nakedBannyId => uint256[]) outfitIdsOf;
    
    /// @notice The Naked Banny and outfit SVG files.
    mapping(uint256 tierId => bytes) svgOf;

    /// @param hook The 721 hook that represents the Banny collection. 
    /// @param owner The owner allowed to add SVG files that correspond to tier IDs.
    constructor(IJB721TiersHook hook, address owner) Ownable(owner) {
        HOOK = hook;
        STORE = hook.STORE();
    }
    
    /// @notice Returns the SVG showing a dressed Naked Banny.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its current outfit.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address, uint256 tokenId) external view returns (string memory tokenUri) {
        // Get a reference to the tier for the given token ID.
        JB721Tier memory outfitTier = STORE.tierOfTokenId(address(HOOK), tokenId, false);

        // If this isn't a naked Banny and there's an SVG available, return the outfit SVG alone (or on an OG banny).        
        if (outfitTier.category > 0) {
            if (svgOf[outfitTier.id].length == 0) return ''; //svgOf[outfitTier.id];
            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(HOOK.baseURI(), STORE.encodedTierIPFSUriOf(address(HOOK), tokenId));
        } 

        // Keep a reference to the owner of the Naked Banny.
        address ownerOfNakedBanny = IERC721(address(HOOK)).ownerOf(tokenId);

        // Get a reference to each outfit ID currently attached to the Naked Banny.
        uint256[] memory outfitIds = outfitIdsOf[tokenId];

        // Get a reference to the number of outfits are on the Naked Banny.
        uint256 numberOfOutfits = outfitIds.length;

        // Keep a reference to the outfit being iterated on.
        uint256 outfitId;

        // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        for (uint256 i; i < numberOfOutfits; i++) {
            outfitId = outfitIds[i];
            if (IERC721(address(HOOK)).ownerOf(outfitId) != ownerOfNakedBanny) continue;
            // Add the svgOf[outfitTier.id] to the image being composed.
        }
    }
    
    /// @notice Dress your Naked Banny with outfits.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param outfitIds The IDs of the outfits that'll be worn. Only one outfit per outfit category allowed at a time and they must be passed in order.
    function dressBannyWith(uint256 nakedBannyId, uint256[] calldata outfitIds) external {
        // Make sure call is being made by owner of Naked Banny.
        if (IERC721(address(HOOK)).ownerOf(nakedBannyId) != msg.sender) revert();

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
            if (IERC721(address(HOOK)).ownerOf(outfitId) != msg.sender) revert();

            // Get the outfit's tier.
            outfitTier = STORE.tierOfTokenId(address(HOOK), outfitId, false);

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitTier.category <= lastOutfitCategory) revert();

            // Keep a reference to the last outfit's category. 
            lastOutfitCategory = outfitTier.category;
        }

        // Store the outfits.  
        outfitIdsOf[nakedBannyId] = outfitIds;
    }
    
    /// @notice The owner of this contract can store SVG files for tier IDs.
    /// @param tierId The ID of the tier having an SVG stored.
    /// @param svg The svg being stored.
    function setSvgFileOf(uint256 tierId, bytes calldata svg) external onlyOwner {
        svgOf[tierId] = svg;
    }
}