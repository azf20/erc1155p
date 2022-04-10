# ERC1155P

ERC1155 implementation that deploys an ERC20-compatible child contract for all new token IDs. Tokens are DEX & NFT-compatible.

_P stands for proxy / passthrough / party-time_

Quickstart:

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
