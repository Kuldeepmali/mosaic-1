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
//
// ----------------------------------------------------------------------------
// Based on the 'final' EIP20 token standard as specified at:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------

/**
 * @title ERC20Interface.
 *
 * @notice Provides ERC20 token interface.
 */
interface ERC20I {


    /* Events */

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );


    /* External functions */

    /**
     * @notice External function to get the name of the token.
     *
     * @return tokenName_ Name of the token.
     */
    function name() external view returns (string memory tokenName_);

    /**
     * @notice External function to get the symbol of the token.
     *
     * @return tokenSymbol_ Symbol of the token.
     */
    function symbol() external view returns (string memory tokenSymbol_);

    /**
     * @notice External function to get the decimals of the token.
     *
     * @return tokenDecimals Decimals of the token.
     */
    function decimals() external view returns (uint8 tokenDecimals_);

    /**
     * @notice External function to get the total supply of the tokens.
     *
     * @return totalTokenSupply_ Total token supply.
     */
    function totalSupply()
        external
        view
        returns (uint256 totalTokenSupply_);

    /**
     * @notice Get the balance of an account.
     *
     * @param _owner Address of the owner account.
     *
     * @return balance_ Account balance of the owner account.
     */
    function balanceOf(address _owner) external view returns (uint256 balance_);

    /**
     * @notice External function to get the allowance.
     *
     * @param _owner Address of the owner account.
     * @param _spender Address of the spender account.
     *
     * @return allowance_ Remaining allowance for the spender to spend from
     *                    owner's account.
     */
    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256 allowance_);


    /**
     * @notice External function to transfer the token.
     *
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to be transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        external
        returns (bool success_);

    /**
     * @notice External function transferFrom.
     *
     * @param _from Address from which tokens are transferred.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool success_);

    /**
     * @notice External function to approve an account for transfer.
     *
     * @param _spender Address authorized to spend from the function caller's
     *                 address.
     * @param _value Amount up to which spender is authorized to spend.
     *
     * @return bool `true` for a successful approval, `false` otherwise.
     */
    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool success_);

    /**
     * @notice Burns an amount of the token of a given
     *         account.
     * @param _account The account whose tokens will be burnt.
     * @param _value The amount that will be burnt.
     */
    function burn(address _account, uint256 _value)
        external;

    /**
     * @notice Burns an amount of the token of a given account, deducting
     *         from the sender's allowance for said account.
     * @param _account The account whose tokens will be burnt.
     * @param _value The amount that will be burnt.
     */
    function burnFrom(address _account, uint256 _value)
        external;
}
