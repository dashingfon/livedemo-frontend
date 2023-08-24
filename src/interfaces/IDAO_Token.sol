// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IERC1155} from "openzeppelin/token/ERC1155/IERC1155.sol";
import {IVotes} from "openzeppelin/governance/utils/IVotes.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
interface IDAO_Token is IERC1155, IVotes {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    event VoteUpdate(address sender, address reciever, uint256 amount, string tokenURI);
}
