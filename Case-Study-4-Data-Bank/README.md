<p align="center" width="100%">
    <img width="40%" src="../images/4.png">
</p>

Find the full case study [**here**](https://8weeksqlchallenge.com/case-study-4/).

# :books: Table of Contents <!-- omit in toc -->

- [:briefcase: Business Case](#briefcase-business-case)
- [:mag: Entity Relationship Diagram](#mag-entity-relationship-diagram)
- [:bookmark_tabs:Example Datasets](#bookmark_tabsexample-datasets)
- [:triangular_flag_on_post: Questions and Solution](#triangular_flag_on_post-questions-and-solution)
  - [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
  - [B. Customer Transactions](#b-customer-transactions)

---

# :briefcase: Business Case

There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

---

# :mag: Entity Relationship Diagram

<p align="center" width="100%">
    <img width="80%" src="../images/case-study-4-erd.png">
</p>

---

# :bookmark_tabs:Example Datasets

<div align="center">

**Table 1: regions**

| region_id | region_name |
| :-------- | :---------- |
| 1         | Africa      |
| 2         | America     |
| 3         | Asia        |
| 4         | Europe      |
| 5         | Oceania     |

</div>

<br/>

<div align="center">

**Table 2: customer_nodes**

| customer_id | region_id | node_id | start_date | end_date   |
| :---------- | :-------- | :------ | :--------- | :--------- |
| 1           | 3         | 4       | 2020-01-02 | 2020-01-03 |
| 2           | 3         | 5       | 2020-01-03 | 2020-01-17 |
| 3           | 5         | 4       | 2020-01-27 | 2020-02-18 |
| 4           | 5         | 4       | 2020-01-07 | 2020-01-19 |
| 5           | 3         | 3       | 2020-01-15 | 2020-01-23 |
| 6           | 1         | 1       | 2020-01-11 | 2020-02-06 |
| 7           | 2         | 5       | 2020-01-20 | 2020-02-04 |
| 8           | 1         | 2       | 2020-01-15 | 2020-01-28 |
| 9           | 4         | 5       | 2020-01-21 | 2020-01-25 |
| 10          | 3         | 4       | 2020-01-13 | 2020-01-14 |

</div>

<br/>

<div align="center">

**Table 2: customer_transactions**

| customer_id | txn_date   | txn_type | txn_amount |
| :---------- | :--------- | :------- | :--------- |
| 429         | 2020-01-21 | deposit  | 82         |
| 155         | 2020-01-10 | deposit  | 712        |
| 398         | 2020-01-01 | deposit  | 196        |
| 255         | 2020-01-14 | deposit  | 563        |
| 185         | 2020-01-29 | deposit  | 626        |
| 309         | 2020-01-13 | deposit  | 995        |
| 312         | 2020-01-20 | deposit  | 485        |
| 376         | 2020-01-03 | deposit  | 706        |
| 188         | 2020-01-13 | deposit  | 601        |
| 138         | 2020-01-11 | deposit  | 520        |

</div>

---

# :triangular_flag_on_post: Questions and Solution

## A. Customer Nodes Exploration

<details>
<summary>Questions</summary>

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-4-Data-Bank/Solution-A-Customer-Node.md)

## B. Customer Transactions

<details>
<summary>Questions</summary>

1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-4-Data-Bank/Solution-B-Customer-Transactions.md)
