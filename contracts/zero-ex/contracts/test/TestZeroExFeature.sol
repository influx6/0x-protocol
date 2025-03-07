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

import "../src/fixins/FixinCommon.sol";
import "../src/ZeroEx.sol";

contract TestZeroExFeature is FixinCommon {
    event PayableFnCalled(uint256 value);
    event NotPayableFnCalled();

    function payableFn() external payable {
        emit PayableFnCalled(msg.value);
    }

    function notPayableFn() external {
        emit NotPayableFnCalled();
    }

    // solhint-disable no-empty-blocks
    function unimplmentedFn() external {}

    function internalFn() external onlySelf {}
}
