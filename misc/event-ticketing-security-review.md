# Event-Ticketing project security review

## Overview

This document details the findings of a security review performed by Team Sierra on Team Charlie's project.

## Project Summary

The **Event Ticketing** blockchain project revolutionizes the ticketing industry by enabling secure transfer and sale of NFT tickets on third-party marketplaces. Users can easily find events, purchase tickets for themselves or others, receive email receipts with NFTs and QR codes, and enjoy benefits like refunds, loyalty rewards, VIP status, and discounted ticket prices.

## Table of Content

- Source code summary
- Findings summary
- Code Base
- Security Review Scope
- Approach and Method
- Compilation warnings/errors
- Findings details

## Source code summary

- Total number of contracts in source files: 1
- Number of contracts in dependencies: 20
- Source lines of code (SLOC) in source files: 154
- Source lines of code (SLOC) in dependencies: 2005
- Use: Openzeppelin-Ownable, Openzeppelin-ERC721
- ERCs: ERC165, ERC721

## Findings summary

<table>
  <tr>
    <th>Number of Findings</th>
    <th>Findings</th>
    <th>Findings Summary</th>
  </tr>
  <tr>
    <td>0</td>
    <td><strong>High</strong></td>
    <td>High risks that impact platform functioning are found.</td>
  </tr>
  <tr>
    <td>1</td>
    <td><strong>Low</strong></td>
    <td>Low risks that can lead to loss of funds or control are identified.</td>
  </tr>
  <tr>
    <td>9</td>
    <td><strong>Medium</strong></td>
    <td>Medium risks that affect overall platform functioning are discovered.</td>
  </tr>
  <tr>
    <td>2</td>
    <td><strong>Optimization</strong></td>
    <td>No minor risks compromising the project integrity are observed.</td>
  </tr>
  <tr>
    <td>476</td>
    <td><strong>Informational</strong></td>
    <td>Recommendations are made to improve code style and adhere to industry best practices, but they don't impact the overall functioning of the code.</td>
  </tr>
</table>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th># functions</th>
      <th>ERCS</th>
      <th>ERC20 info</th>
      <th>Complex code</th>
      <th>Features</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>EventTicketing</td>
      <td>108</td>
      <td>ERC165, ERC721</td>
      <td></td>
      <td>No</td>
      <td>Receive ETH<br>Send ETH<br>Assembly</td>
    </tr>
    <tr>
      <td>Address</td>
      <td>13</td>
      <td></td>
      <td></td>
      <td>No</td>
      <td>Send ETH<br>Delegatecall<br>Assembly</td>
    </tr>
    <tr>
      <td>Counters</td>
      <td>4</td>
      <td></td>
      <td></td>
      <td>No</td>
      <td></td>
    </tr>
    <tr>
      <td>Strings</td>
      <td>7</td>
      <td></td>
      <td></td>
      <td>No</td>
      <td>Assembly</td>
    </tr>
    <tr>
      <td>Math</td>
      <td>14</td>
      <td></td>
      <td></td>
      <td>Yes</td>
      <td>Assembly</td>
    </tr>
    <tr>
      <td>SignedMath</td>
      <td>4</td>
      <td></td>
      <td></td>
      <td>No</td>
      <td></td>
    </tr>
    <tr>
      <td>console</td>
      <td>381</td>
      <td></td>
      <td></td>
      <td>No</td>
      <td>Assembly</td>
    </tr>
  </tbody>
</table>

## Code Base

