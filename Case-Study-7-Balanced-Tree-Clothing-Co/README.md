<p align="center" width="100%">
    <img width="40%" src="../images/7.png">
</p>

Find the full case study [**here**](https://8weeksqlchallenge.com/case-study-7/).

# :books: Table of Contents <!-- omit in toc -->

- [:briefcase: Business Case](#briefcase-business-case)
- [:bookmark\_tabs:Example Datasets](#bookmark_tabsexample-datasets)
- [:triangular\_flag\_on\_post: Questions and Solution](#triangular_flag_on_post-questions-and-solution)
  - [A. High Level Sales Analysis](#a-high-level-sales-analysis)
  - [B. Transaction Analysis](#b-transaction-analysis)
  - [C. Product Analysis](#c-product-analysis)
  - [D. Reporting Challenge](#d-reporting-challenge)

---

# :briefcase: Business Case

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

---

# :bookmark_tabs:Example Datasets

<div align="center">

**Table 1: product_details**

| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name          |
| :--------- | :---- | :------------------------------- | :---------- | :--------- | :------- | :------------ | :----------- | :------------------ |
| c4a632     | 13    | Navy Oversized Jeans - Womens    | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Black Straight Jeans - Womens    | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Cream Relaxed Jeans - Womens     | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens       | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens      | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Grey Fashion Jacket - Womens     | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | White Tee Shirt - Mens           | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Teal Button Up Shirt - Mens      | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Blue Polo Shirt - Mens           | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Navy Solid Socks - Mens          | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | White Striped Socks - Mens       | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2           | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |

</div>

<br>

<div align="center">

**Table 2: sales**

| prod_id | qty  | price | discount | member | txn_id | start_txn_time           |
| :------ | :--- | :---- | :------- | :----- | :----- | :----------------------- |
| c4a632  | 4    | 13    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 5d267b  | 4    | 40    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| b9a74d  | 4    | 17    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| 2feb6b  | 2    | 29    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296  |
| c4a632  | 5    | 13    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| e31d39  | 2    | 10    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 72f5d4  | 3    | 19    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| 2a2353  | 3    | 57    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| f084eb  | 3    | 36    | 21       | t      | 26cc98 | 2021-01-19 01:39:00.3456 |
| c4a632  | 1    | 13    | 21       | f      | ef648d | 2021-01-27 02:18:17.1648 |

</div>

---

# :triangular_flag_on_post: Questions and Solution

## A. High Level Sales Analysis

<details>
<summary>Questions</summary>

1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-7-Balanced-Tree-Clothing-Co/Solution-A-High-Level-Sales.md)

## B. Transaction Analysis

<details>
<summary>Questions</summary>

1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-7-Balanced-Tree-Clothing-Co/Solution-B-Transaction-Analysis.md)

## C. Product Analysis

<details>
<summary>Questions</summary>

1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-7-Balanced-Tree-Clothing-Co/Solution-C-Product-Analysis.md)

## D. Reporting Challenge

<details>
<summary>Questions</summary>

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-7-Balanced-Tree-Clothing-Co/Solution-D-Reporting-Challenge.md)

---
