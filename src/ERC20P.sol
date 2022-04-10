// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./Utils.sol";

interface IERC1155P {
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function totalSupply(uint256 _id) external view returns (uint256);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function setApprovalFromProxy(uint256 id, address owner, address operator, bool approved) external;
  }

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
contract ERC20P is Initializable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public decimals;

    address public parent;

    uint256 public tokenId;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    function totalSupply() public view returns (uint256) {
      return IERC1155P(parent).totalSupply(tokenId);
    }

    function balanceOf(address owner) public view returns (uint256) {
      return IERC1155P(parent).balanceOf(owner, tokenId);
    }


    function allowance(address owner, address operator) public view returns(uint256) {
      if(IERC1155P(parent).isApprovedForAll(owner, operator)) {
        return MAX_INT;
      } else {
        return 0;
      }
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    // TODO: make initializable
    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _tokenId,
        address _parent
    ) public initializer {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        tokenId = _tokenId;
        parent = _parent;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {

        if(amount > 0) {
          IERC1155P(parent).setApprovalFromProxy(tokenId, msg.sender, spender, true);
        } else {
          IERC1155P(parent).setApprovalFromProxy(tokenId, msg.sender, spender, false);
        }

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {

        IERC1155P(parent).safeTransferFrom(msg.sender, to, tokenId, amount, "0x");

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {

        bool isApproved = (IERC1155P(parent).isApprovedForAll(from, msg.sender));
        require(msg.sender == from || isApproved, "NOT_AUTHORIZED");

        IERC1155P(parent).safeTransferFrom(from, to, tokenId, amount, "0x");

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                               Parent logic
    //////////////////////////////////////////////////////////////*/

    function emitTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(msg.sender == parent, "NOT_AUTHORIZED");
        emit Transfer(from, to, amount);
        return true;
    }

    function emitApproval(address owner, address spender, uint256 amount) public returns(bool) {
        require(msg.sender == parent, "NOT_AUTHORIZED");
        emit Approval(owner, spender, amount);
        return true;
    }

}
