// SPDX-Licence-Identifier: UNLICENSED

pragma solidity 0.8.19;

import {IListing} from "./interfaces/IListing.sol";
import {IALLDAO_Governor} from "./interfaces/IALLDAO_Governor.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract Listing is IListing {}
