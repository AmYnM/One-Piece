// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnePieceMint is VRFConsumerBaseV2Plus, ERC721, ERC721URIStorage {
    uint256 private s_tokenCounter;

    // URIs String for five One Piece characters    
    string[] internal characterTokenURIs = [
        "https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmNp4sHf4ccqPpqMBUCSG1CpFwFR4D6kgHesxc1mLs75am",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmPHaFt55PeidgCuXe2kaeRYmLaBUPE1Y7Kg4tDyzapZHy",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmP9pC9JuUpKcnjUk8GBXEWVTGvK3FTjXL91Q3MJ2rhA16",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmSnNXo5hxrFnpbyBeb7jY7jhkm5eyknaCXtr8muk31AHK",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmarkkgDuBUcnqksatPzU8uNS4o6LTbEtuK43P7Jyth9NH"
    ];

    // Local variables
    uint256 public s_subscriptionId;
    bytes32 private i_keyHash;
    uint32 private i_callbackGasLimit;
    uint16 private i_requestConfirmations = 3;
    uint32 private i_numWords = 1;

    // Add mappings
    mapping(uint256 => address) private requestIdToSender; // allows the contract to keep track of which address made a request
    mapping(address => uint256) private userCharacter; // enables the contract to associate each user with their selected character
    mapping(address => bool) public hasMinted; // prevents users from minting muliple NFTs with the same address
    mapping(address => uint256) public s_addressToCharacter; // allows users to query which character they received based on their address
    mapping(address => uint256) public userTokenID;
    // add events
    event NftRequested(uint256 requestId, address requester);
    event CharacterTraitDetermined(uint256 characterId);
    event NftMinted(uint256 characterId, address minter);

    // Constructor function
    constructor(
        address vrfCoordinatorV2Address,
        uint256 subscriptionId,
        bytes32 keyHash,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2Address) ERC721("OnePiece NFT", "OPN") {
        s_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
    }

    // Function to mint NFT
    function mintNFT(address recipient, uint256 characterId) internal {
        // Ensure the address has not been minted before
        require(!hasMinted[recipient], "You have already minted your house NFT");

        // Get the next available token ID
        uint256 tokenId = s_tokenCounter;

        // Mint the NFT and assign it to the recipient
        _safeMint(recipient, tokenId);

        // Set the token URI for the minted NFT based on the character ID
        _setTokenURI(tokenId, characterTokenURIs[characterId]);

        // Map the recipient's address to the character ID they received
        s_addressToCharacter[recipient] = characterId;
        userTokenID[recipient] = tokenId;

        // Increment the token counter for the next minting
        s_tokenCounter += 1;

        // Mark the recipient's address as having minted an NFT
        hasMinted[recipient] = true;

        // Emit the event to log the mintiing of the NFT
        emit NftMinted(characterId, recipient);
    }

    // Function to request NFT
    function requestNFT(uint256[5] memory answers) public {
        userCharacter[msg.sender] = determineCharacter(answers);

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: i_requestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: i_numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false
                    })
                )
            })
        );
        requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    // Create Fulfill Random Words
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        address nftOwner = requestIdToSender[requestId];
        uint256 traitBasedCharacterId = userCharacter[nftOwner];

        // Random Value
        uint256 randomValue = randomWords[0];
        uint256 randomCharacterId = (randomValue % 5);

        // Final character ID
        uint256 finalCharacterId = (traitBasedCharacterId + randomCharacterId) % 5;
        mintNFT(nftOwner, finalCharacterId);
    }

    // Create a function to determine the character
    function determineCharacter(uint256[5] memory answers) private returns (uint256) {
        // Initialize characterId variable to store the calculated character ID
        uint256 characterId = 0;

        // Loop through each answer provider in the answer array
        for (uint256 i = 0; i < 5; i++) {
            characterId += answers[i];
        }

        // Calculate the final character ID by taking the remainder when divided by 5 and adding 1
        characterId = (characterId % 5) + 1;

        // Emit an event to log the determination of the character traits
        emit CharacterTraitDetermined(characterId);

        // Return the final character ID
        return characterId;
    }

    // Ovverride the transfer functionality of ERC721 to make it soulbound
    // This function is called before every token transfer to enforce soulbinding
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        // Call the parent contract's implmentation of _beforeTokenTransfer
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        // Ensure that tokens are only transferred to or from the zero address
        require(from == address(0) || to == address(0), "Err! This is not allowed");
    }

    // Override the tokenURI function to ensure compatibility with ERC721URIStorage
    function tokenURI(uint256 tokenId)
        public 
        view 
        override(ERC721, ERC721URIStorage)
        returns (string memory) 
    {
        // Call the parent contract's implementation of tokenURI
        return super.tokenURI(tokenId);
    }

    // Override the supportInterface function to ensure compatibility with ERC721URIStorage
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        // Call the parent contract's implementatin of supportsInterface
        return super.supportsInterface(interfaceId);
    }

    // Override the _burn function to ensure compatibility with ERC721URIStorage
    function _burn(uint256 tokenId) internal 
        override(ERC721, ERC721URIStorage)
    {
        // Call the parent contract's implementation of _burn
        super._burn(tokenId);
    }
}