// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC721} from "@bananapus/721-hook/src/abstract/ERC721.sol";
import {IJB721TiersHook} from "@bananapus/721-hook/src/interfaces/IJB721TiersHook.sol";
import {IJB721TiersHookStore} from "@bananapus/721-hook/src/interfaces/IJB721TiersHookStore.sol";
import {IJB721TokenUriResolver} from "@bananapus/721-hook/src/interfaces/IJB721TokenUriResolver.sol";
import {JB721Tier} from "@bananapus/721-hook/src/structs/JB721Tier.sol";
import {JBIpfsDecoder} from "@bananapus/721-hook/src/libraries/JBIpfsDecoder.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "lib/base64/base64.sol";

import {IBanny721TokenUriResolver} from "./interfaces/IBanny721TokenUriResolver.sol";

/// @notice Banny asset manager. Stores and shows Naked Bannys in worlds with outfits on.
contract Banny721TokenUriResolver is
    Ownable,
    ERC2771Context,
    IJB721TokenUriResolver,
    IBanny721TokenUriResolver,
    IERC721Receiver
{
    using Strings for uint256;

    error Banny721TokenUriResolver_CantAccelerateTheLock();
    error Banny721TokenUriResolver_ContentsAlreadyStored();
    error Banny721TokenUriResolver_ContentsMismatch();
    error Banny721TokenUriResolver_HashAlreadyStored();
    error Banny721TokenUriResolver_HashNotFound();
    error Banny721TokenUriResolver_HeadAlreadyAdded();
    error Banny721TokenUriResolver_LockedNakedBanny();
    error Banny721TokenUriResolver_OutfitChangesLocked();
    error Banny721TokenUriResolver_SuitAlreadyAdded();
    error Banny721TokenUriResolver_UnauthorizedNakedBanny();
    error Banny721TokenUriResolver_UnauthorizedOutfit();
    error Banny721TokenUriResolver_UnauthorizedWorld();
    error Banny721TokenUriResolver_UnorderedCategories();
    error Banny721TokenUriResolver_UnrecognizedCategory();
    error Banny721TokenUriResolver_UnrecognizedWorld();
    error Banny721TokenUriResolver_UnrecognizedProduct();
    error Banny721TokenUriResolver_UnauthorizedTransfer();

    //*********************************************************************//
    // ------------------------ private constants ------------------------ //
    //*********************************************************************//

    /// @notice Just a kind reminder to our readers.
    /// @dev Used in 721 token ID generation.
    uint256 private constant _ONE_BILLION = 1_000_000_000;

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

    //*********************************************************************//
    // --------------------- public stored properties -------------------- //
    //*********************************************************************//

    /// @notice The amount of time each naked banny is currently locked for.
    /// @custom:param hook The hook address of the collection.
    /// @custom:param owner The owner of the naked banny.
    /// @custom:param nakedBannyId The ID of the Naked Banny to lock.
    mapping(address hook => mapping(address owner => mapping(uint256 upc => uint256))) public override outfitLockedUntil;

    /// @notice The base of the domain hosting the SVG files that can be lazily uploaded to the contract.
    string public override svgBaseUri;

    /// @notice The Naked Banny and outfit SVG hash files.
    /// @custom:param upc The universal product code that the SVG hash represent.
    mapping(uint256 upc => bytes32) public override svgHashOf;

    string public override DEFAULT_ALIEN_EYES;
    string public override DEFAULT_MOUTH;
    string public override DEFAULT_NECKLACE;
    string public override DEFAULT_STANDARD_EYES;
    string public override NAKED_BANNY;

    //*********************************************************************//
    // --------------------- internal stored properties ------------------ //
    //*********************************************************************//

    /// @notice The outfits currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with outfits currently owned by the owner of the Naked Banny.
    /// @custom:param hook The hook address of the collection.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the outfits.
    mapping(address hook => mapping(uint256 nakedBannyId => uint256[])) internal _attachedOutfitIdsOf;

    /// @notice The world currently attached to each Naked Banny.
    /// @dev Nakes Banny's will only be shown with a world currently owned by the owner of the Naked Banny.
    /// @custom:param hook The hook address of the collection.
    /// @custom:param nakedBannyId The ID of the Naked Banny of the world.
    mapping(address hook => mapping(uint256 nakedBannyId => uint256)) internal _attachedWorldIdOf;

    /// @notice The name of each product.
    /// @custom:param upc The universal product code that the name belongs to.
    mapping(uint256 upc => string) internal _customProductNameOf;

    /// @notice The Naked Banny and outfit SVG files.
    /// @custom:param upc The universal product code that the SVG contents represent.
    mapping(uint256 upc => string) internal _svgContentOf;

    /// @notice The ID of the naked banny each world is being used by.
    /// @custom:param hook The hook address of the collection.
    /// @custom:param worldId The ID of the world.
    mapping(address hook => mapping(uint256 worldId => uint256)) internal _userOf;

    /// @notice The ID of the naked banny each outfit is being worn by.
    /// @custom:param hook The hook address of the collection.
    /// @custom:param outfitId The ID of the outfit.
    mapping(address hook => mapping(uint256 outfitId => uint256)) internal _wearerOf;

    //*********************************************************************//
    // -------------------------- constructor ---------------------------- //
    //*********************************************************************//

    /// @param nakedBanny The SVG of the naked banny.
    /// @param defaultNecklace The SVG of the default necklace.
    /// @param defaultMouth The SVG of the default mouth.
    /// @param defaultStandardEyes The SVG of the default standard eyes.
    /// @param defaultAlienEyes The SVG of the default alien eyes.
    /// @param owner The owner allowed to add SVG files that correspond to product IDs.
    /// @param trustedForwarder The trusted forwarder for the ERC2771Context.
    constructor(
        string memory nakedBanny,
        string memory defaultNecklace,
        string memory defaultMouth,
        string memory defaultStandardEyes,
        string memory defaultAlienEyes,
        address owner,
        address trustedForwarder
    )
        Ownable(owner)
        ERC2771Context(trustedForwarder)
    {
        NAKED_BANNY = nakedBanny;
        DEFAULT_NECKLACE = defaultNecklace;
        DEFAULT_MOUTH = defaultMouth;
        DEFAULT_STANDARD_EYES = defaultStandardEyes;
        DEFAULT_ALIEN_EYES = defaultAlienEyes;
    }

    //*********************************************************************//
    // ------------------------- external views -------------------------- //
    //*********************************************************************//

    /// @notice Returns the SVG showing a dressed Naked Banny in a world.
    /// @param tokenId The ID of the token to show. If the ID belongs to a Naked Banny, it will be shown with its
    /// current outfits in its current world.
    /// @return tokenUri The URI representing the SVG.
    function tokenUriOf(address hook, uint256 tokenId) external view override returns (string memory) {
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = _productOfTokenId(hook, tokenId);

        // If the token's product ID doesn't exist, return an empty uri.
        if (product.id == 0) return "";

        string memory contents;

        string memory extraMetadata = "";

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

            // If the world or outfit is attached to a naked banny, add it to the metadata.
            if (product.category == _WORLD_CATEGORY) {
                uint256 nakedBannyId = userOf(hook, tokenId);
                extraMetadata = string.concat('"usedByNakedBannyId": ', nakedBannyId.toString(), ",");
            } else {
                uint256 nakedBannyId = wearerOf(hook, tokenId);
                extraMetadata = string.concat('"wornByNakedBannyId": ', nakedBannyId.toString(), ",");
            }
        } else {
            // Compose the contents.
            contents =
                svgOf({hook: hook, tokenId: tokenId, shouldDressNakedBanny: true, shouldIncludeWorldOnNakedBanny: true});

            // Get a reference to each asset ID currently attached to the Naked Banny.
            (uint256 worldId, uint256[] memory outfitIds) = assetIdsOf(hook, tokenId);

            // Keep a reference to the number of outfits
            uint256 numberOfOutfits = outfitIds.length;

            extraMetadata = '"outfitIds": [';

            for (uint256 i; i < numberOfOutfits; i++) {
                extraMetadata = string.concat(extraMetadata, outfitIds[i].toString(), ",");
            }

            extraMetadata = string.concat(extraMetadata, "],");

            if (worldId != 0) extraMetadata = string.concat(extraMetadata, '"worldId": ', worldId.toString(), ",");

            // If the token has an owner, check if the owner has locked the token.
            try IERC721(hook).ownerOf(tokenId) returns (address owner) {
                uint256 lockedUntil = outfitLockedUntil[owner][hook][tokenId];
                if (lockedUntil > block.timestamp) {
                    extraMetadata =
                        string.concat(extraMetadata, '"decorationsLockedUntil": ', lockedUntil.toString(), ",");
                }
            } catch {}
        }

        if (bytes(contents).length == 0) {
            // If the product's category is greater than the last expected category, use the default base URI of the 721
            // contract. Otherwise use the SVG URI.
            string memory baseUri = product.category > _TOPPING_CATEGORY ? IJB721TiersHook(hook).baseURI() : svgBaseUri;

            // Fallback to returning an IPFS hash if present.
            return JBIpfsDecoder.decode(baseUri, _storeOf(hook).encodedTierIPFSUriOf(hook, tokenId));
        }

        // Get a reference to the pricing context.
        // slither-disable-next-line unused-return
        (uint256 currency, uint256 decimals,) = IJB721TiersHook(hook).pricingContext();

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
                    '", "tokenId": ',
                    tokenId.toString(),
                    ', "upc": ',
                    uint256(product.id).toString(),
                    ', "category": ',
                    uint256(product.category).toString(),
                    ', "supply": ',
                    uint256(product.initialSupply).toString(),
                    ', "remaining": ',
                    uint256(product.remainingSupply).toString(),
                    ', "price": ',
                    uint256(product.price).toString(),
                    ', "decimals": ',
                    decimals.toString(),
                    ', "currency": ',
                    currency.toString(),
                    ", ",
                    extraMetadata,
                    '"description":"A piece of the Bannyverse","image":"data:image/svg+xml;base64,',
                    Base64.encode(abi.encodePacked(contents)),
                    '"}'
                )
            )
        );
    }

    //*********************************************************************//
    // -------------------------- public views --------------------------- //
    //*********************************************************************//

    /// @notice The assets currently attached to each Naked Banny.
    /// @custom:param hook The hook address of the collection.
    /// @param nakedBannyId The ID of the naked banny shows with the associated assets.
    /// @return worldId The world attached to the Naked Banny.
    /// @return outfitIds The outfits attached to the Naked Banny.
    function assetIdsOf(
        address hook,
        uint256 nakedBannyId
    )
        public
        view
        override
        returns (uint256 worldId, uint256[] memory outfitIds)
    {
        // Keep a reference to the outfit IDs currently stored as attached to the Naked Banny.
        uint256[] memory storedOutfitIds = _attachedOutfitIdsOf[hook][nakedBannyId];

        // Keep a reference to the number of outfit IDs currently attached.
        uint256 numberOfStoredOutfitIds = storedOutfitIds.length;

        // Initiate the outfit IDs array with the same number of entries.
        outfitIds = new uint256[](numberOfStoredOutfitIds);

        // Keep a reference to the number of included outfits.
        uint256 numberOfIncludedOutfits = 0;

        // Keep a reference to the stored outfit ID being iterated on.
        uint256 storedOutfitId;

        // Return the outfit's that are still being worn by the naked banny.
        for (uint256 i; i < numberOfStoredOutfitIds; i++) {
            // Set the stored outfit ID being iterated on.
            storedOutfitId = storedOutfitIds[i];

            // If the stored outfit is still being worn, return it.
            if (wearerOf(hook, storedOutfitId) == nakedBannyId) outfitIds[numberOfIncludedOutfits++] = storedOutfitId;
        }

        // Keep a reference to the world currently stored as attached to the naked Banny.
        uint256 storedWorldOf = _attachedWorldIdOf[hook][nakedBannyId];

        // If the world is still being used, return it.
        if (userOf(hook, storedWorldOf) == nakedBannyId) worldId = storedWorldOf;
    }

    /// @notice Returns the name of the token.
    /// @param hook The hook storing the assets.
    /// @param tokenId The ID of the token to show.
    /// @return fullName The full name of the token.
    /// @return categoryName The name of the token's category.
    /// @return productName The name of the token's product.
    function namesOf(
        address hook,
        uint256 tokenId
    )
        public
        view
        override
        returns (string memory, string memory, string memory)
    {
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = _productOfTokenId(hook, tokenId);

        return (_fullNameOf(tokenId, product), _categoryNameOf(product.category), _productNameOf(tokenId));
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
        override
        returns (string memory)
    {
        // Get a reference to the product for the given token ID.
        JB721Tier memory product = _productOfTokenId(hook, tokenId);

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
        (uint256 worldId, uint256[] memory outfitIds) = assetIdsOf(hook, tokenId);

        // Add the world if needed.
        if (worldId != 0 && shouldIncludeWorldOnNakedBanny) contents = string.concat(contents, _svgOf(hook, worldId));

        // Start with the Naked Banny.
        contents = string.concat(contents, _nakedBannySvgOf(product.id));

        // Add eyes.
        if (product.id == ALIEN_UPC) contents = string.concat(contents, DEFAULT_ALIEN_EYES);
        else contents = string.concat(contents, DEFAULT_STANDARD_EYES);

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

    /// @notice Checks to see which naked banny is currently using a particular world.
    /// @param hook The hook address of the collection.
    /// @param worldId The ID of the world being used.
    /// @return The ID of the naked banny using the world.
    function userOf(address hook, uint256 worldId) public view override returns (uint256) {
        // Get a reference to the naked banny using the world.
        uint256 nakedBannyId = _userOf[hook][worldId];

        // If no naked banny is wearing the outfit, or if its no longer the world attached, return 0.
        if (nakedBannyId == 0 || _attachedWorldIdOf[hook][nakedBannyId] != worldId) return 0;

        // Return the naked banny ID.
        return nakedBannyId;
    }

    /// @notice Checks to see which naked banny is currently wearing a particular outfit.
    /// @param hook The hook address of the collection.
    /// @param outfitId The ID of the outfit being worn.
    /// @return The ID of the naked banny wearing the outfit.
    function wearerOf(address hook, uint256 outfitId) public view override returns (uint256) {
        // Get a reference to the naked banny wearing the outfit.
        uint256 nakedBannyId = _wearerOf[hook][outfitId];

        // If no naked banny is wearing the outfit, return 0.
        if (nakedBannyId == 0) return 0;

        // Keep a reference to the outfit IDs currently attached to a naked banny.
        uint256[] memory attachedOutfitIds = _attachedOutfitIdsOf[hook][nakedBannyId];

        // Keep a reference to the number of outfit IDs currently attached.
        uint256 numberOfAttachedOutfitIds = attachedOutfitIds.length;
        for (uint256 i; i < numberOfAttachedOutfitIds; i++) {
            // If the outfit is still attached, return the naked banny ID.
            if (attachedOutfitIds[i] == outfitId) return nakedBannyId;
        }

        // If the outfit is no longer attached, return 0.
        return 0;
    }

    //*********************************************************************//
    // -------------------------- internal views ------------------------- //
    //*********************************************************************//

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

    /// @dev ERC-2771 specifies the context as being a single address (20 bytes).
    function _contextSuffixLength() internal view virtual override(ERC2771Context, Context) returns (uint256) {
        return super._contextSuffixLength();
    }

    /// @notice Make sure the message sender own's the token.
    /// @param hook The 721 contract of the token having ownership checked.
    /// @param upc The product's UPC to check ownership of.
    function _checkIfSenderIsOwner(address hook, uint256 upc) internal view {
        if (IERC721(hook).ownerOf(upc) != _msgSender()) revert Banny721TokenUriResolver_UnauthorizedNakedBanny();
    }

    /// @notice The fills for a product.
    /// @param upc The ID of the token whose product's fills are being returned.
    /// @return fills The fills for the product.
    function _fillsFor(
        uint256 upc
    )
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

        revert Banny721TokenUriResolver_UnrecognizedProduct();
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

        string memory remainingString = " remaining";

        // If there's a raw token id, append it to the name before appending it to the category.
        if (rawTokenId != 0) {
            name = string.concat(name, rawTokenId.toString(), "/", uint256(product.initialSupply).toString());
        } else if (product.remainingSupply == 0) {
            name = string.concat(
                name,
                " (SOLD OUT) ",
                uint256(product.remainingSupply).toString(),
                "/",
                uint256(product.initialSupply).toString(),
                remainingString
            );
        } else {
            name = string.concat(
                name,
                uint256(product.remainingSupply).toString(),
                "/",
                uint256(product.initialSupply).toString(),
                remainingString
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
        name = string.concat(name, "UPC #", uint256(product.id).toString());
    }

    /// @notice Returns the standard dimension SVG containing dynamic contents and SVG metadata.
    /// @param contents The contents of the SVG
    /// @return svg The SVG contents.
    function _layeredSvg(string memory contents) internal pure returns (string memory) {
        return string.concat(
            '<svg width="400" height="400" viewBox="0 0 400 400" fill="white" xmlns="http://www.w3.org/2000/svg"><style>.o{fill:#050505;}.w{fill:#f9f9f9;}</style>',
            contents,
            "</svg>"
        );
    }

    /// @notice The SVG contents for a mannequin banny.
    /// @return contents The SVG contents of the mannequin banny.
    function _mannequinBannySvg() internal view returns (string memory) {
        string memory fillNoneString = string.concat("{fill:none;}");
        return string.concat(
            "<style>.o{fill:#808080;}.b2",
            fillNoneString,
            ".b3",
            fillNoneString,
            ".b4",
            fillNoneString,
            ".a1",
            fillNoneString,
            ".a2",
            fillNoneString,
            ".a3",
            fillNoneString,
            "</style>",
            NAKED_BANNY
        );
    }

    /// @notice Returns the calldata, prefered to use over `msg.data`
    /// @return calldata the `msg.data` of this call
    function _msgData() internal view override(ERC2771Context, Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    /// @notice Returns the sender, prefered to use over `msg.sender`
    /// @return sender the sender address of this call.
    function _msgSender() internal view override(ERC2771Context, Context) returns (address sender) {
        return ERC2771Context._msgSender();
    }

    /// @notice The SVG contents for a naked banny.
    /// @param upc The ID of the token whose product's SVG is being returned.
    /// @return contents The SVG contents of the naked banny.
    function _nakedBannySvgOf(uint256 upc) internal view returns (string memory) {
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
            NAKED_BANNY
        );
    }

    /// @notice The SVG contents for a list of outfit IDs.
    /// @param hook The 721 contract that the product belongs to.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny.
    /// @return contents The SVG contents of the outfits.
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

        // Keep a reference to if certain accessories have been added.
        bool hasNecklace;
        bool hasMouth;

        // Keep a reference to the custom necklace. Needed because the custom necklace is layered differently than the
        // default.
        string memory customNecklace;

        // Loop once more to make sure all default outfits are added.
        uint256 numberOfIterations = numberOfOutfits + 1;

        // For each outfit, add the SVG layer if it's owned by the same owner as the Naked Banny being dressed.
        for (uint256 i; i < numberOfIterations; i++) {
            // Keep a reference to the outfit ID being iterated on.
            uint256 outfitId;

            // Keep a reference to the category of the outfit being iterated on.
            uint256 category;

            // If the outfit is within the bounds of the number of outfits there are, add it normally.
            if (i < numberOfOutfits) {
                // Set the outfit ID being iterated on.
                outfitId = outfitIds[i];

                // Set the category of the outfit being iterated on.
                category = _productOfTokenId(hook, outfitId).category;
            } else {
                // Set the category to be more than all other categories to force adding defaults.
                category = _TOPPING_CATEGORY + 1;
                outfitId = 0;
            }

            if (category == _NECKLACE_CATEGORY) {
                hasNecklace = true;
                customNecklace = _svgOf(hook, outfitId);
            } else if (category > _NECKLACE_CATEGORY && !hasNecklace) {
                contents = string.concat(contents, DEFAULT_NECKLACE);
                hasNecklace = true;
            }

            if (category == _MOUTH_CATEGORY) {
                hasMouth = true;
            } else if (category > _MOUTH_CATEGORY && !hasMouth) {
                contents = string.concat(contents, DEFAULT_MOUTH);
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

    /// @notice Get the product of the 721 with the provided token ID in the provided 721 contract.
    /// @param hook The 721 contract that the product belongs to.
    /// @param tokenId The token ID of the 721 to get the product of.
    /// @return product The product.
    function _productOfTokenId(address hook, uint256 tokenId) internal view returns (JB721Tier memory) {
        return _storeOf(hook).tierOfTokenId({hook: hook, tokenId: tokenId, includeResolvedUri: false});
    }

    /// @notice The store of the hook.
    /// @param hook The hook to get the store of.
    /// @return store The store of the hook.
    function _storeOf(address hook) internal view returns (IJB721TiersHookStore) {
        return IJB721TiersHook(hook).STORE();
    }

    /// @notice The Naked Banny and outfit SVG files.
    /// @param hook The 721 contract that the product belongs to.
    /// @param upc The universal product code of the product that the SVG contents represent.
    function _svgOf(address hook, uint256 upc) internal view returns (string memory) {
        // Keep a reference to the stored scg contents.
        string memory svgContents = _svgContentOf[upc];

        if (bytes(svgContents).length != 0) return svgContents;

        return string.concat(
            '<image href="',
            JBIpfsDecoder.decode(svgBaseUri, _storeOf(hook).encodedIPFSUriOf(hook, upc)),
            '" width="400" height="400"/>'
        );
    }

    //*********************************************************************//
    // ---------------------- external transactions ---------------------- //
    //*********************************************************************//

    /// @notice Dress your Naked Banny with outfits.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param hook The hook storing the assets.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param worldId The ID of the world that'll be associated with the specified banny.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny. Only one outfit per
    /// outfit category allowed at a time and they must be passed in order.
    function decorateBannyWith(
        address hook,
        uint256 nakedBannyId,
        uint256 worldId,
        uint256[] calldata outfitIds
    )
        external
        override
    {
        _checkIfSenderIsOwner({hook: hook, upc: nakedBannyId});

        // Can't decorate a banny that's locked.
        if (outfitLockedUntil[_msgSender()][hook][nakedBannyId] > block.timestamp) {
            revert Banny721TokenUriResolver_OutfitChangesLocked();
        }

        emit DecorateBanny(hook, nakedBannyId, worldId, outfitIds, _msgSender());

        // Add the world.
        _decorateBannyWithWorld(hook, nakedBannyId, worldId);

        // Add the outfits.
        _decorateBannyWithOutfits(hook, nakedBannyId, outfitIds);
    }

    /// @notice Locks a naked banny ID so that it can't change its outfit for a period of time.
    /// @param hook The hook address of the collection.
    /// @param nakedBannyId The ID of the Naked Banny to lock.
    /// @param duration The amount of seconds to lock the naked banny for.
    function lockOutfitChangesFor(address hook, uint256 nakedBannyId, uint256 duration) public override {
        // Make sure only the naked banny's owner can lock it.
        _checkIfSenderIsOwner(hook, nakedBannyId);

        // Keep a reference to the current lock.
        uint256 currentLockedUntil = outfitLockedUntil[_msgSender()][hook][nakedBannyId];

        // Calculate the new time at which the lock will expire.
        uint256 newLockUntil = block.timestamp + duration;

        // Make sure the new lock is at least as big as the current lock.
        if (currentLockedUntil > newLockUntil) revert Banny721TokenUriResolver_CantAccelerateTheLock();

        // Set the lock.
        outfitLockedUntil[_msgSender()][hook][nakedBannyId] = newLockUntil;
    }

    /// @dev Make sure tokens can be receieved if the transaction was initiated by this contract.
    /// @param operator The address that initiated the transaction.
    /// @param from The address that initiated the transfer.
    /// @param tokenId The ID of the token being transferred.
    /// @param data The data of the transfer.
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        view
        override
        returns (bytes4)
    {
        from; // unused.
        tokenId; // unused.
        data; // unused.

        // Make sure the transaction's operator is this contract.
        if (operator != address(this)) revert Banny721TokenUriResolver_UnauthorizedTransfer();

        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Allows the owner to set the product's name.
    /// @param upcs The universal product codes of the products having their name stored.
    /// @param names The names of the products.
    function setProductNames(uint256[] memory upcs, string[] memory names) external override onlyOwner {
        uint256 numberOfProducts = upcs.length;

        for (uint256 i; i < numberOfProducts; i++) {
            uint256 upc = upcs[i];
            string memory name = names[i];

            _customProductNameOf[upc] = name;

            emit SetProductName(upc, name, msg.sender);
        }
    }

    /// @notice Allows the owner of this contract to specify the base of the domain hosting the SVG files.
    /// @param baseUri The base URI of the SVG files.
    function setSvgBaseUri(string calldata baseUri) external override onlyOwner {
        // Store the base URI.
        svgBaseUri = baseUri;

        emit SetSvgBaseUri(baseUri, msg.sender);
    }

    /// @notice The owner of this contract can store SVG files for product IDs.
    /// @param upcs The universal product codes of the products having SVGs stored.
    /// @param svgContents The svg contents being stored, not including the parent <svg></svg> element.
    function setSvgContentsOf(uint256[] memory upcs, string[] calldata svgContents) external override {
        uint256 numberOfProducts = upcs.length;

        for (uint256 i; i < numberOfProducts; i++) {
            uint256 upc = upcs[i];
            string memory svgContent = svgContents[i];

            // Make sure there isn't already contents for the specified universal product code.
            if (bytes(_svgContentOf[upc]).length != 0) revert Banny721TokenUriResolver_ContentsAlreadyStored();

            // Get the stored svg hash for the product.
            bytes32 svgHash = svgHashOf[upc];

            // Make sure a hash exists.
            if (svgHash == bytes32(0)) revert Banny721TokenUriResolver_HashNotFound();

            // Make sure the content matches the hash.
            if (keccak256(abi.encodePacked(svgContent)) != svgHash) revert Banny721TokenUriResolver_ContentsMismatch();

            // Store the svg contents.
            _svgContentOf[upc] = svgContent;

            emit SetSvgContent(upc, svgContent, msg.sender);
        }
    }

    /// @notice Allows the owner of this contract to upload the hash of an svg file for a universal product code.
    /// @dev This allows anyone to lazily upload the correct svg file.
    /// @param upcs The universal product codes of the products having SVG hashes stored.
    /// @param svgHashs The svg hashes being stored, not including the parent <svg></svg> element.
    function setSvgHashsOf(uint256[] memory upcs, bytes32[] memory svgHashs) external override onlyOwner {
        uint256 numberOfProducts = upcs.length;

        for (uint256 i; i < numberOfProducts; i++) {
            uint256 upc = upcs[i];
            bytes32 svgHash = svgHashs[i];

            // Make sure there isn't already contents for the specified universal product code.
            if (svgHashOf[upc] != bytes32(0)) revert Banny721TokenUriResolver_HashAlreadyStored();

            // Store the svg contents.
            svgHashOf[upc] = svgHash;

            emit SetSvgHash(upc, svgHash, msg.sender);
        }
    }

    //*********************************************************************//
    // ---------------------- internal transactions ---------------------- //
    //*********************************************************************//

    /// @notice Add outfits to a naked banny.
    /// @dev The caller must own the naked banny being dressed and all outfits being worn.
    /// @param hook The hook storing the assets.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param outfitIds The IDs of the outfits that'll be associated with the specified banny. Only one outfit per
    /// outfit category allowed at a time and they must be passed in order.
    function _decorateBannyWithOutfits(address hook, uint256 nakedBannyId, uint256[] memory outfitIds) internal {
        // Keep track of certain outfits being used along the way to prevent conflicting outfits.
        bool hasHead;
        bool hasSuit;

        // Keep a reference to the category of the last outfit iterated on.
        uint256 lastAssetCategory;

        // Keep a reference to the currently attached outfits on the naked banny.
        uint256[] memory previousOutfitIds = _attachedOutfitIdsOf[hook][nakedBannyId];

        // Keep a index counter that'll help with tracking progress.
        uint256 previousOutfitIndex;

        // Keep a reference to the previous outfit being iterated on when removing.
        uint256 previousOutfitId;

        // Get the outfit's product info.
        uint256 previousOutfitProductCategory;

        // Set the previous values if there are previous outfits.
        if (previousOutfitIds.length > 0) {
            previousOutfitId = previousOutfitIds[0];
            previousOutfitProductCategory = _productOfTokenId(hook, previousOutfitId).category;
        }

        // Keep a reference to the number of outfits.
        uint256 numberOfOutfits = outfitIds.length;

        // Iterate through each outfit, transfering them in and adding them to the banny if needed, while transfering
        // out and removing old outfits no longer being worn.
        for (uint256 i; i < numberOfOutfits; i++) {
            // Set the outfit ID being iterated on.
            uint256 outfitId = outfitIds[i];

            // Check if the call is being made either by the outfit's owner or the owner of the naked banny currently
            // wearing it.
            if (
                _msgSender() != IERC721(hook).ownerOf(outfitId)
                    && _msgSender() != IERC721(hook).ownerOf(wearerOf(hook, outfitId))
            ) {
                revert Banny721TokenUriResolver_UnauthorizedOutfit();
            }

            // Get the outfit's product info.
            uint256 outfitProductCategory = _productOfTokenId(hook, outfitId).category;

            // The product's category must be a known category.
            if (outfitProductCategory < _BACKSIDE_CATEGORY || outfitProductCategory > _TOPPING_CATEGORY) {
                revert Banny721TokenUriResolver_UnrecognizedCategory();
            }

            // Make sure the category is an increment of the previous outfit's category.
            if (i != 0 && outfitProductCategory <= lastAssetCategory) {
                revert Banny721TokenUriResolver_UnorderedCategories();
            }

            if (outfitProductCategory == _HEAD_CATEGORY) {
                hasHead = true;
            } else if (outfitProductCategory == _SUIT_CATEGORY) {
                hasSuit = true;
            } else if (
                (
                    outfitProductCategory == _GLASSES_CATEGORY || outfitProductCategory == _MOUTH_CATEGORY
                        || outfitProductCategory == _HEADTOP_CATEGORY
                ) && hasHead
            ) {
                revert Banny721TokenUriResolver_HeadAlreadyAdded();
            } else if (
                (outfitProductCategory == _SUIT_TOP_CATEGORY || outfitProductCategory == _SUIT_BOTTOM_CATEGORY)
                    && hasSuit
            ) {
                revert Banny721TokenUriResolver_SuitAlreadyAdded();
            }

            // Remove all previous assets up to and including the current category being iterated on.
            while (previousOutfitProductCategory <= outfitProductCategory && previousOutfitProductCategory != 0) {
                if (previousOutfitId != outfitId) {
                    // Transfer the previous outfit to the owner of the banny.
                    // slither-disable-next-line reentrancy-no-eth
                    _transferFrom({hook: hook, from: address(this), to: _msgSender(), assetId: previousOutfitId});
                }

                if (++previousOutfitIndex < previousOutfitIds.length) {
                    // set the next previous outfit.
                    previousOutfitId = previousOutfitIds[previousOutfitIndex];
                    // Get the next previous outfit.
                    previousOutfitProductCategory = _productOfTokenId(hook, previousOutfitId).category;
                } else {
                    previousOutfitId = 0;
                    previousOutfitProductCategory = 0;
                }
            }

            // If the outfit is not already being worn by the banny, transfer it to this contract.
            if (wearerOf(hook, outfitId) != nakedBannyId) {
                // Store the banny that's in the world.
                _wearerOf[hook][outfitId] = nakedBannyId;

                // Transfer the outfit to this contract.
                // slither-disable-next-line reentrancy-no-eth
                _transferFrom({hook: hook, from: _msgSender(), to: address(this), assetId: outfitId});
            }

            // Keep a reference to the last outfit's category.
            lastAssetCategory = outfitProductCategory;
        }

        // Remove and transfer out any remaining assets no longer being worn.
        while (previousOutfitId != 0) {
            // Transfer the previous world to the owner of the banny.
            // slither-disable-next-line reentrancy-no-eth
            _transferFrom({hook: hook, from: address(this), to: _msgSender(), assetId: previousOutfitId});

            if (++previousOutfitIndex < previousOutfitIds.length) {
                // remove previous product.
                previousOutfitId = previousOutfitIds[previousOutfitIndex];
            } else {
                previousOutfitId = 0;
            }
        }

        // Store the outfits.
        _attachedOutfitIdsOf[hook][nakedBannyId] = outfitIds;
    }

    /// @notice Add a world to a Naked Banny.
    /// @param hook The hook storing the assets.
    /// @param nakedBannyId The ID of the Naked Banny being dressed.
    /// @param worldId The ID of the world that'll be associated with the specified banny.
    function _decorateBannyWithWorld(address hook, uint256 nakedBannyId, uint256 worldId) internal {
        // Keep a reference to the previous world attached.
        uint256 previousWorldId = _attachedWorldIdOf[hook][nakedBannyId];

        // If the world is changing, add the lateset world and transfer the old one back to the owner.
        if (worldId != previousWorldId) {
            // Add the world if needed.
            if (worldId != 0) {
                // Check if the call is being made by the world's owner, or the owner of a naked banny using it.
                if (
                    _msgSender() != IERC721(hook).ownerOf(worldId)
                        && _msgSender() != IERC721(hook).ownerOf(userOf(hook, worldId))
                ) {
                    revert Banny721TokenUriResolver_UnauthorizedWorld();
                }

                // Get the world's product info.
                JB721Tier memory worldProduct = _productOfTokenId(hook, worldId);

                // World must exist
                if (worldProduct.id == 0) revert Banny721TokenUriResolver_UnrecognizedWorld();

                // Store the world for the banny.
                _attachedWorldIdOf[hook][nakedBannyId] = worldId;

                // Store the banny that's in the world.
                _userOf[hook][worldId] = nakedBannyId;

                // Transfer the world to this contract.
                _transferFrom({hook: hook, from: _msgSender(), to: address(this), assetId: worldId});
            } else {
                _attachedWorldIdOf[hook][nakedBannyId] = 0;
            }

            // If there's a previous world, transfer it back to the owner.
            if (previousWorldId != 0) {
                // Transfer the previous world to the owner of the banny.
                _transferFrom({hook: hook, from: address(this), to: _msgSender(), assetId: previousWorldId});
            }
        }
    }

    /// @notice Transfer a token from one address to another.
    /// @param hook The 721 contract of the token being transfered.
    /// @param from The address to transfer the token from.
    /// @param to The address to transfer the token to.
    /// @param assetId The ID of the token to transfer.
    function _transferFrom(address hook, address from, address to, uint256 assetId) internal {
        IERC721(hook).safeTransferFrom({from: from, to: to, tokenId: assetId});
    }
}
