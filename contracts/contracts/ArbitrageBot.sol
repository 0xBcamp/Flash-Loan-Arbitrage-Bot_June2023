// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <=0.8.19;

import "../interfaces/IArbitrageFinder.sol";
import "../interfaces/IArbitrageExecutor.sol";
import "./Whitelisted.sol";
import "../lib/Arbitrage.sol";

contract ArbitrageBot is Whitelisted {
    IArbitrageFinder private arbitrageFinder;
    IArbitrageExecutor private arbitrageExecutor;

    constructor(address _arbitragFinder, address _arbitrageExecutor) {
        arbitrageFinder = IArbitrageFinder(_arbitragFinder);
        arbitrageExecutor = IArbitrageExecutor(_arbitrageExecutor);
    }

    function execute(address token1, address token2) external onlyWhitelisted {
        (bool isFound, Arbitrage.Opportunity memory arbitrage) = arbitrageFinder
            .find(token1, token2);

        if (isFound) {
            arbitrageExecutor.execute(arbitrage);
        }
    }
}
