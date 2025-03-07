// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;

import "@0x/contracts-erc20/contracts/src/v06/IERC20TokenV06.sol";
import "../tokens/TestMintableERC20Token.sol";

contract TestMooniswap {
    event MooniswapCalled(
        uint256 value,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        uint256 minBuyAmount,
        address referral
    );

    uint256 public nextBuyAmount;

    function setNextBoughtAmount(uint256 amt) external payable {
        nextBuyAmount = amt;
    }

    function swap(
        IERC20TokenV06 sellToken,
        TestMintableERC20Token buyToken,
        uint256 sellAmount,
        uint256 minBuyAmount,
        address referral
    ) external payable returns (uint256 boughtAmount) {
        emit MooniswapCalled(
            msg.value,
            sellToken,
            IERC20TokenV06(address(buyToken)),
            sellAmount,
            minBuyAmount,
            referral
        );
        boughtAmount = nextBuyAmount;
        nextBuyAmount = 0;
        require(boughtAmount >= minBuyAmount, "UNDERBOUGHT");
        if (sellToken != IERC20TokenV06(0)) {
            sellToken.transferFrom(msg.sender, address(this), sellAmount);
        } else {
            require(sellAmount == msg.value, "NOT_ENOUGH_ETH");
        }
        if (address(buyToken) == address(0)) {
            msg.sender.transfer(boughtAmount);
        } else {
            buyToken.mint(msg.sender, boughtAmount);
        }
    }
}
