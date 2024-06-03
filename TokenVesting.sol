// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
    IERC20 public token;
    uint256 public vestingPeriod;
    mapping(address => uint256) public vestedAmounts;
    mapping(address => uint256) public releaseTimes;

    event TokensVested(address beneficiary, uint256 amount, uint256 releaseTime);
    event TokensReleased(address beneficiary, uint256 amount);

    constructor(IERC20 _token, uint256 _vestingPeriod) {
        token = _token;
        vestingPeriod = _vestingPeriod;
    }

    function vestTokens(address beneficiary, uint256 amount) external onlyOwner {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        vestedAmounts[beneficiary] += amount;
        releaseTimes[beneficiary] = block.timestamp + vestingPeriod;
        emit TokensVested(beneficiary, amount, releaseTimes[beneficiary]);
    }

    function releaseTokens() external {
        require(block.timestamp >= releaseTimes[msg.sender], "Tokens not yet releasable");
        uint256 amount = vestedAmounts[msg.sender];
        require(amount > 0, "No tokens to release");

        vestedAmounts[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit TokensReleased(msg.sender, amount);
    }
}
