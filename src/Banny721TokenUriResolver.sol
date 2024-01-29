// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IJB721TokenUriResolver} from "lib/juice-721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {IERC721} from "lib/juice-721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHookStore} from "lib/juice-721-hook/src/interfaces/IJB721TiersHookStore.sol";
import {JB721Tier} from "lib/juice-721-hook/src/structs/JB721Tier.sol";

contract Banny721TokenUriResolver is IJB721TokenUriResolver {

    IJB721TiersHookStore immutable STORE; 

    mapping(address nft => mapping(uint256 nakedBannyId => uint256[])) outfitIdsOf;
    
    constructor( IJB721TiersHookStore store) {
        STORE = store;
    }

    function tokenUriOf(address nft, uint256 tokenId) external pure returns (string memory tokenUri) {
        nft;
        tokenId;
        return '';
        // if the tokenId is a naked banny, lookup all the outfits the Banny is currently wearing, dress the banny svg in each outfit svg currently assigned.
        // else return the outfit svg.

        // dressBanny
    }

    function dressBanny(address nft, uint256 nakedBannyId, uint256[] calldata outfitIds) external {
        // Make sure call is being made by owner of nakedBanny.
        if (IERC721(nft).ownerOf(nakedBannyId) != msg.sender) revert();

        uint256 numberOfOutfits = outfitIds.length;
        uint256 outfitId;

        uint256 outfitCategory;
        uint256 lastOutfitCategory;
        JB721Tier memory outfitTier;

        // check to see if owner owns all accessories. only dress banny is owned outfits.
        for (uint256 i; i < numberOfOutfits; i++) {
            outfitId = outfitIds[i];
            if (IERC721(nft).ownerOf(outfitId) != msg.sender) revert();

            outfitTier = STORE.tierOfTokenId(nft, outfitId, false);
            outfitCategory = outfitTier.category;

            if (i != 0 && outfitCategory <= lastOutfitCategory) revert();

            lastOutfitCategory = outfitCategory;
        }

        // check to see if any outfits conflict.
        /*** 
            Face: Category 1
            Hat: Category 2
            Chain: Category 3
            Suit: Category 4
            Shoes: Categoryat 5
            Right hand object: Category 6
            Left hand object: Category 7
        */

        // Store the outfits.  
        outfitIdsOf[nft][nakedBannyId] = outfitIds;
    }
}