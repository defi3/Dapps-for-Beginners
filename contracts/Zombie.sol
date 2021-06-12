/**
 *   Source: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 */
pragma solidity >=0.5.0 <0.6.0;

import "./token/ERC721/ERC721.sol";

contract Zombie is ERC721 {
    struct ZData {
        string name;
        uint dna;
    }
    
    ZData[] public zombies;
    
    event NewZombie(uint _tokenId, string name, uint dna);
}