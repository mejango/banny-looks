// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IJB721TokenUriResolver} from "lib/juice-721-hook/src/interfaces/IJB721TokenUriResolver.sol";

contract Banny721TokenUriResolver is IJB721TokenUriResolver {

    function tokenUriOf(address nft, uint256 tokenId) external view returns (string memory tokenUri) {
        nft;
        tokenId;
        return '';
    }
}