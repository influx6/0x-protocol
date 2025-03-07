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

import "../src/features/interfaces/IMetaTransactionsFeature.sol";
import "../src/features/TransformERC20Feature.sol";

contract TestMetaTransactionsTransformERC20Feature is TransformERC20Feature {
    event TransformERC20Called(
        address sender,
        uint256 value,
        address taker,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] transformations
    );

    constructor() public TransformERC20Feature() {}

    function _transformERC20(TransformERC20Args memory args)
        public
        payable
        override
        returns (uint256 outputTokenAmount)
    {
        if (msg.value == 555) {
            tx.origin.transfer(1);
        }

        if (msg.value == 666) {
            revert("FAIL");
        }

        if (msg.value == 777) {
            LibSignature.Signature memory signature;

            // Try to reenter `executeMetaTransaction()`
            IMetaTransactionsFeature(address(this)).executeMetaTransaction(
                IMetaTransactionsFeature.MetaTransactionData({
                    signer: address(0),
                    sender: address(0),
                    minGasPrice: 0,
                    maxGasPrice: 0,
                    expirationTimeSeconds: 0,
                    salt: 0,
                    callData: "",
                    value: 0,
                    feeToken: IERC20TokenV06(0),
                    feeAmount: 0
                }),
                signature
            );
        }

        if (msg.value == 888) {
            // Try to reenter `batchExecuteMetaTransactions()`
            IMetaTransactionsFeature.MetaTransactionData[]
                memory mtxs = new IMetaTransactionsFeature.MetaTransactionData[](1);
            LibSignature.Signature[] memory signatures = new LibSignature.Signature[](1);
            mtxs[0] = IMetaTransactionsFeature.MetaTransactionData({
                signer: address(0),
                sender: address(0),
                minGasPrice: 0,
                maxGasPrice: 0,
                expirationTimeSeconds: 0,
                salt: 0,
                callData: "",
                value: 0,
                feeToken: IERC20TokenV06(0),
                feeAmount: 0
            });
            IMetaTransactionsFeature(address(this)).batchExecuteMetaTransactions(mtxs, signatures);
        }

        emit TransformERC20Called(
            msg.sender,
            msg.value,
            args.taker,
            args.inputToken,
            args.outputToken,
            args.inputTokenAmount,
            args.minOutputTokenAmount,
            args.transformations
        );
        return 1337;
    }
}
