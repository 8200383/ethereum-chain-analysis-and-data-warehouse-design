# Ethereum Chain Analysis And Data Warehouse Design
A project to design a fact and dimension star schema for optimizing queries on a Ethereum Chain database using MSSQL (Microsoft SQL Server), a relational database management system.

A data warehouse provides a consistent view of Ethereum data over time. The designed schema allows for efficient querying of data such as transaction dates, gas fees, and transaction volume information.

The ETL process for the Ethereum Chain Analysis is designed using Microsoft SQL Server Integration Services (SSIS).

# 0. Abstract
The Ethereum blockchain generates a significant amount of data due to its intrinsic transparency and decentralized nature.  It is also referred to as on-chain data and is openly accessible to the world.

A peer-to-peer network of mutually distrusting nodes maintains a common view of the global state and executes code upon request. The stated is stored in a blockchain secured by a proof-of-state consensus mechanism that work by selecting validators in proportion to their quantity of holdings.

Moreover, the on-chain data is timestamped, integrated, and validated into an open ledger. This important blockchain feature enables us to assess the network’s health and usage. It serves as a massive data warehouse for complex prediction algorithms, network adoption and much more.

# 1. Introduction

On-chain metrics such as active addresses, total addresses and transaction volume indicate the usage and adoption of the network.

- [ ] What is the total transaction volume on the eth chain over a specific time period?
- [ ] What are the most popularly exchanged digital tokens, represented by ERC-721 and ERC-20 smart contracts?
- [ ] The biggest transactions over the last 24 hours?
- [ ] Transactions with the highest gas fee over the last 24 hours?

# 2. Data Staging Area
- [ ] Implement SSIS
## 2.1. 
![ETL](diagrams/Diagram2.png)

# 3. Data Warehouse
![Data Warehouse Diagram](diagrams/data_warehouse.svg)

## 3.1 Facts and Dimensions
The star schema for the Ethereum Chain Analysis and Data Warehouse Design consists of the following dimensions and facts:

| **Facts**           | **Description**                                                                                                                                |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Transaction** | To store information about individual Ethereum transactions, such as transaction hash, block hash, transaction value, and transaction gas. |
| **Balance** | To store information about an address' balance at a given time. |

| **Dimensions**           | **Description**                                                                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------|
| **Token**       | To store information about ERC-20 tokens, such as token contract address, token symbol, token name, and token total supply. |
| **Timestamp** | To store timestamps for various Ethereum-related events. |
| **Token Snapshot** |  Slowly Changing Dimension to store circulating supply. |
| **Block** | An Ethereum block that stores Ethereum transactions and defines the gas fee for the next block. |

## 3.2 Fact Specs
### 3.2.1. Transaction Fact Schema
| **Column** | **Type**| **Designation** |
|----------|-------------| -------- |
| **SurrogateKey** | int | Dimension | 
| **BlockKey** | int | Dimension |
| **TokenKey** | int | Dimension | 
| **TimeStampKey** | bigint | Dimension | 
| **TransactionHash** | binary(1) | Degenerated Dimension|
| **FromAddress** | varbinary(1) | Degenerated Dimension |
| **ToAddress** | varbinary(1) | Degenerated Dimension | 
| **ValueETH** | bigint | Metric |
| **GasUsed** | bigint | Metric |
| **GasPrice** | bigint| Metric |
| **GasPaid** | bigint | Metric |
| **TransactionType** | int | | 
### 3.2.2. Balance Fact Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | --------- | 
| **SurrogateKey** | int | Dimension | 
| **TimestampKey** | int | Dimension | 
| **Address** | varbinary(1) | Degenerated Dimension | 
| **BalanceETH**   | bigint | Metric |
## 3.3. Dimension Specs
### 3.3.1. Token Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | -------- |
| **SurrogateKey**      | int | - |
| **Address**      | varbinary(1) |  |
| **Symbol**       | varchar(4)  | |
| **Name** | varchar(50) | |
| **Decimals** | bigint | |
| **ERC20** | bit | |
| **ERC721** | bit | |
### 3.3.2. Timestamp Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | ---------------- |
| **SurrogateKey** | int | - |
| **UnixTimestamp** | bigint | |
| **HH** | int | | 
| **MM** | int | |   
| **SS** | int | |
| **AM_PM** | int | |
| **Day** | int | |
| **Week** | int | | 
| **WeekName** | varchar(9) | |
| **Month** | int | |
| **MonthName** | varchar(9) | |
| **Quarter** | int | |
| **Year** | int | |
### 3.3.3. Block Dim Schema
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | ---------------- |
| **SurrogateKey** | int | - |
| **TimestampKey** | int | Dimension |
| **BlockHash** | varbinary(1) | Degenerated Dimension |
| **GasLimit** | bigint | Metric |
| **GasUsed** | bigint | Metric |
| **TransactionCount** | bigint | Metric |
| **BaseFeePerGas** | bigint | Metric |
### 3.4. Slowly Changing Dimensions
#### 3.4.1. Token Snapshot
| **Column**       | **Type**    | **Designation** |
| --------------   | ----------- | -------- |
| **SurrogateKey** | int | - |
| **TokenKey** | int | Dimension |
| **TotalSupply** | bigint | Metric |

## 3.5. SQL Syntax
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

# 5. Diagrams
## 5.1. Data Warehouse Diagram

# 6. Power BI

# 7. References
- [x] Design And Representation Of The Time Dimension In Enterprise Data Warehouses [spec](https://www.scitepress.org/papers/2004/26426/26426.pdf)
- [x] Ethereum: State of Knowledge and Research Perspectives [spec](https://link.springer.com/chapter/10.1007/978-3-319-75650-9_14)
- [ ] An On-Chain Analysis-Based Approach to Predict Ethereum Prices [spec](https://researchsystem.canberra.edu.au/ws/portalfiles/portal/53556322/An_On_Chain_Analysis_Based_Approach_to_Predict_Ethereum_Prices.pdf)
