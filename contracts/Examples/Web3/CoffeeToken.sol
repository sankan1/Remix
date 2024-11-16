// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CoffeeToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Event mida näeb blockchain exploreris kui kohvi osta ehk üks token burnida.
    event CoffeePurchased(address indexed receiver, address indexed buyer);

    constructor() ERC20("CoffeeToken", "CFE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    // põhiline funktsioon mida kasutasin, mis loob reaalse tokeni, mida deponeeritakse SmartBank saldole.
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // Tokeni "kulutamise funktsioon, kus kasutaja olemasolev token hävitatakse"
    function buyOneCoffee() public {
        _burn(_msgSender(), 1);
        emit CoffeePurchased(_msgSender(), _msgSender());
    }

    // Sarnane eelneva funktsiooniga, kuid siin "ostetakse" token ja siis see hävitatakse,
    function buyOneCoffeeFrom(address account) public {
        _spendAllowance(account, _msgSender(), 1);
        _burn(account, 1);
        emit CoffeePurchased(_msgSender(), account);
    }

    // Antud token on täpselt samasugune nagu Udemy kursuses, kuid reaalselt kasutasin blockchain exploreri demos vaid mint ja
    // approve (kunagine "allowance" nagu enamus dokumentatsiooni väidab) meetodeid.
}