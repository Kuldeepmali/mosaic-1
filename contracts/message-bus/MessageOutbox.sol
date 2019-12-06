pragma solidity >=0.5.0 <0.6.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "./MessageBox.sol";

contract MessageOutbox is MessageBox {

    /* Variables */

    // TODO: If we want to revert, may be the value will change to MessageBoxEnum.(still to think on this)
    /** Mapping to indicate that message hash exists in outbox. */
    mapping(bytes32 => bool) public outbox;

    /** Domain separator for outbox */
    bytes32 public outboxDomainSeparator;

    /** Message inbox address */
    address public messageInbox;


    /* External Functions. */

    /**
     * @notice Generate outbox message hash from the input params
     * @param _intentHash Intent hash of message.
     * @param _nonce Nonce of sender.
     * @param _gasPrice Gas price.
     * @param _gasLimit Gas limit.
     * @param _sender Sender address.
     * @return messageHash_ Message hash.
     */
    function outboxMessageHash(
        bytes32 _intentHash,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _sender
    )
        external
        view
        returns (bytes32 messageHash_)
    {
        messageHash_ = _messageHash(
            _intentHash,
            _nonce,
            _gasPrice,
            _gasLimit,
            _sender,
            outboxDomainSeparator
        );
    }


    /* Internal Functions. */

    // TODO: change `chainId` to `metachainId`
    /**
     * @notice Setup message outbox.
     * @param _chainId Chain identifier.
     * @param _messageInbox MessageInbox contract address.
     * @param _verifyingAddress Address of verifying contract.
     */
    function setupMessageOutbox(
        bytes20 _chainId,
        address _messageInbox,
        address _verifyingAddress
    )
        internal
    {
        require(
            outboxDomainSeparator == bytes32(0),
            "Message outbox is already setup."
        );

        require(
            _chainId != bytes20(0),
            "Chain id is 0."
        );

        require(
            _messageInbox != address(0),
            "Message inbox address is 0."
        );

        require(
            _verifyingAddress != address(0),
            "Verifying address is 0."
        );

        messageInbox = _messageInbox;

        outboxDomainSeparator = keccak256(
            abi.encode(
                DOMAIN_SEPARATOR_TYPEHASH,
                DOMAIN_SEPARATOR_NAME,
                DOMAIN_SEPARATOR_VERSION,
                _chainId,
                _verifyingAddress
            )
        );
    }

    /**
     * @notice Declare a new message. This will update the outbox value to
     *         `true` for the given message hash.
     * @param _intentHash Intent hash of message.
     * @param _nonce Nonce of sender.
     * @param _gasPrice Gas price.
     * @param _gasLimit Gas limit.
     * @param _sender Sender address.
     * @return messageHash_ Message hash
     */
    function declareMessage(
        bytes32 _intentHash,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _sender
    )
        internal
        returns (bytes32 messageHash_)
    {
        messageHash_ = _messageHash(
            _intentHash,
            _nonce,
            _gasPrice,
            _gasLimit,
            _sender,
            outboxDomainSeparator
        );

        require(
            outbox[messageHash_] == false,
            "Message already exists in the outbox."
        );

        outbox[messageHash_] = true;
    }
}
