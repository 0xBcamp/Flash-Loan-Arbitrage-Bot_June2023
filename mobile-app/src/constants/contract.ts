// Arbitrage Engine Optimism Goerli network
export const arbitrageBotAddress = "0xD21D93713ae9Bc83DA03360665799Ce95Ae61583";
export const arbitrageFinderAddress =
  "0xEEFe0B568Eb7572112DfFEdd8ACa99d8eeA65383";
export const arbitrageExecutorAddress =
  "0x56235F7cf1CC0F61685a077D7b1C8b7927838a09";
export const tradeExecutorAddress =
  "0x788018DA0c2656EC90494f55325d3dc862109857";

export const botAbi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_arbitragFinder",
        type: "address",
      },
      {
        internalType: "address",
        name: "_arbitrageExecutor",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bool",
        name: "isFound",
        type: "bool",
      },
    ],
    name: "ArbitrageOpportunity",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_address",
        type: "address",
      },
    ],
    name: "addToWhitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token1",
        type: "address",
      },
      {
        internalType: "address",
        name: "token2",
        type: "address",
      },
    ],
    name: "execute",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_address",
        type: "address",
      },
    ],
    name: "isWhitelisted",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_address",
        type: "address",
      },
    ],
    name: "removeFromWhitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];
