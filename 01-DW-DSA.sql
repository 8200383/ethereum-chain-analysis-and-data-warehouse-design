create database DataStagingArea
go

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
