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
import "../src/transformers/IERC20Transformer.sol";
import "../src/transformers/LibERC20Transformer.sol";
import "./tokens/TestMintableERC20Token.sol";

contract TestMintTokenERC20Transformer is IERC20Transformer {
    struct TransformData {
        IERC20TokenV06 inputToken;
        TestMintableERC20Token outputToken;
        uint256 burnAmount;
        uint256 mintAmount;
        uint256 feeAmount;
    }

    event MintTransform(
        address context,
        address caller,
        address sender,
        address taker,
        bytes data,
        uint256 inputTokenBalance,
        uint256 ethBalance
    );

    function transform(TransformContext calldata context) external override returns (bytes4 success) {
        TransformData memory data = abi.decode(context.data, (TransformData));
        emit MintTransform(
            address(this),
            msg.sender,
            context.sender,
            context.recipient,
            context.data,
            LibERC20Transformer.isTokenETH(data.inputToken)
                ? address(this).balance
                : data.inputToken.balanceOf(address(this)),
            address(this).balance
        );
        // "Burn" input tokens.
        if (LibERC20Transformer.isTokenETH(data.inputToken)) {
            address(0).transfer(data.burnAmount);
        } else {
            data.inputToken.transfer(address(0), data.burnAmount);
        }
        // Mint output tokens.
        if (!LibERC20Transformer.isTokenETH(IERC20TokenV06(address(data.outputToken)))) {
            if (data.feeAmount > data.mintAmount) {
                data.outputToken.burn(context.recipient, data.feeAmount - data.mintAmount);
            } else {
                data.outputToken.mint(address(this), data.mintAmount);
                data.outputToken.burn(context.recipient, data.feeAmount);
            }
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}
