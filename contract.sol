// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockSafe {
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
        address owner;
    }

    mapping(address => Lock[]) public locks;
    uint256 public rewardRate = 1; // 1% reward per year in LSafe tokens (adjustable)

    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount, uint256 reward);

    // Lock tokens
    function lockTokens(uint256 _amount, uint256 _lockDuration) external payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(msg.value == _amount, "Sent value must match amount");

        uint256 unlockTime = block.timestamp + _lockDuration;
        locks[msg.sender].push(Lock(_amount, unlockTime, msg.sender));
        emit TokensLocked(msg.sender, _amount, unlockTime);
    }

    // Unlock tokens and distribute rewards
    function unlockTokens(uint256 _index) external {
        Lock storage userLock = locks[msg.sender][_index];
        require(block.timestamp >= userLock.unlockTime, "Tokens are still locked");
        require(userLock.owner == msg.sender, "Not the owner");

        uint256 reward = calculateReward(userLock.amount, userLock.unlockTime);
        payable(msg.sender).transfer(userLock.amount);
        
        // Simulate LSafe reward distribution (in a real scenario, integrate an ERC-20 token)
        emit TokensUnlocked(msg.sender, userLock.amount, reward);

        // Remove the lock
        locks[msg.sender][_index] = locks[msg.sender][locks[msg.sender].length - 1];
        locks[msg.sender].pop();
    }

    // Calculate reward (mock function; integrate LSafe token in full version)
    function calculateReward(uint256 _amount, uint256 _unlockTime) internal view returns (uint256) {
        uint256 lockDuration = (block.timestamp - _unlockTime) / 365 days;
        return (_amount * rewardRate * lockDuration) / 100;
    }

    // Accept native currency (tBNB for testing)
    receive() external payable {}
}