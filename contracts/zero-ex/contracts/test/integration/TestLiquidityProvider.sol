// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2020 ZeroEx Intl.

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

contract TestLiquidityProvider {
    event SellTokenForToken(
        address inputToken,
        address outputToken,
        address recipient,
        uint256 minBuyAmount,
        uint256 inputTokenBalance
    );

    event SellEthForToken(address outputToken, address recipient, uint256 minBuyAmount, uint256 ethBalance);

    event SellTokenForEth(address inputToken, address recipient, uint256 minBuyAmount, uint256 inputTokenBalance);

    receive() external payable {}

    /// @dev Trades `inputToken` for `outputToken`. The amount of `inputToken`
    ///      to sell must be transferred to the contract prior to calling this
    ///      function to trigger the trade.
    /// @param inputToken The token being sold.
    /// @param outputToken The token being bought.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of `outputToken` to buy.
    /// @return boughtAmount The amount of `outputToken` bought.
    function sellTokenForToken(
        address inputToken,
        address outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata // auxiliaryData
    ) external returns (uint256) {
        emit SellTokenForToken(
            inputToken,
            outputToken,
            recipient,
            minBuyAmount,
            IERC20TokenV06(inputToken).balanceOf(address(this))
        );
        uint256 outputTokenBalance = IERC20TokenV06(outputToken).balanceOf(address(this));
        IERC20TokenV06(outputToken).transfer(recipient, outputTokenBalance);
    }

    /// @dev Trades ETH for token. ETH must be sent to the contract prior to
    ///      calling this function to trigger the trade.
    /// @param outputToken The token being bought.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of `outputToken` to buy.
    /// @return boughtAmount The amount of `outputToken` bought.
    function sellEthForToken(
        address outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata // auxiliaryData
    ) external returns (uint256) {
        emit SellEthForToken(outputToken, recipient, minBuyAmount, address(this).balance);
        uint256 outputTokenBalance = IERC20TokenV06(outputToken).balanceOf(address(this));
        IERC20TokenV06(outputToken).transfer(recipient, outputTokenBalance);
    }

    /// @dev Trades token for ETH. The token must be sent to the contract prior
    ///      to calling this function to trigger the trade.
    /// @param inputToken The token being sold.
    /// @param recipient The recipient of the bought tokens.
    /// @param minBuyAmount The minimum acceptable amount of ETH to buy.
    /// @return boughtAmount The amount of ETH bought.
    function sellTokenForEth(
        address inputToken,
        address payable recipient,
        uint256 minBuyAmount,
        bytes calldata // auxiliaryData
    ) external returns (uint256) {
        emit SellTokenForEth(inputToken, recipient, minBuyAmount, IERC20TokenV06(inputToken).balanceOf(address(this)));
        recipient.transfer(address(this).balance);
    }
}
