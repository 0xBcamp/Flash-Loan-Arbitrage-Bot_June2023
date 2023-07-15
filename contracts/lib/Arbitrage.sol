// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Arbitrage {
    struct Transaction {
        address tokenFrom;
        address tokenTo;
        address exchange;
        uint256 amount;
    }
    struct Opportunity {
        Transaction firstTransaction;
        Transaction secondTransaction;
    }
}
