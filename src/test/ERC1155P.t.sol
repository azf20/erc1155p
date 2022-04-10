// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../ExampleERC1155P.sol";
import "../ERC20P.sol";
import "../ERC1155P.sol";

interface CheatCodes {
    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;
    function prank(address) external;
    function assume(bool) external;
}

contract ERC1155PTest is DSTest {

    ExampleERC1155P exampleERC1155P;
    ERC20P erc20Pimplementation;
    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    string name = "NewToken";
    string symbol = "NEW";
    uint8 decimals = 18;
    string uri = "starterURI";
    uint256 tokenId = 1;
    uint256 amount = 10;

    address testAddress = 0x60Ca282757BA67f3aDbF21F3ba2eBe4Ab3eb01fc;
    address anotherAddress = 0x34aA3F359A9D614239015126635CE7732c18fDF3;

    event NewToken(string name, string symbol, uint8 decimals, uint256 id);
    event Transfer(address from, address to, uint256 amount);
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    function setUp() public {
      erc20Pimplementation = new ERC20P();
      exampleERC1155P = new ExampleERC1155P(address(erc20Pimplementation));
    }

    function createAndMint(uint256 newTokenId) public {
      exampleERC1155P.createToken(name, symbol, decimals, newTokenId, uri);
      exampleERC1155P.mint(testAddress, newTokenId, amount);
    }

    function testFailMint() public {
        exampleERC1155P.mint(address(this), tokenId, 1);
    }

    function testCreateToken(uint256 newTokenId) public {
        cheats.expectEmit(true, true, true, true);
        emit NewToken(name, symbol, decimals, newTokenId);
        exampleERC1155P.createToken(name, symbol, decimals, newTokenId, uri);
    }

    function testFailCreateTokenTwice() public {
        exampleERC1155P.createToken(name, symbol, decimals, tokenId, uri);
        exampleERC1155P.createToken(name, symbol, decimals, tokenId, uri);
    }

    function testFailNonOwnerCall(address caller) public {
        cheats.assume(caller != address(this));
        cheats.prank(caller);
        exampleERC1155P.createToken(name, symbol, decimals, tokenId, uri);
    }

    function testMint(uint256 fuzzAmount) public {
        cheats.assume(fuzzAmount > 0);

        exampleERC1155P.createToken(name, symbol, decimals, tokenId, uri);

        /*
        //There seems to be a bug in expectEmit where the event is emitted by a child contract
        cheats.expectEmit(true, true, false, true);
        emit Transfer(address(0), testAddress, amount);

        cheats.expectEmit(true, true, false, true);
        emit TransferSingle(address(this), address(0), testAddress, 1, amount);
        */

        exampleERC1155P.mint(testAddress, tokenId, fuzzAmount);
        assertEq(exampleERC1155P.balanceOf(testAddress, tokenId), fuzzAmount);

        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        assertEq(childErc20P.balanceOf(testAddress), fuzzAmount);
    }

    function testERC1155Transfer() public {

        createAndMint(1);

        cheats.prank(testAddress);
        exampleERC1155P.safeTransferFrom(testAddress, anotherAddress, tokenId, amount, "0x");
        assertEq(exampleERC1155P.balanceOf(anotherAddress, tokenId), amount);
        assertEq(exampleERC1155P.balanceOf(testAddress, tokenId), 0);

        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        assertEq(childErc20P.balanceOf(anotherAddress), amount);
        assertEq(childErc20P.balanceOf(testAddress), 0);
    }

    function testERC1155BatchTransfer() public {

        createAndMint(1);
        createAndMint(2);

        cheats.prank(testAddress);

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);

        ids[0] = 1;
        ids[1] = 2;

        amounts[0] = amount;
        amounts[1] = amount / 2;

        exampleERC1155P.safeBatchTransferFrom(testAddress, anotherAddress, ids, amounts, "0x");
        assertEq(exampleERC1155P.balanceOf(anotherAddress, 1), amount);
        assertEq(exampleERC1155P.balanceOf(testAddress, 1), 0);

        assertEq(exampleERC1155P.balanceOf(anotherAddress, 2), amount / 2);
        assertEq(exampleERC1155P.balanceOf(testAddress, 2), amount / 2);

        ERC20P childErc20P1 = ERC20P(exampleERC1155P.erc20P(1));
        assertEq(childErc20P1.balanceOf(anotherAddress), amount);
        assertEq(childErc20P1.balanceOf(testAddress), 0);

        ERC20P childErc20P2 = ERC20P(exampleERC1155P.erc20P(2));
        assertEq(childErc20P2.balanceOf(anotherAddress), amount / 2);
        assertEq(childErc20P2.balanceOf(testAddress), amount / 2);
    }

    function testERC20Transfer() public {

        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));

        cheats.prank(testAddress);
        childErc20P.transfer(anotherAddress, amount);
        assertEq(exampleERC1155P.balanceOf(anotherAddress, tokenId), amount);
        assertEq(exampleERC1155P.balanceOf(testAddress, tokenId), 0);

        assertEq(childErc20P.balanceOf(anotherAddress), amount);
        assertEq(childErc20P.balanceOf(testAddress), 0);
    }

    function testERC20TransferFrom() public {

        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));

        cheats.prank(testAddress);
        childErc20P.transferFrom(testAddress, anotherAddress, amount);
        assertEq(exampleERC1155P.balanceOf(anotherAddress, tokenId), amount);
        assertEq(exampleERC1155P.balanceOf(testAddress, tokenId), 0);

        assertEq(childErc20P.balanceOf(anotherAddress), amount);
        assertEq(childErc20P.balanceOf(testAddress), 0);
    }

    function testERC1155Approve() public {

        createAndMint(1);

        cheats.prank(testAddress);
        exampleERC1155P.setApprovalForAll(anotherAddress, true);
        assertTrue(exampleERC1155P.isApprovedForAll(testAddress, anotherAddress));

        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        assertEq(childErc20P.allowance(testAddress, anotherAddress), MAX_INT);
    }

    function testERC20Approve() public {

        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));

        cheats.prank(testAddress);
        childErc20P.approve(anotherAddress, 10);

        assertTrue(exampleERC1155P.isApprovedForAll(testAddress, anotherAddress));
        assertEq(childErc20P.allowance(testAddress, anotherAddress), MAX_INT);
    }

    function testApprovedOnceApprovedForAll() public {

        createAndMint(1);
        createAndMint(2);

        ERC20P childErc20P1 = ERC20P(exampleERC1155P.erc20P(1));
        ERC20P childErc20P2 = ERC20P(exampleERC1155P.erc20P(2));

        cheats.prank(testAddress);
        childErc20P1.approve(anotherAddress, 10);

        assertEq(childErc20P1.allowance(testAddress, anotherAddress), MAX_INT);
        assertEq(childErc20P2.allowance(testAddress, anotherAddress), MAX_INT);
    }

    function testTransferByApprovedOperator() public {

        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));

        cheats.prank(testAddress);
        childErc20P.approve(anotherAddress, 10);

        cheats.prank(anotherAddress);
        exampleERC1155P.safeTransferFrom(testAddress, anotherAddress, tokenId, 1, "0x");

        assertEq(childErc20P.balanceOf(anotherAddress), 1);

        cheats.prank(anotherAddress);
        childErc20P.transferFrom(testAddress, anotherAddress, 1);

        assertEq(childErc20P.balanceOf(anotherAddress), 2);
    }

    function testFailERC1155TransferByNonApproved() public {
        createAndMint(1);
        exampleERC1155P.safeTransferFrom(testAddress, anotherAddress, tokenId, 1, "0x");
    }

    function testFailERC20TransferByNonApproved() public {
        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        childErc20P.transferFrom(testAddress, anotherAddress, 1);
    }

    function testFailEmitTransferForNonParent() public {
        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        cheats.prank(anotherAddress);
        childErc20P.emitTransfer(testAddress, anotherAddress, 1);
    }

    function testFailEmitApproveForNonParent() public {
        createAndMint(1);
        ERC20P childErc20P = ERC20P(exampleERC1155P.erc20P(tokenId));
        cheats.prank(anotherAddress);
        childErc20P.emitApproval(testAddress, anotherAddress, 1);
    }
}
