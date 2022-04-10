// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "./ERC1155P.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice Mars token implementation of ERC1155P
/// @author azf20
contract ExampleERC1155P is ERC1155P, Ownable {

    constructor(address _erc20PImplementation) ERC1155P(_erc20PImplementation) {
    }

    mapping(uint256 => string) public tokenURIs;

    function setTokenURI(uint256 id, string memory newURI) public onlyOwner {
        tokenURIs[id] = newURI;
        emit URI(uri(id), id);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory tokenURI = tokenURIs[tokenId];
        return tokenURI;
    }

    function createToken(string calldata name, string calldata symbol, uint8 decimals, uint256 id, string calldata _uri) public onlyOwner {
      _createToken(name, symbol, decimals, id);
      setTokenURI(id, _uri);
    }

    /**
     * mints a tokenId to a recipient
     * @param to the recipient of the $ROVER
     * @param id the tokenId
     * @param amount the amount of $ROVER to mint
     */
    function mint(address to, uint256 id, uint256 amount) external onlyOwner {
      _mint(to, id, amount, "0x");
    }

    /**
     * batch mints token Ids to recipients
     * @param to the recipient
     * @param ids the tokenIds
     * @param amounts the amounts
     */
    function batchMint(
            address to,
            uint256[] memory ids,
            uint256[] memory amounts
            ) external onlyOwner {
      _batchMint(to, ids, amounts, "0x");
    }

    /**
     * burns a tokenId from a holder
     * @param from the holder
     * @param id the tokenId
     * @param amount the amount to burn
     */
    function burn(address from, uint256 id, uint256 amount) external onlyOwner {
      _burn(from, id, amount);
    }

    /**
     * batch burns a tokenId from a holder
     * @param from the holders
     * @param ids the tokenIds
     * @param amounts the amount to burns
     */
    function burn(
            address from,
            uint256[] memory ids,
            uint256[] memory amounts
            ) external onlyOwner {
      _batchBurn(from, ids, amounts);
    }
}
