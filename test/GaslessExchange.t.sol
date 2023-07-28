//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, stdError} from "@forge-std/Test.sol";

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {MockERC20Permit} from "@test/mocks/MockERC20Permit.sol";

import {GaslessExchange, MyMinimalForwarder} from "@main/GaslessExchange.sol";


contract GaslessExchangeTest is Test {

    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);

    IERC20Permit tokenA;
    IERC20Permit tokenB;

    MyMinimalForwarder forwarder;
    GaslessExchange exhange;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        tokenA = IERC20Permit(address(new MockERC20Permit("TestTokenA", "A")));
        vm.label(address(tokenA), "TestTokenA");
        tokenB = IERC20Permit(address(new MockERC20Permit("TestTokenB", "B")));
        vm.label(address(tokenB), "TestTokenB");

        forwarder = new MyMinimalForwarder();
        exhange = new GaslessExchange(tokenA, tokenB, address(forwarder));
        vm.label(address(exhange), "GaslessExchange");

        vm.stopPrank();
    }
    
}
