//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RPD is ERC20 {
    constructor() ERC20("RapiDrive", "RPD") {}

    function mint() external payable {
        _mint(_msgSender(), msg.value);
    }
}
