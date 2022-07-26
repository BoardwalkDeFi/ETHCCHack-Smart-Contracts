//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BoardwalkToken is ERC20{
    constructor() ERC20("Boardwalk Token", "BORD"){

    }

    function mint(address _to, uint _am)external {
        _mint(_to, _am);
    }
}