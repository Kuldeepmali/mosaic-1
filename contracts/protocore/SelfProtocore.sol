pragma solidity >=0.5.0 <0.6.0;

// Copyright 2020 OpenST Ltd.
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

import "../protocore/Protocore.sol";
import "../protocore/GenesisSelfProtocore.sol";
import "../proxies/MasterCopyNonUpgradable.sol";
import "../validator/ValidatorSet.sol";


/**
 * @title SelfProtocore - This contract finalizes the proposed blocks of auxiliary chain.
 */
contract SelfProtocore is MasterCopyNonUpgradable, GenesisSelfProtocore, ValidatorSet, Protocore {

    /* Events */

    event LinkProposed(
        bytes32 _parentVoteMessageHash,
        bytes32 _targetBlockHash,
        uint256 _targetBlockNumber,
        bytes32 _sourceOriginObservation,
        bytes32 _sourceKernelHash,
        uint256 _sourceDynasty,
        uint256 _sourceAccumulatedGas,
        bytes32 _sourceCommitteeLock
    );


    /* Constants */

    bytes32 public constant SOURCE_TRANSITION_TYPEHASH = keccak256(
        "Source(bytes32 kernelHash,bytes32 originObservation,uint256 dynasty,uint256 accumulatedGas,bytes32 committeeLock)"
    );


    /* Special Functions */

    /**
     * @notice setup() function initializes the current contract.
     *
     * @dev These input params will be provided by the coconsensus contract.
     *      This can be called only by the coconsensus contract once.
     *
     * @param _metachainId Metachain id.
     * @param _domainSeparator Domain separator.
     * @param _epochLength Epoch length.
     * @param _metablockHeight Metablock height.
     *
     * \pre `_metachainId` is not 0.
     * \pre `_domainSeparator` is not 0.
     * \pre `_epochLength` is not 0.
     *
     * \post Sets `selfProtocore` to the given value.
     * \post Sets `domainSeparator` to the given value.
     * \post Sets `epochLength` to the given value.
     * \post Sets `metachainId` to the given value.
     * \post Sets genesis link.
     */
    function setup(
        bytes32 _metachainId,
        bytes32 _domainSeparator,
        uint256 _epochLength,
        uint256 _metablockHeight
    )
        external
        onlyCoconsensus
    {
        Protocore.setup(
            _metachainId,
            _domainSeparator,
            _epochLength,
            _metablockHeight,
            genesisAuxiliaryParentVoteMessageHash,
            genesisAuxiliarySourceTransitionHash,
            genesisAuxiliarySourceBlockHash,
            genesisAuxiliarySourceBlockNumber,
            genesisAuxiliaryTargetBlockHash,
            genesisAuxiliaryTargetBlockNumber
        );
        ValidatorSet.setupValidatorSet();
    }


    /* External Functions */

    /**
     * @notice Insert or remove validator. It inserts validator if not already
     *         present and reputation is greater than 0. It removes validator
     *         if it is present and reputation is 0.
     *
     * @dev Function requires:
     *      - Caller should be Coconsensus contract.
     *      - Validator can get joined/removed only at height one greater than
     *        current open kernel height.
     *
     * @param _validator Validator address to upsert.
     * @param _height Validator start or end height to be updated.
     * @param _reputation Validator's reputation value.
     */
    function upsertValidator(
        address _validator,
        uint256 _height,
        uint256 _reputation
    )
        external
        onlyCoconsensus
    {
        assert(_height == openKernelHeight.add(1));
        if(ValidatorSet.inValidatorSet(_validator, openKernelHeight)) {
            if(_reputation == 0) {
                removeValidatorInternal(_validator, _height);
            }
        }
        else {
            if(_reputation > 0) {
                insertValidatorInternal(_validator, _height);
            }
        }
    }


    /* External Functions. */

    /**
     * @notice It proposes a valid link to be voted later by active validators.
     *         It emits LinkProposed event.
     *
     * @dev Function requires :
     *          - parent vote messagehash must not be 0.
     *          - target block hash must not be 0.
     *          - source origin observation must not be 0.
     *          - source kernel hash must not be 0.
     *          - source kernel hash must not be 0.
     *          - source committee lock must not be 0.
     *          - open kernel hash must be same as source kernel hash.
     *
     * @param _parentVoteMessageHash Vote message message of the parent metablock.
     * @param _targetBlockHash Hash of block at target chain.
     * @param _targetBlockNumber Block number at target.
     * @param _sourceOriginObservation Observation of the origin chain.
     * @param _sourceKernelHash Hash of kernel at origin chain.
     * @param _sourceDynasty Dynasty of origin chain.
     * @param _sourceAccumulatedGas Accumulated gas at origin chain.
     * @param _sourceCommitteeLock Committee lock at source.
     */
    function proposeLink(
        bytes32 _parentVoteMessageHash,
        bytes32 _targetBlockHash,
        uint256 _targetBlockNumber,
        bytes32 _sourceKernelHash,
        bytes32 _sourceOriginObservation,
        uint256 _sourceDynasty,
        uint256 _sourceAccumulatedGas,
        bytes32 _sourceCommitteeLock
    )
        external
    {
        require(
            _parentVoteMessageHash != bytes32(0),
            "Vote message hash of parent must not be 0."
        );
        require(
            _targetBlockHash != bytes32(0),
            "Target blockhash must not be 0."
        );
        require(
            _sourceKernelHash != bytes32(0),
            "Origin observation must not be 0."
        );
        require(
            _sourceOriginObservation != bytes32(0),
            "Origin observation must not be 0."
        );
        require(
            _sourceCommitteeLock != bytes32(0),
            "Source committee lock must not be 0."
        );
        require(
            _sourceKernelHash == openKernelHash,
            "Source kernel hash must match with already opened kernel hash."
        );

        bytes32 sourceTransitionHash = hashSourceTransition(
            _sourceKernelHash,
            _sourceOriginObservation,
            _sourceDynasty,
            _sourceAccumulatedGas,
            _sourceCommitteeLock
        );

        Protocore.proposeLinkInternal(
            _parentVoteMessageHash,
            sourceTransitionHash,
            _targetBlockHash,
            _targetBlockNumber
        );

        emit LinkProposed(
            _parentVoteMessageHash,
            _targetBlockHash,
            _targetBlockNumber,
            _sourceOriginObservation,
            _sourceKernelHash,
            _sourceDynasty,
            _sourceAccumulatedGas,
            _sourceCommitteeLock
        );
    }


    /* Private Functions */

    /**
     * @notice Takes the parameters of an source transition object and returns the
     *         typed hash of it.
     *
     * @param _kernelHash Kernel hash.
     * @param _originObservation Observation of the origin chain.
     * @param _dynasty The dynasty number where the meta-block closes
     *                 on the auxiliary chain.
     * @param _accumulatedGas The total consumed gas on auxiliary within a
     *                        meta-block.
     * @param _committeeLock The committee lock that hashes the transaction
     *                       root on the auxiliary chain.
     * @return sourceTransitionHash_ The hash of source transition object.
     */
    function hashSourceTransition(
        bytes32 _kernelHash,
        bytes32 _originObservation,
        uint256 _dynasty,
        uint256 _accumulatedGas,
        bytes32 _committeeLock
    )
        private
        view
        returns (bytes32 sourceTransitionHash_)
    {
        bytes32 typedSourceTransitionHash = keccak256(
            abi.encode(
                SOURCE_TRANSITION_TYPEHASH,
                _kernelHash,
                _originObservation,
                _dynasty,
                _accumulatedGas,
                _committeeLock
            )
        );

        sourceTransitionHash_ = keccak256(
            abi.encodePacked(
                byte(0x19),
                byte(0x01),
                domainSeparator,
                typedSourceTransitionHash
            )
        );
    }
}
