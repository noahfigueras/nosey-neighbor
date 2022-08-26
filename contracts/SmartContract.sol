/** 
 * Submitted for verification at Etherscan.io on YEAR-MONTH-DAY
*/
                                                                                                   
//                      :~7JJ?^.                              ...         ^7?JJ?!:         !BBBGP5J!  
//   .:~7JJYJJ7^.     !G&@@@@@@#P!   .^^.      .5BB? ^PGGBBBB####G.      ~@@@@@@@&J        B@@@@@@@@~ 
//  ~#@@@@@@@@@@#?   Y@@@#5?YB#@@@P .B@@#Y~    ~@@@B ?@@@@@@@@&&&G.      ^@@@&5@@@#       7@@@#77??!  
//  ~@@@@Y?77J#@@@J ^@@@#:    .G@@@! #@@@@@BJ: ~@@@B  :^:7@@@#:..         B@@@B@@@&5?^   .#@@@@@&#7   
//   P@@@?    ^&@@&.~@@@B      G@@@7 Y@@@@@@@&5J@@@B     :&@@&.           Y@@@@@@@@@@&!  ?@@@#PBBB!   
//   ~@@@&:    #@@@^.#@@@!   :5@@@B. ^@@@&75&@@@@@@B     .#@@@^           ~@@@@?~^5@@@P .#@@@!        
//    5@@@Y  :Y@@@B. !&@@@GPG&@@@P.   P@@@J :Y&@@@@#      G@@@!            G@@@P5G@@@&~ J@@@@##G5:    
//    :&@@&PB@@@@G^   :YB@@@@@#5~     ^@@@&^  :Y&@@P      P@@@?            !&@@@@@&BY:  ^PBB#&@@#^    
//     J@@@@@&BY~        :~!~^.        Y@@@5    :!~.      7&&&!             .^!7!~:         ..:^.     
//      7JJ7~:                      ... 7YJ^               .:.^7!!~^:                                 
//                      .~!^    ^JPB#&#P7^                   ~@@@@@@&#?                               
//           :YPJ~      5@@@~ :P@@@@&&@@@@B!    :?5PGGPJ^    P@@@GPG#&?          ?55!                 
//           Y@@@@BY^   G@@@7 G@@@5^.:!?#@@@~  J@@@@@@@@&.  ~@@@@PYJ!.          Y@@@G                 
//           !@@@@@@@G7 G@@@!:@@@#      Y@@@Y :@@@@J^^?J~   G@@@@@@@#.  ^PG5?~.!@@@&:                 
//           .#@@@G#@@@B#@@@!.&@@&.    :#@@@7  J@@@&GJ^    !@@@B^~77^   7@@@@@&&@@@!                  
//            ?@@@P.?B@@@@@@7 Y@@@G~^^J#@@@Y    ~YB@@@@5.  B@@@G!~^      .~?5B&@@@#.                  
//            .#@@@!  !B@@@@7  J&@@@@@@@@G!   J##5~^G@@@J :&@@@@@@@5          .P@@@5                  
//             7@@@#.   7GB5:   :75GBGPJ~     J@@@@G#@@@?  :!7?JY5Y^           .B@@@J                 
//              5&@B:                          :JB&@@&B?                        :#@@@7                
//               ::.                              :^^:                           :5GP^                
                                                                                                    
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NOSEY_NEIGHBOR is ERC721Enumerable, Ownable {
  using Strings for uint256;

  uint256 constant maxSupply = 1500;
  uint256 constant cost = 0.01 ether;

  uint256 public maxMintAmount = 3;
  uint256 public revealDate;

  string public baseURI;
  string public notRevealedURI;
  string public baseExtension = ".json";
  
  bool public paused = false;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _notRevealedURI,
    uint256 _revealDate
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_notRevealedURI);
    revealDate = _revealDate;

	// Mint NFT project Reserve
    _mintToken(50);
  }

  // NFT mint
  function mint(uint256 _mintAmount) public payable {
    require(!paused, "Error: The Contract is not active at the moment");
    require(_mintAmount > 0, "Error: Mint amount has to be bigger than 0");
    require(totalSupply() + _mintAmount <= maxSupply, "Error: Sorry we are sold out");
    require(balanceOf(msg.sender) + _mintAmount <= maxMintAmount, "Error: Maximum NFT mint amount exceeded");
	require(msg.value >= (cost * _mintAmount), "Error: mint price not satisfied");
	_mintToken(_mintAmount);
  }

  // @returns tokenIds of owner 
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  // @returns URL with metadata of tokenId
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if( block.timestamp <= revealDate ) {
        return notRevealedURI;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  function _mintToken(uint256 amount) internal {
    uint256 supply = totalSupply();
    for (uint256 i = 1; i <= amount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  /**
  * ADMIN FUNCTIONS
  */

  // Sets Max Mints
  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  // URL for nonRevealed NFT state
  function setNotRevealedURI(string memory _newBaseURI) public onlyOwner {
    notRevealedURI = _newBaseURI;
  }
 
  // URL for main NFT metadata
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  // Extension of metadata
  // @dev Default .json
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  // Pause Contract 
  // @dev stops minting
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  // Withdraw funds 
  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  // @dev Fallback function for receiving Ether
  receive() external payable {
  }
}
