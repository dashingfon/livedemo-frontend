// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {ERC1155URIStorage} from "openzeppelin/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {IDAO_Token} from "./interfaces/IDAO_Token.sol";
import {Votes} from "openzeppelin/governance/utils/Votes.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract DAO_Token is IDAO_Token, Votes, ERC1155URIStorage {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call");
    }

    constructor() {
        owner = msg.sender;
    }

    // External Functions

    function mint(uint256 tokenId, uint256 amount, address to, bytes data) external onlyOwner {}

    function setURI() external onlyOwner {}

    function setBaseURI() external onlyOwner {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(tokenId);
    }

    // Internal Functions

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        _transferVotingUnits(from, to, batchSize);
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return balanceOf(account);
    }
}
