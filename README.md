# ERC1155P

ERC1155P is ERC1155 compatible, but clones an ERC20-compatible child (ERC20P) via CREATE2 for all new token IDs.

State is stored in the parent ERC1155P contract, but users can interact with either the parent or children via the standard interfaces. Tokens are therefore simultaneously DEX & NFT-compatible. The additional overhead is in inter-contract calls & emitted events.

ERC1155P is an abstract contract. ExampleERC1155P.sol is an example implementation, whose functionality is illustrated in `/src/test/ERC1155P.t.sol`.

### Notes:

- Partial approvals are not possible (as they are not compatible with EIP-1155) - any approval greater than zero is treated as a MAX_INT approval
- Any approval for any child token is an approval for all of them (this could be a benefit or a hazard, depending on your perspective)
- Batch transfers are supported in line with EIP-1155
- uri() implementation is left up to the user (not specifically in scope for ERC1155P, but the Example implementation takes a view)

_P stands for proxy / passthrough / party-time_

### Quickstart:

```
// if foundry is not installed (from https://book.getfoundry.sh/getting-started/installation.html)
curl -L https://foundry.paradigm.xyz | bash
foundryup
// build & test
forge build
forge test
```

Built with [Foundry](https://github.com/gakonst/foundry), [solmate](https://github.com/Rari-Capital/solmate) & [OpenZeppelin](https://docs.openzeppelin.com/contracts/4.x/).

_This is experimental software and is provided on an "as is" and "as available" basis._
