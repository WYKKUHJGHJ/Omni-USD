// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AccessRoles.sol";

abstract contract AntiBotGuard {
    mapping(address => uint256) private _lastTrade;
    uint256 public cooldownTime = 5;

    modifier antiBot(address from) {
        require(block.timestamp >= _lastTrade[from] + cooldownTime, "Bot: wait");
        _;
        _lastTrade[from] = block.timestamp;
    }

    function setCooldown(uint256 seconds_) public virtual;
}

contract OmniUSDToken is AccessRoles, AntiBotGuard {
    string public name = "Omni USD";
    string public symbol = "USDO";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public anchorPrice = 1e18; // 1 USD 默认

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() AccessRoles() {
        totalSupply = 12_000_000_000 * 1e18;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function setCooldown(uint256 seconds_) public override onlyOwner {
        cooldownTime = seconds_;
    }

    function setAnchorPrice(uint256 newPrice) public onlyPriceController {
        anchorPrice = newPrice;
    }

    function transfer(address to, uint256 amount) public antiBot(msg.sender) returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public antiBot(from) returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Not approved");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}