# Ethereum Chain Analysis And Data Warehouse Design
A project to design a fact and dimension star schema for optimizing queries on a Ethereum Chain database using MSSQL (Microsoft SQL Server), a relational database management system.
The designed schema allows for efficient querying of data such as transaction dates, gas fees, and transaction volume information.
The ETL process for the Ethereum Chain Analysis is designed using Microsoft SQL Server Integration Services (SSIS).

## 1. Asks!?
- [ ] What is the total transaction volume on the eth chain over a specific time period?
- [ ] What are the most popularly exchanged digital tokens, represented by ERC-721 and ERC-20 smart contracts?
- [ ] The biggest transactions over the last 24 hours?
- [ ] Transactions with the highest gas fee over the last 24 hours?

## 2. Fact and Dimensional Tables
The star schema for the Ethereum Chain Analysis and Data Warehouse Design consists of the following dimensions and facts:

| **Facts**           | **Description**                                                                                                                                |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Fact Transactions** | To store information about individual Ethereum transactions, such as transaction hash, block hash, transaction value, and transaction gas. |
| **Fact Token Transfers** | To store information about ERC-20 token transfers, such as transfer from, transfer to, transfer value, and transfer transaction hash. |

| **Dimensions**           | **Description**                                                                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Dimension Tokens**       | To store information about ERC-20 tokens, such as token contract address, token symbol, token name, and token total supply. |
| **Dimension Timestamp** | To store timestamps for various Ethereum-related events. |
| **Dimension Addresses** | To store information about Ethereum addresses, such as address type, address balance. |

### 2.1. Star Schema as PlantUML

## 3. Schemas
### 3.1. Fact Schemas
#### 3.1.1. Transaction Fact Schema
| **Column** | **Type**| **Designation** |
|----------|-------------| -------- |
| **hash** | hex_string | |
| **nonce** | bigint | | 
| **block_hash** | hex_string | | 
| **block_number** | bigint | | 
| **transaction_index** | bigint | |
| **from_address** | address | |
| **to_address** | address | | 
| **gas** | numeric | |
| **gas_price** | bigint | |
| **input** | hex_string | |
| **block_timestamp** | bigint| |
| **max_fee_per_gas** | bigint | | 
| **max_priority_fee_per_gas** | bigint | |
| **transaction_type** | bigint | | 
#### 3.1.2. Token Transfer Fact Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | --------- | 
| **token_address** | address | | 
| **from_address** | address | | 
| **to_address**   | address | | 
| **value**        | numeric | | 
| **transaction_hash** | hex_string | |
| **log_index**    | bigint   | |
| **block_number** | bigint   | | 
### 3.2. Dimension Schemas
#### 3.2.1. Timestamp Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | ---------------- |
|timestamp_pk (Primary Key) | int | |
|timestamp_unix (Datetime) | bigint | |
| year | int | | 
| quarter| int | |   
| month| int | |
|day | int | |
| hour_12h/24h | int | |
| minute| int | | 
| second| int | | 
