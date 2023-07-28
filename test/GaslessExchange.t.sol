//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, stdError} from "@forge-std/Test.sol";

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {MockERC20Permit} from "@test/mocks/MockERC20Permit.sol";
import {PermitSignature} from "@test/utils/PermitSignature.sol";

import {GaslessExchange, MyMinimalForwarder} from "@main/GaslessExchange.sol";

contract GaslessExchangeTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);

    address trader1;
    address trader2;
    address trader3;
    address trader4;

    IERC20Permit tokenA;
    IERC20Permit tokenB;

    PermitSignature sigUtilsTokenA;
    PermitSignature sigUtilsTokenB;

    MyMinimalForwarder forwarder;
    GaslessExchange exchange;

    function setUp() public {
        vm.startPrank(deployer);
        vm.label(deployer, "Deployer");
        vm.deal(deployer, 1 ether);

        trader1 = vm.addr(11);
        trader2 = vm.addr(12);
        // trader3 = vm.addr(13);
        // trader4 = vm.addr(14);

        tokenA = IERC20Permit(address(new MockERC20Permit("TestTokenA", "A")));
        tokenB = IERC20Permit(address(new MockERC20Permit("TestTokenB", "B")));
        vm.label(address(tokenA), "TestTokenA");
        vm.label(address(tokenB), "TestTokenB");

        sigUtilsTokenA = new PermitSignature(tokenA.DOMAIN_SEPARATOR());
        sigUtilsTokenB = new PermitSignature(tokenB.DOMAIN_SEPARATOR());

        forwarder = new MyMinimalForwarder();
        exchange = new GaslessExchange(tokenA, tokenB, address(forwarder));
        vm.label(address(exchange), "GaslessExchange");

        deal({token: address(tokenA), to: deployer, give: 20e18});

        vm.stopPrank();
    }

    modifier setupTokens() {
        deal({token: address(tokenA), to: trader1, give: 250e18});
        deal({token: address(tokenA), to: trader2, give: 520e18});
        // deal({token: address(tokenA), to: trader3, give: 1080e18});
        // deal({token: address(tokenA), to: trader4, give: 0e18});

        deal({token: address(tokenB), to: trader1, give: 700e18});
        deal({token: address(tokenB), to: trader2, give: 300e18});
        // deal({token: address(tokenB), to: trader3, give: 200e18});
        // deal({token: address(tokenB), to: trader4, give: 0e18});
        _;
    }

    function test_mactchOrders() external setupTokens {
        vm.startPrank(deployer);

        PermitSignature.Permit memory permitToken = PermitSignature.Permit({
            owner: trader1,
            spender: address(exchange),
            value: 100e18,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digestTokenA = sigUtilsTokenA.getTypedDataHash(permitToken);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(11, digestTokenA);

        GaslessExchange.Order[] memory orders = new GaslessExchange.Order[](2);
        orders[0] = GaslessExchange.Order({
            from: address(tokenA),
            fromAmount: 100e18,
            to: address(tokenB),
            toAmount: 50e18,
            owner: trader1,
            spender: address(exchange),
            value: 100e18,
            deadline: 1 days,
            v: v,
            r: r,
            s: s,
            nonce: 0
        });

        permitToken = PermitSignature.Permit({
            owner: trader2,
            spender: address(exchange),
            value: 50e18,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digestTokenB = sigUtilsTokenB.getTypedDataHash(permitToken);
        (v, r, s) = vm.sign(12, digestTokenB);

        orders[1] = GaslessExchange.Order({
            from: address(tokenB),
            fromAmount: 50e18,
            to: address(tokenA),
            toAmount: 100e18,
            owner: trader2,
            spender: address(exchange),
            value: 50e18,
            deadline: 1 days,
            v: v,
            r: r,
            s: s,
            nonce: 0
        });

        bool success = exchange.mactchOrders(orders);
        require(success);
    }
}
