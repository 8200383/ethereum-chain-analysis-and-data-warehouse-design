# Ethereum Chain Analysis And Data Warehouse Design
A project to design a fact and dimension star schema for optimizing queries on a Ethereum Chain database using MSSQL (Microsoft SQL Server), a relational database management system.
The designed schema allows for efficient querying of data such as transaction dates, gas fees, and transaction volume information.
The ETL process for the Ethereum Chain Analysis is designed using Microsoft SQL Server Integration Services (SSIS).

# 1. Asks!?
- [ ] What is the total transaction volume on the eth chain over a specific time period?
- [ ] What are the most popularly exchanged digital tokens, represented by ERC-721 and ERC-20 smart contracts?
- [ ] The biggest transactions over the last 24 hours?
- [ ] Transactions with the highest gas fee over the last 24 hours?

# 3. Fact and Dimensional Tables
The star schema for the Ethereum Chain Analysis and Data Warehouse Design consists of the following dimensions and facts:

| **Facts**           | **Description**                                                                                                                                |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Transactions** | To store information about individual Ethereum transactions, such as transaction hash, block hash, transaction value, and transaction gas. |
| **Token Transfers** | To store information about ERC-20 token transfers, such as transfer from, transfer to, transfer value, and transfer transaction hash. |
| **Wallet Snapshot** | To store wallet balance |
| **Block Snapshot** | To store state of a block, such as gas_price, max_fee_per_gas, max_priority_fee_per_gas per block_timestamp |

| **Dimensions**           | **Description**                                                                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Tokens**       | To store information about ERC-20 tokens, such as token contract address, token symbol, token name, and token total supply. |
| **Timestamp** | To store timestamps for various Ethereum-related events. |
| **Wallets** | To store information about Ethereum addresses. |

## 3.1. Star Schema as PlantUML

# 4. Schemas
## 4.1. Fact Schemas
### 4.1.1. Transaction Fact Schema
| **Column** | **Type**| **Designation** |
|----------|-------------| -------- |
| **transaction_id** | int | | 
| **hash** | hex_string | |
| **block_hash** | hex_string | | 
| **block_number** | bigint | | 
| **transaction_index** | bigint | |
| **from_address** | address | |
| **to_address** | address | | 
| **gas** | numeric | |
| **gas_price** | bigint | |
| **block_timestamp** | bigint| |
| **max_fee_per_gas** | bigint | | 
| **max_priority_fee_per_gas** | bigint | |
| **transaction_type** | bigint | | 
### 4.1.2. Token Transfer Fact Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | --------- | 
| **token_transfer_id** | int | | 
| **token_address** | address | | 
| **from_address** | address | | 
| **to_address**   | address | | 
| **value**        | numeric | | 
| **transaction_hash** | hex_string | |
| **log_index**    | bigint   | |
| **block_number** | bigint   | |
### 4.1.3. Wallet Snapshot Fact Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | --------- | 
| **wallet_id** | int | |
| **balance** | bigint | |
### 4.1.4. Block Snapshot Fact Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | --------- | 
| **block_id** | int | |
| **hash** | hex_string | |
| **timestamp_id** | int | | 
| **difficulty** | numeric | |
| **total_difficulty** | numeric | |
| **transaction_count** | bigint | |
| **gas_limit** | bigint | |
| **gas_used** | bigint | |
| **base_fee_per_gas** | bigint | |
## 4.2. Dimension Schemas
### 4.2.1. Token Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | -------- |
| **token_id**      | int | |
| **address**      | address | |
| **symbol**       | string  | |
| **name**         | string  | |
| **decimals**     | bigint  | |
| **is_erc20**     | boolean | |
| **is_erc721**    | boolean | |
### 4.2.2. Wallets Dim Schema
| **Column**     | **Type**    | **Designation** |
| -------------- | ----------- | --------------- |
| **wallet_id** | int | |
| **wallet** | hex_string | |
### 4.2.3. Timestamp Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | ---------------- |
| **timestamp_id** | int | |
| **timestamp_unix** | bigint | |
| **year** | int | | 
| **quarter** | int | |   
| **month** | int | |
| **day** | int | |
| **hour_12h/24h** | int | |
| **minute** | int | | 
| **second** | int | |
## 4.3. Slowly Changing Dimensions
### 4.3.1. Token Snapshot
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | -------- |
| **token_id** | int | |
| **circulating_supply** | bigint | |
# 4. Data Source
# 5. Data Staging Area
# 6. Data Warehouse
# 7. ETL
![ETL](https://github.com/aimproxy/ethereum-chain-analysis-and-data-warehouse-design/blob/main/diagrams/ETL.png?raw=true)
