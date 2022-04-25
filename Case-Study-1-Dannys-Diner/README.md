<p align="center" width="100%">
    <img width="40%" src="../images/1.png">
</p>

Find the full case study [**here**](https://8weeksqlchallenge.com/case-study-1/).

# :books: Table of Contents <!-- omit in toc -->

- [:briefcase: Business Case](#briefcase-business-case)
- [:mag: Entity Relationship Diagram](#mag-entity-relationship-diagram)
- [:bookmark_tabs:Example Datasets](#bookmark_tabsexample-datasets)
- [:pencil: Questions and Solution](#pencil-questions-and-solution)

---

# :briefcase: Business Case

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

---

# :mag: Entity Relationship Diagram

<p align="center" width="100%">
    <img width="80%" src="../images/case-study-1-erd.png">
</p>

---

# :bookmark_tabs:Example Datasets

<div align="center">

**Table 1: Sales**

| customer_id | order_date | product_id |
| :---------- | :--------- | :--------- |
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

</div>

<br>

<div align="center">

**Table 2: Menu**

| product_id | product_name | price |
| :--------- | :----------- | :---- |
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

</div>

<br>

<div align="center">

**Table 3: Member**

| customer_id | join_date  |
| :---------- | :--------- |
| A           | 2021-01-07 |
| B           | 2021-01-09 |

</div>

---

# :pencil: Questions and Solution

<details>
<summary>Questions</summary>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

</details>

**Click** the badge below to view my solution for this case study.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-1-Dannys-Diner/Solution.md)