- [GitHub repository](https://github.com/0xBcamp/Event-Ticketing_June2023)

## Security Review Scope

- `EventTicketing.sol` smart contract and its dependencies

## Approach and Method

This report has been prepared for Bcamp **Event-Ticketing** to discover issues and vulnerabilities in the source code of the **Team Event-Ticketing** project as well as any contract dependencies that were not part of an officially recognized library. A good examination has been performed, utilizing **Manual Review** with use of **ChatGPT** and **Slither**

## Compilation warnings/errors

```solidity
Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> /mnt/d/Engineering/bcamp/Event-Ticketing_June2023/contracts/EventTicketing.sol:73:31:
   |
73 |     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
   |                               ^^^^^^^^^^^^^^^^

Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> /mnt/d/Engineering/bcamp/Event-Ticketing_June2023/contracts/EventTicketing.sol:73:49:
   |
73 |     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
   |                                                 ^^^^^^^^^^^^

Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> /mnt/d/Engineering/bcamp/Event-Ticketing_June2023/contracts/EventTicketing.sol:73:63:
   |
73 |     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
   |                                                               ^^^^^^^^^^^^^^^

Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> /mnt/d/Engineering/bcamp/Event-Ticketing_June2023/contracts/EventTicketing.sol:73:80:
   |
73 |     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
   |                                                                                ^^^^^^^^^^^^^^^^^^^

Warning: Function state mutability can be restricted to pure
  --> /mnt/d/Engineering/bcamp/Event-Ticketing_June2023/contracts/EventTicketing.sol:73:5:
   |
73 |     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
   |     ^ (Relevant source part starts here and spans across multiple lines).
```

## Findings details

### Lack of SPDX License Identifier:

**Severity: Informational**  
**Description**: The SPDX-License-Identifier is missing, which is a best practice for indicating the license under which the smart contract is released. While this does not pose a direct security risk, it is important for clarity and compliance.

---

### Variable and Function Documentation:

**Severity: Informational**  
**Description**: Some variables and functions lack sufficient documentation and comments, which can make the code less understandable and maintainable. Proper documentation is essential for other developers to easily understand the contract's logic and potential risks.

Example:

```solidity
function seatTaken(uint256 _seat) public view returns (bool) {
    return tickets[_seat].purchaser != address(0);
}
```

---

### Calls inside a loop:

**Severity: Low**  
**Description**: Calls inside a loop might lead to a denial-of-service attack.

```solidity
ERC721._checkOnERC721Received(address,address,uint256,bytes) (@openzeppelin/contracts/token/ERC721/ERC721.sol#399-421) has external calls inside a loop: retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (@openzeppelin/contracts/token/ERC721/ERC721.sol#406-417)
```

## **[Reference](https://github.com/crytic/slither/wiki/Detector-Documentation/#calls-inside-a-loop)**

### State variables that could be declared immutable:

**Severity: Optimization**  
**Description**: State variables that are not updated following deployment should be declared immutable to save gas.

```solidity
EventTicketing.cost (../contracts/EventTicketing.sol#24) should be immutable
EventTicketing.eventTime (../contracts/EventTicketing.sol#22) should be immutable
EventTicketing.maxTickets (../contracts/EventTicketing.sol#20) should be immutable
```

## **[Reference](https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable)**

---

### `Public` access modifier can be `External`

**Severity: Medium**  
**Description**: `public` functions that are not used internally should be marked as `external`.

```solidity
function setupTicketScannerRoles(address ticketScanner) public onlyOwner {
  grantRole(TICKET_SCANNER_ROLE, ticketScanner);
}
```

## **[Reference](https://gus-tavo-guim.medium.com/public-vs-external-functions-in-solidity-b46bcf0ba3ac)**

---

### `_setupRole` function is deprecated OpenZeppelin `AccessControl.sol`

**Severity: Optimization**  
**Description**: following the OpenZeppelin documentation `_setupRole` function that is used in constructor was deprecated, `_grantRole` should be used instead

```solidity
constructor(uint256 _maxTickets, string memory _eventLocation, string memory _eventName, uint256 _eventTime) ERC721("EventTicketing", "EVTK") {
  maxTickets = _maxTickets;
  eventLocation = _eventLocation;
  eventTime = _eventTime;
  eventName = _eventName;
  cost = uint256(100);

  _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
}
```

## **[Reference](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol#L204)**

---

### Divide before multiply:

**Severity: Medium**  
**Description**: Solidity's integer division truncates. Thus, performing division before multiplication can lead to precision loss.

```solidity
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse = (3 * denominator) ^ 2 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#116)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#120)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#121)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#122)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#123)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#124)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#101)
        - inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#125)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        - prod0 = prod0 / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#104)
        - result = prod0 * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#131)
```

## **[Reference](https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply)**
