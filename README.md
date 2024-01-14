# Ethereum Chain Analysis And Data Warehouse Design
A project to design a fact and dimension star schema for optimizing queries on a Ethereum Chain database using MSSQL (Microsoft SQL Server), a relational database management system.

A data warehouse provides a consistent view of Ethereum data over time. The designed schema allows for efficient querying of data such as transaction dates, gas fees, and transaction volume information.

The ETL process for the Ethereum Chain Analysis is designed using Microsoft SQL Server Integration Services (SSIS).

# 0. Abstract
The Ethereum blockchain generates a significant amount of data due to its intrinsic transparency and decentralized nature.  It is also referred to as on-chain data and is openly accessible to the world.

A peer-to-peer network of mutually distrusting nodes maintains a common view of the global state and executes code upon request. The stated is stored in a blockchain secured by a proof-of-state consensus mechanism that work by selecting validators in proportion to their quantity of holdings.

Moreover, the on-chain data is timestamped, integrated, and validated into an open ledger. This important blockchain feature enables us to assess the network’s health and usage. It serves as a massive data warehouse for complex prediction algorithms that can effectively detect systemic trends and forecast future behavior.

# 1. Introduction
- [ ] What is the total transaction volume on the eth chain over a specific time period?
- [ ] What are the most popularly exchanged digital tokens, represented by ERC-721 and ERC-20 smart contracts?
- [ ] The biggest transactions over the last 24 hours?
- [ ] Transactions with the highest gas fee over the last 24 hours?

# 2. Data Staging Area
- [ ] Create DSA Schema
- [ ] Implement SSIS

# 3. Data Warehouse

## 3.1 Fact and Dimensional Tables
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
| **Token Snapshot** |  Slowly Changing Dimension to store circulating supply |

## 3.2. Star Schema

## 3.3. SQL Syntax
```sql
create database DataWarehouse
go

use DataWarehouse
go

CREATE TABLE DimTimestamp
(
    SurrogateKey  INT        NOT NULL
        CONSTRAINT DimTimestamp_SurrogateKey PRIMARY KEY,
    UnixTimestamp BIGINT     NOT NULL,
    HH            INT        NOT NULL CHECK (HH >= 0 AND HH <= 23),
    MM            INT        NOT NULL CHECK (MM >= 0 AND MM <= 59),
    SS            INT        NOT NULL CHECK (SS >= 0 AND SS <= 59),
    AM_PM         INT        NOT NULL CHECK (AM_PM IN (0, 1)),
    Day           INT        NOT NULL CHECK (Day >= 1 AND Day <= 31),
    Week          INT        NOT NULL CHECK (Week >= 1 AND Week <= 53),
    WeekName      VARCHAR(9) NOT NULL,
    Month         INT        NOT NULL CHECK (Month >= 1 AND Month <= 12),
    MonthName     VARCHAR(9) NOT NULL,
    Quarter       INT        NOT NULL CHECK (Quarter >= 1 AND Quarter <= 4),
    Year          INT        NOT NULL
)
go

create table DimBlock
(
    SurrogateKey     int       not null
        constraint DimBlock_SurrogateKey
            primary key,
    BlockHash        varbinary not null,
    GasLimit         bigint    not null,
    GasUsed          bigint    not null,
    TimestampKey     int       not null
        constraint DimBlock_DimTimestamp_SurrogateKey_Foreign_Key
            references DimTimestamp,
    TransactionCount bigint    not null,
    BaseFeePerGas    bigint    not null
)
go

create table DimToken
(
    Address      varbinary   not null
        constraint DimToken_Address
            unique,
    Symbol       varchar(4)  not null,
    Name         varchar(50) not null,
    Decimals     bigint      not null,
    ERC20        bit         not null,
    ERC721       bit         not null,
    SurrogateKey int         not null
        constraint DimToken_SurrogateKey_Foreign_Key
            primary key
)
go

create table DimTokenSnapshot
(
    SurrogateKey int    not null
        constraint TokenSnapshot_SurrogateKey
            primary key,
    TokenKey     int    not null
        constraint DimTokenSnapshot_DimToken_SurrogateKey_Foreign_Key
            references DimToken,
    TotalSupply  bigint not null
)
go

create table FactBalance
(
    SurrogateKey int       not null
        constraint FactBalance_SurrogateKey
            primary key,
    Address      varbinary not null,
    BalanceETH   bigint    not null,
    TimestampKey int       not null
        constraint FactBalance_DimTimestamp_SurrogateKey_Foreign_Key
            references DimTimestamp
)
go

create table FactTransaction
(
    TransactionHash binary    not null,
    BlockKey        int       not null
        constraint FactTransaction_DimBlock_SurrogateKey_Foreign_Key
            references DimBlock,
    FromAddress     varbinary not null,
    ToAddress       varbinary not null,
    TokenKey        int       not null
        constraint FactTransaction_DimToken_SurrogateKey_Foreign_Key
            references DimToken,
    ValueETH        bigint    not null,
    GasUsed         bigint    not null,
    GasPrice        bigint    not null,
    GasPaid         bigint    not null,
    TransactionType int       not null,
    SurrogateKey    int       not null
        constraint FactTransaction_SurrogateKey
            primary key
)
go
```

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

# 7. ETL
- [ ] Write queries for BigQuery
- [ ] Explain extracting process
- [ ] Draw BPMN

## 7.1 Ingestion Overview
![ETL](https://github.com/aimproxy/ethereum-chain-analysis-and-data-warehouse-design/blob/main/diagrams/ETL.png?raw=true)

# 8. Power BI

# 9. References
- [x] Design And Representation Of The Time Dimension In Enterprise Data Warehouses [spec](https://www.scitepress.org/papers/2004/26426/26426.pdf)
- [x] Ethereum: State of Knowledge and Research Perspectives [spec](https://link.springer.com/chapter/10.1007/978-3-319-75650-9_14)
- [ ] An On-Chain Analysis-Based Approach to Predict Ethereum Prices [spec](https://researchsystem.canberra.edu.au/ws/portalfiles/portal/53556322/An_On_Chain_Analysis_Based_Approach_to_Predict_Ethereum_Prices.pdf)
