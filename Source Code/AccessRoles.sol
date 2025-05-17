// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract AccessRoles {
    address public owner;
    address public treasury;
    address public priceController;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyPriceController() {
        require(msg.sender == priceController, "Not controller");
        _;
    }

    constructor() {
        owner = msg.sender;
        treasury = msg.sender;
        priceController = msg.sender;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function updatePriceController(address newController) public onlyOwner {
        priceController = newController;
    }

    function updateTreasury(address newTreasury) public onlyOwner {
        treasury = newTreasury;
    }
}