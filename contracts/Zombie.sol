/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 *  
 *  Creation, 2021-06
 * 
 */
pragma solidity ^0.8.0;

import "./token/ERC721/ERC721.sol";

abstract contract Zombie is ERC721 {
    struct ZData {
        string name;
        uint dna;
    }
    
    ZData[] public zombies;
    
    event NewZombie(uint _tokenId, string name, uint dna);
}