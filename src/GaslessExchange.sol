//SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from  "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {ERC20Permit} from  "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";


contract GaslessExchange is ERC2771Context {

    IERC20Permit public immutable tokenA;
    IERC20Permit public immutable tokenB;

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        uint256 tokenAamount;
        uint256 tokenBamount;
        uint256 expires;
        uint filled;
        bool isExisted;
    }

    Order[] public orders;

    constructor(IERC20Permit _tokenA, IERC20Permit _tokenB, address trustedForwarder_) ERC2771Context(trustedForwarder_) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }


    function  createOrder(uint256 amount, bytes calldata signature) external {

    }

    function createOrderWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {

    }

    function splitSignature(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(signature.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(signature, 32))
            // second 32 bytes
            s := mload(add(signature, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(signature, 96)))
        }
    }
}