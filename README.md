# Ethereum Chain Analysis And Data Warehouse Design
A project to design a fact and dimension star schema for optimizing queries on a Ethereum Chain database using MSSQL (Microsoft SQL Server), a relational database management system.
The designed schema allows for efficient querying of data such as transaction dates, gas fees, and transaction volume information.
The ETL process for the Ethereum Chain Analysis is designed using Microsoft SQL Server Integration Services (SSIS).

## 1. Asks!?
- [ ] What is the total transaction volume on the eth chain over a specific time period?
- [ ] Transactions with the highest gas fee over the last 24 hours!
- [ ] Can you identify transactions with unusually high gas fees?
- [ ] What are the most popularly exchanged digital tokens, represented by ERC-721 and ERC-20 smart contracts?
- [ ] The biggest transactions over the last 24 hours?
- [ ] Transactions with the highest gas fee over the last 24 hours?

## 2. Fact and Dimensional Tables
The fact and dimension star schema for the Ethereum Chain Analysis and Data Warehouse Design consists of the following dimensions and facts:

| **Facts**           | **Description**                                                                                        | **Fields**                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| **Fact Transactions** | To store information about individual Ethereum transactions, such as transaction hash, block hash, transaction value, and transaction gas. | Transaction Hash, Block Hash, Transaction Value, Transaction Gas |
| **Fact Token Transfers** | To store information about ERC-20 token transfers, such as transfer from, transfer to, transfer value, and transfer transaction hash. | Transfer From, Transfer To, Transfer Value, Transfer Transaction Hash |

| **Dimensions**           | **Description**                                                                                        | **Fields**                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| **Fact Tokens**       | To store information about ERC-20 tokens, such as token contract address, token symbol, token name, and token total supply. | Token Contract Address, Token Symbol, Token Name, Token Total Supply |
| **Dimension Timestamp** | To store timestamps for various Ethereum-related events. | Timestamp Dimension ID, Timestamp, Year, Month, Day, Hour, Minute, Second, Timezone |
| **Dimension Addresses** | To store information about Ethereum addresses, such as address type, address balance, and address nonce. | Address Type, Address Balance, Address Nonce |

### 2.1. Fact and Dimensional as PlantUML

