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
- [ ] Create DSA Schema
- [ ] Implement SSIS

# 3. Data Warehouse
- [ ] Put star schema here

## 3.1 Facts and Dimensions
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

## 3.2 Fact and Dimensions Specs

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

# 5. Diagrams
## 5.1. Data Warehouse Diagram
<?xml version="1.0" encoding="us-ascii" standalone="no"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" contentStyleType="text/css" height="893px" preserveAspectRatio="none" style="width:773px;height:893px;background:#FFFFFF;" version="1.1" viewBox="0 0 773 893" width="773px" zoomAndPan="magnify"><defs/><g><!--class DimBlock--><g id="elem_DimBlock"><rect codeLine="2" fill="#F1F1F1" height="178.3477" id="DimBlock" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="167" x="210" y="339"/><ellipse cx="260.25" cy="355" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M263.0156,350.875 Q263.1719,350.6563 263.3594,350.5469 Q263.5469,350.4375 263.7656,350.4375 Q264.1406,350.4375 264.375,350.7031 Q264.6094,350.9531 264.6094,351.5625 L264.6094,353.0156 Q264.6094,353.625 264.375,353.8906 Q264.1406,354.1563 263.7656,354.1563 Q263.4219,354.1563 263.2188,353.9531 Q263.0156,353.7656 262.9063,353.25 Q262.8594,352.8906 262.6719,352.7031 Q262.3438,352.3281 261.7344,352.1094 Q261.125,351.8906 260.5,351.8906 Q259.7344,351.8906 259.0938,352.2188 Q258.4688,352.5469 257.9688,353.2969 Q257.4844,354.0469 257.4844,355.0781 L257.4844,356.1719 Q257.4844,357.4063 258.375,358.2344 Q259.2656,359.0469 260.8594,359.0469 Q261.7969,359.0469 262.4531,358.7969 Q262.8438,358.6406 263.2656,358.2031 Q263.5313,357.9375 263.6719,357.8594 Q263.8281,357.7813 264.0313,357.7813 Q264.3594,357.7813 264.6094,358.0469 Q264.875,358.2969 264.875,358.6406 Q264.875,358.9844 264.5313,359.3906 Q264.0313,359.9688 263.2344,360.2969 Q262.1563,360.75 260.8594,360.75 Q259.3438,360.75 258.1406,360.125 Q257.1563,359.625 256.4688,358.5625 Q255.7813,357.4844 255.7813,356.2031 L255.7813,355.0469 Q255.7813,353.7188 256.3906,352.5781 Q257.0156,351.4219 258.1094,350.8125 Q259.2031,350.1875 260.4375,350.1875 Q261.1719,350.1875 261.8125,350.3594 Q262.4688,350.5156 263.0156,350.875 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="58" x="280.75" y="360.7969">DimBlock</text><line style="stroke:#181818;stroke-width:0.5;" x1="211" x2="376" y1="371" y2="371"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="97" x="216" y="390.1074">GasLimit: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="100" x="216" y="408.7285">GasUsed: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="116" x="216" y="427.3496">TimestampKey: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="155" x="216" y="445.9707">TransactionCount: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="147" x="216" y="464.5918">BaseFeePerGas: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="216" y="483.2129">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="211" x2="376" y1="490.7266" y2="490.7266"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="151" x="216" y="509.834">BlockHash: varbinary(1)</text></g><!--class DimTimestamp--><g id="elem_DimTimestamp"><rect codeLine="11" fill="#F1F1F1" height="290.0742" id="DimTimestamp" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="161" x="107" y="596"/><ellipse cx="138.2" cy="612" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M140.9656,607.875 Q141.1219,607.6563 141.3094,607.5469 Q141.4969,607.4375 141.7156,607.4375 Q142.0906,607.4375 142.325,607.7031 Q142.5594,607.9531 142.5594,608.5625 L142.5594,610.0156 Q142.5594,610.625 142.325,610.8906 Q142.0906,611.1563 141.7156,611.1563 Q141.3719,611.1563 141.1688,610.9531 Q140.9656,610.7656 140.8563,610.25 Q140.8094,609.8906 140.6219,609.7031 Q140.2938,609.3281 139.6844,609.1094 Q139.075,608.8906 138.45,608.8906 Q137.6844,608.8906 137.0438,609.2188 Q136.4188,609.5469 135.9188,610.2969 Q135.4344,611.0469 135.4344,612.0781 L135.4344,613.1719 Q135.4344,614.4063 136.325,615.2344 Q137.2156,616.0469 138.8094,616.0469 Q139.7469,616.0469 140.4031,615.7969 Q140.7938,615.6406 141.2156,615.2031 Q141.4813,614.9375 141.6219,614.8594 Q141.7781,614.7813 141.9813,614.7813 Q142.3094,614.7813 142.5594,615.0469 Q142.825,615.2969 142.825,615.6406 Q142.825,615.9844 142.4813,616.3906 Q141.9813,616.9688 141.1844,617.2969 Q140.1063,617.75 138.8094,617.75 Q137.2938,617.75 136.0906,617.125 Q135.1063,616.625 134.4188,615.5625 Q133.7313,614.4844 133.7313,613.2031 L133.7313,612.0469 Q133.7313,610.7188 134.3406,609.5781 Q134.9656,608.4219 136.0594,607.8125 Q137.1531,607.1875 138.3875,607.1875 Q139.1219,607.1875 139.7625,607.3594 Q140.4188,607.5156 140.9656,607.875 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="93" x="155.8" y="617.7969">DimTimestamp</text><line style="stroke:#181818;stroke-width:0.5;" x1="108" x2="267" y1="628" y2="628"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="137" x="113" y="647.1074">UnixTimestamp: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="41" x="113" y="665.7285">HH: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="45" x="113" y="684.3496">MM: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="41" x="113" y="702.9707">SS: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="71" x="113" y="721.5918">AM_PM: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="48" x="113" y="740.2129">Day: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="59" x="113" y="758.834">Week: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="62" x="113" y="777.4551">Month: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="72" x="113" y="796.0762">Quarter: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="53" x="113" y="814.6973">Year: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="113" y="833.3184">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="108" x2="267" y1="840.832" y2="840.832"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="146" x="113" y="859.9395">WeekName: varchar(9)</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="149" x="113" y="878.5605">MonthName: varchar(9)</text></g><!--class DimToken--><g id="elem_DimToken"><rect codeLine="26" fill="#F1F1F1" height="178.3477" id="DimToken" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="149" x="497" y="339"/><ellipse cx="535.85" cy="355" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M538.6156,350.875 Q538.7719,350.6563 538.9594,350.5469 Q539.1469,350.4375 539.3656,350.4375 Q539.7406,350.4375 539.975,350.7031 Q540.2094,350.9531 540.2094,351.5625 L540.2094,353.0156 Q540.2094,353.625 539.975,353.8906 Q539.7406,354.1563 539.3656,354.1563 Q539.0219,354.1563 538.8188,353.9531 Q538.6156,353.7656 538.5063,353.25 Q538.4594,352.8906 538.2719,352.7031 Q537.9438,352.3281 537.3344,352.1094 Q536.725,351.8906 536.1,351.8906 Q535.3344,351.8906 534.6938,352.2188 Q534.0688,352.5469 533.5688,353.2969 Q533.0844,354.0469 533.0844,355.0781 L533.0844,356.1719 Q533.0844,357.4063 533.975,358.2344 Q534.8656,359.0469 536.4594,359.0469 Q537.3969,359.0469 538.0531,358.7969 Q538.4438,358.6406 538.8656,358.2031 Q539.1313,357.9375 539.2719,357.8594 Q539.4281,357.7813 539.6313,357.7813 Q539.9594,357.7813 540.2094,358.0469 Q540.475,358.2969 540.475,358.6406 Q540.475,358.9844 540.1313,359.3906 Q539.6313,359.9688 538.8344,360.2969 Q537.7563,360.75 536.4594,360.75 Q534.9438,360.75 533.7406,360.125 Q532.7563,359.625 532.0688,358.5625 Q531.3813,357.4844 531.3813,356.2031 L531.3813,355.0469 Q531.3813,353.7188 531.9906,352.5781 Q532.6156,351.4219 533.7094,350.8125 Q534.8031,350.1875 536.0375,350.1875 Q536.7719,350.1875 537.4125,350.3594 Q538.0688,350.5156 538.6156,350.875 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="64" x="555.15" y="360.7969">DimToken</text><line style="stroke:#181818;stroke-width:0.5;" x1="498" x2="645" y1="371" y2="371"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="99" x="503" y="390.1074">Decimals: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="68" x="503" y="408.7285">ERC20: bit</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="76" x="503" y="427.3496">ERC721: bit</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="503" y="445.9707">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="498" x2="645" y1="453.4844" y2="453.4844"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="137" x="503" y="472.5918">Address: varbinary(1)</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="120" x="503" y="491.2129">Symbol: varchar(4)</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="118" x="503" y="509.834">Name: varchar(50)</text></g><!--class DimTokenSnapshot--><g id="elem_DimTokenSnapshot"><rect codeLine="35" fill="#F1F1F1" height="103.8633" id="DimTokenSnapshot" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="156" x="579.5" y="81.5"/><ellipse cx="594.5" cy="97.5" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M597.2656,93.375 Q597.4219,93.1563 597.6094,93.0469 Q597.7969,92.9375 598.0156,92.9375 Q598.3906,92.9375 598.625,93.2031 Q598.8594,93.4531 598.8594,94.0625 L598.8594,95.5156 Q598.8594,96.125 598.625,96.3906 Q598.3906,96.6563 598.0156,96.6563 Q597.6719,96.6563 597.4688,96.4531 Q597.2656,96.2656 597.1563,95.75 Q597.1094,95.3906 596.9219,95.2031 Q596.5938,94.8281 595.9844,94.6094 Q595.375,94.3906 594.75,94.3906 Q593.9844,94.3906 593.3438,94.7188 Q592.7188,95.0469 592.2188,95.7969 Q591.7344,96.5469 591.7344,97.5781 L591.7344,98.6719 Q591.7344,99.9063 592.625,100.7344 Q593.5156,101.5469 595.1094,101.5469 Q596.0469,101.5469 596.7031,101.2969 Q597.0938,101.1406 597.5156,100.7031 Q597.7813,100.4375 597.9219,100.3594 Q598.0781,100.2813 598.2813,100.2813 Q598.6094,100.2813 598.8594,100.5469 Q599.125,100.7969 599.125,101.1406 Q599.125,101.4844 598.7813,101.8906 Q598.2813,102.4688 597.4844,102.7969 Q596.4063,103.25 595.1094,103.25 Q593.5938,103.25 592.3906,102.625 Q591.4063,102.125 590.7188,101.0625 Q590.0313,99.9844 590.0313,98.7031 L590.0313,97.5469 Q590.0313,96.2188 590.6406,95.0781 Q591.2656,93.9219 592.3594,93.3125 Q593.4531,92.6875 594.6875,92.6875 Q595.4219,92.6875 596.0625,92.8594 Q596.7188,93.0156 597.2656,93.375 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="124" x="608.5" y="103.2969">DimTokenSnapshot</text><line style="stroke:#181818;stroke-width:0.5;" x1="580.5" x2="734.5" y1="113.5" y2="113.5"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="87" x="585.5" y="132.6074">TokenKey: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="117" x="585.5" y="151.2285">TotalSupply: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="585.5" y="169.8496">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="580.5" x2="734.5" y1="177.3633" y2="177.3633"/></g><!--class FactBalance--><g id="elem_FactBalance"><rect codeLine="40" fill="#F1F1F1" height="122.4844" id="FactBalance" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="149" x="7" y="367"/><ellipse cx="39.1" cy="383" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M41.8656,378.875 Q42.0219,378.6563 42.2094,378.5469 Q42.3969,378.4375 42.6156,378.4375 Q42.9906,378.4375 43.225,378.7031 Q43.4594,378.9531 43.4594,379.5625 L43.4594,381.0156 Q43.4594,381.625 43.225,381.8906 Q42.9906,382.1563 42.6156,382.1563 Q42.2719,382.1563 42.0688,381.9531 Q41.8656,381.7656 41.7563,381.25 Q41.7094,380.8906 41.5219,380.7031 Q41.1938,380.3281 40.5844,380.1094 Q39.975,379.8906 39.35,379.8906 Q38.5844,379.8906 37.9438,380.2188 Q37.3188,380.5469 36.8188,381.2969 Q36.3344,382.0469 36.3344,383.0781 L36.3344,384.1719 Q36.3344,385.4063 37.225,386.2344 Q38.1156,387.0469 39.7094,387.0469 Q40.6469,387.0469 41.3031,386.7969 Q41.6938,386.6406 42.1156,386.2031 Q42.3813,385.9375 42.5219,385.8594 Q42.6781,385.7813 42.8813,385.7813 Q43.2094,385.7813 43.4594,386.0469 Q43.725,386.2969 43.725,386.6406 Q43.725,386.9844 43.3813,387.3906 Q42.8813,387.9688 42.0844,388.2969 Q41.0063,388.75 39.7094,388.75 Q38.1938,388.75 36.9906,388.125 Q36.0063,387.625 35.3188,386.5625 Q34.6313,385.4844 34.6313,384.2031 L34.6313,383.0469 Q34.6313,381.7188 35.2406,380.5781 Q35.8656,379.4219 36.9594,378.8125 Q38.0531,378.1875 39.2875,378.1875 Q40.0219,378.1875 40.6625,378.3594 Q41.3188,378.5156 41.8656,378.875 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="79" x="56.9" y="388.7969">FactBalance</text><line style="stroke:#181818;stroke-width:0.5;" x1="8" x2="155" y1="399" y2="399"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="120" x="13" y="418.1074">BalanceETH: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="116" x="13" y="436.7285">TimestampKey: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="13" y="455.3496">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="8" x2="155" y1="462.8633" y2="462.8633"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="137" x="13" y="481.9707">Address: varbinary(1)</text></g><!--class FactTransaction--><g id="elem_FactTransaction"><rect codeLine="46" fill="#F1F1F1" height="252.832" id="FactTransaction" rx="2.5" ry="2.5" style="stroke:#181818;stroke-width:0.5;" width="184" x="280.5" y="7"/><ellipse cx="317.55" cy="23" fill="#ADD1B2" rx="11" ry="11" style="stroke:#181818;stroke-width:1.0;"/><path d="M320.3156,18.875 Q320.4719,18.6563 320.6594,18.5469 Q320.8469,18.4375 321.0656,18.4375 Q321.4406,18.4375 321.675,18.7031 Q321.9094,18.9531 321.9094,19.5625 L321.9094,21.0156 Q321.9094,21.625 321.675,21.8906 Q321.4406,22.1563 321.0656,22.1563 Q320.7219,22.1563 320.5188,21.9531 Q320.3156,21.7656 320.2063,21.25 Q320.1594,20.8906 319.9719,20.7031 Q319.6438,20.3281 319.0344,20.1094 Q318.425,19.8906 317.8,19.8906 Q317.0344,19.8906 316.3938,20.2188 Q315.7688,20.5469 315.2688,21.2969 Q314.7844,22.0469 314.7844,23.0781 L314.7844,24.1719 Q314.7844,25.4063 315.675,26.2344 Q316.5656,27.0469 318.1594,27.0469 Q319.0969,27.0469 319.7531,26.7969 Q320.1438,26.6406 320.5656,26.2031 Q320.8313,25.9375 320.9719,25.8594 Q321.1281,25.7813 321.3313,25.7813 Q321.6594,25.7813 321.9094,26.0469 Q322.175,26.2969 322.175,26.6406 Q322.175,26.9844 321.8313,27.3906 Q321.3313,27.9688 320.5344,28.2969 Q319.4563,28.75 318.1594,28.75 Q316.6438,28.75 315.4406,28.125 Q314.4563,27.625 313.7688,26.5625 Q313.0813,25.4844 313.0813,24.2031 L313.0813,23.0469 Q313.0813,21.7188 313.6906,20.5781 Q314.3156,19.4219 315.4094,18.8125 Q316.5031,18.1875 317.7375,18.1875 Q318.4719,18.1875 319.1125,18.3594 Q319.7688,18.5156 320.3156,18.875 Z " fill="#000000"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="103" x="336.45" y="28.7969">FactTransaction</text><line style="stroke:#181818;stroke-width:0.5;" x1="281.5" x2="463.5" y1="39" y2="39"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="81" x="286.5" y="58.1074">BlockKey: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="87" x="286.5" y="76.7285">TokenKey: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="105" x="286.5" y="95.3496">ValueETH: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="100" x="286.5" y="113.9707">GasUsed: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="100" x="286.5" y="132.5918">GasPrice: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="96" x="286.5" y="151.2129">GasPaid: bigint</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="130" x="286.5" y="169.834">TransactionType: int</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="110" x="286.5" y="188.4551">SurrogateKey: int</text><line style="stroke:#181818;stroke-width:0.5;" x1="281.5" x2="463.5" y1="195.9688" y2="195.9688"/><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="172" x="286.5" y="215.0762">TransactionHash: binary(1)</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="170" x="286.5" y="233.6973">FromAddress: varbinary(1)</text><text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="154" x="286.5" y="252.3184">ToAddress: varbinary(1)</text></g><!--link DimBlock to DimTimestamp--><g id="link_DimBlock_DimTimestamp"><path codeLine="60" d="M269.7,517.06 C264.92,533.41 259.75,550.29 254.5,566 C251.27,575.67 253.8881,568.6537 250.3181,578.6237 " fill="none" id="DimBlock-to-DimTimestamp" style="stroke:#595959;stroke-width:1.0;"/><polygon fill="none" points="244.25,595.57,255.9668,580.6463,244.6693,576.601,244.25,595.57" style="stroke:#595959;stroke-width:1.0;"/><text fill="#000000" font-family="sans-serif" font-size="13" lengthAdjust="spacing" textLength="170" x="261.5" y="562.0283">TimestampKey:SurrogateKey</text></g><!--link DimTokenSnapshot to DimToken--><g id="link_DimTokenSnapshot_DimToken"><path codeLine="61" d="M648.26,185.84 C641.41,220.9 631.09,268.22 618.5,309 C615.48,318.8 618.1906,312.028 614.5206,322.048 " fill="none" id="DimTokenSnapshot-to-DimToken" style="stroke:#595959;stroke-width:1.0;"/><polygon fill="none" points="608.33,338.95,620.1546,324.1116,608.8867,319.9845,608.33,338.95" style="stroke:#595959;stroke-width:1.0;"/><text fill="#000000" font-family="sans-serif" font-size="13" lengthAdjust="spacing" textLength="141" x="624.5" y="305.0283">TokenKey:SurrogateKey</text></g><!--link FactBalance to DimTimestamp--><g id="link_FactBalance_DimTimestamp"><path codeLine="62" d="M69.83,489.04 C67.3,513.36 67.23,541.45 74.5,566 C81.71,590.35 84.2509,599.05 97.5809,621.24 " fill="none" id="FactBalance-to-DimTimestamp" style="stroke:#595959;stroke-width:1.0;"/><polygon fill="none" points="106.85,636.67,102.7242,618.1503,92.4376,624.3297,106.85,636.67" style="stroke:#595959;stroke-width:1.0;"/><text fill="#000000" font-family="sans-serif" font-size="13" lengthAdjust="spacing" textLength="170" x="75.5" y="562.0283">TimestampKey:SurrogateKey</text></g><!--link FactTransaction to DimBlock--><g id="link_FactTransaction_DimBlock"><path codeLine="63" d="M299.91,260.22 C296.17,270.09 292.96,280.08 290.5,290 C286.64,305.59 285.3477,304.4828 285.0577,320.9128 " fill="none" id="FactTransaction-to-DimBlock" style="stroke:#595959;stroke-width:1.0;"/><polygon fill="none" points="284.74,338.91,291.0567,321.0187,279.0586,320.8069,284.74,338.91" style="stroke:#595959;stroke-width:1.0;"/><text fill="#000000" font-family="sans-serif" font-size="13" lengthAdjust="spacing" textLength="139" x="291.5" y="305.0283">BlockKey:SurrogateKey</text></g><!--link FactTransaction to DimToken--><g id="link_FactTransaction_DimToken"><path codeLine="64" d="M436.39,260.01 C446.23,276.84 456.72,293.6 467.5,309 C476.42,321.75 475.0045,320.8538 485.3245,333.2338 " fill="none" id="FactTransaction-to-DimToken" style="stroke:#595959;stroke-width:1.0;"/><polygon fill="none" points="496.85,347.06,489.9332,329.392,480.7158,337.0757,496.85,347.06" style="stroke:#595959;stroke-width:1.0;"/><text fill="#000000" font-family="sans-serif" font-size="13" lengthAdjust="spacing" textLength="141" x="468.5" y="305.0283">TokenKey:SurrogateKey</text></g><!--SRC=[hLHTIyCm57tVhmZwCi71DXoolUtJWKwctHGHbRlkieQbIKbIiOZ_tRLTqsRVYEbBxaauzzoJU-ioK8hqgDzXmbsIxn8X9DaEGNajyWboHZd8g5oxY8zkGDrHd-eMcT45vNgDJHNEYz24-gWq-C4jHYsIWHAu0bTJmRiYv1P71nGE4CSeLsp50oUKKYn0es7wARcPPfCcrJtbzCj0HPBXq8WOZSpMSSosFVeOvmSzo4K_8owju1vyJ7nnFP3bPkBAI73jvIdYQDUrXn2aHcaklY3amU52nH9vMcHxFfUerFRJE94_4opFUPMWjev6DG5xw58Vc6Lq_x5RhyP05btNQoOyBixX42XFw5Ha0bblBpGm9mm25ftskeDLetI00NVnIDthM_t9y6W77avNwCzr5JcGJeETDvwI8lj02d-loeauSBHXrXEmSBEU7KEsWiQIkhY90RLdCQzY4WLuq8oI-H6OLNazRpJZxp9WGFbRvPtOenUl5Zcp32zodvMsUcGlQTBcsOf9Csjimc9p_9lApHROIseRj28rdV17mXFB_WK0]--></g></svg>

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
