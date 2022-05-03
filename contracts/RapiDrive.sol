//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./RPD.sol";

interface IRapiDrive {
    event DidOnRamp(address driver, string location);
    event DidOffRamp(address driver, string location, uint256 fees);

    function setTollFees(
        string calldata onRamp_,
        string calldata offRamp_,
        uint256 fees_
    ) external;

    function onRamp(string calldata location) external;

    function offRamp(string calldata location) external;

    function ownerWithdraw() external;

    function setRPD(address rpd_) external;
}

contract RapiDrive is Ownable, Pausable, IRapiDrive {
    RPD public rpd;
    mapping(string => mapping(string => uint256)) public fees;
    mapping(address => string) public driverOnRamps;

    function setTollFees(
        string calldata onRamp_,
        string calldata offRamp_,
        uint256 fees_
    ) external override onlyOwner {
        fees[onRamp_][offRamp_] = fees_;
    }

    function onRamp(string calldata location) external override whenNotPaused {
        require(
            rpd.allowance(_msgSender(), address(this)) >= 10,
            "Insufficient allowance"
        );
        // Since Solidity does not support direct string comparison,
        // we compare their hashes instead.
        require(
            keccak256(abi.encode(driverOnRamps[_msgSender()])) ==
                keccak256(abi.encode("")),
            "Already on road"
        );
        driverOnRamps[_msgSender()] = location;
        emit DidOnRamp(_msgSender(), location);
    }

    function offRamp(string calldata location) external override whenNotPaused {
        require(
            keccak256(abi.encode(driverOnRamps[_msgSender()])) !=
                keccak256(abi.encode("")),
            "Not on road"
        );
        uint256 tollFees = fees[driverOnRamps[_msgSender()]][location];
        driverOnRamps[_msgSender()] = "";
        rpd.transferFrom(_msgSender(), address(this), tollFees);
        emit DidOffRamp(_msgSender(), location, tollFees);
    }

    function ownerWithdraw() external override onlyOwner {
        (bool success, bytes memory data) = payable(owner()).call{ // Sending funds using call instead of transfer
            value: address(this).balance
        }("");
        require(success, string(data)); // Forwards revert message to sender
    }

    function setRPD(address rpd_) external override onlyOwner {
        rpd = RPD(rpd_);
    }

    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
    }
}
