// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract AntiBotGuard {
    mapping(address => uint256) private _lastTrade;
    uint256 public cooldownTime = 5; // 秒级冷却

    modifier antiBot(address from) {
        require(block.timestamp >= _lastTrade[from] + cooldownTime, "Bot: wait before next tx");
        _;
        _lastTrade[from] = block.timestamp;
    }

    function setCooldown(uint256 seconds_) public virtual;
}