<p align="center" width="100%">
    <img width="40%" src="../images/3.png">
</p>

Find the full case study [**here**](https://8weeksqlchallenge.com/case-study-3/).

# :books: Table of Contents <!-- omit in toc -->

- [:briefcase: Business Case](#briefcase-business-case)
- [:mag: Entity Relationship Diagram](#mag-entity-relationship-diagram)
- [:bookmark\_tabs:Example Datasets](#bookmark_tabsexample-datasets)
- [:triangular\_flag\_on\_post: Questions and Solution](#triangular_flag_on_post-questions-and-solution)
  - [A. Customer Journey](#a-customer-journey)
  - [B. Data Analysis](#b-data-analysis)
  - [C. Payment Challenge](#c-payment-challenge)

---

# :briefcase: Business Case

Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

---

# :mag: Entity Relationship Diagram

<p align="center" width="100%">
    <img width="80%" src="../images/case-study-3-erd.png">
</p>

---

# :bookmark_tabs:Example Datasets

<div align="center">

**Table 1: plans**

| plan_id | plan_name     | price |
| :------ | :------------ | :---- |
| 0       | trial         | 0     |
| 1       | basic monthly | 9.90  |
| 2       | pro monthly   | 19.90 |
| 3       | pro annual    | 199   |
| 4       | churn         | null  |

</div>

<br/>

<div align="center">

**Table 2: subscriptions**

| customer_id | plan_id | start_date |
| :---------- | :------ | :--------- |
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 11          | 0       | 2020-11-19 |
| 11          | 4       | 2020-11-26 |
| 13          | 0       | 2020-12-15 |
| 13          | 1       | 2020-12-22 |
| 13          | 2       | 2021-03-29 |
| 15          | 0       | 2020-03-17 |
| 15          | 2       | 2020-03-24 |
| 15          | 4       | 2020-04-29 |
| 16          | 0       | 2020-05-31 |
| 16          | 1       | 2020-06-07 |
| 16          | 3       | 2020-10-21 |
| 18          | 0       | 2020-07-06 |
| 18          | 2       | 2020-07-13 |
| 19          | 0       | 2020-06-22 |
| 19          | 2       | 2020-06-29 |
| 19          | 3       | 2020-08-29 |

</div>

---

# :triangular_flag_on_post: Questions and Solution

## A. Customer Journey

<details>
<summary>Questions</summary>

>Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
>Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-3-Foodie-Fi/Solution-A-Customer-Journey.md)

## B. Data Analysis

<details>
<summary>Questions</summary>

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of `trial` plan `start_date` values for our dataset - use the start of the month as the group by value
3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 `plan_name` values at `2020-12-31`?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-3-Foodie-Fi/Solution-B-Data-Analysis.md)

## C. Payment Challenge

<details>
<summary>Questions</summary>

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

Example outputs for this table might look like the following:

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order |
|-------------|---------|---------------|--------------|--------|---------------|
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1             |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2             |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3             |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4             |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5             |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1             |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1             |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1             |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2             |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1             |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2             |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3             |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4             |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5             |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6             |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1             |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2             |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3             |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4             |
| 18          | 2       | pro monthly   | 2020-11-13   | 19.90  | 5             |
| 18          | 2       | pro monthly   | 2020-12-13   | 19.90  | 6             |
| 19          | 2       | pro monthly   | 2020-06-29   | 19.90  | 1             |
| 19          | 2       | pro monthly   | 2020-07-29   | 19.90  | 2             |
| 19          | 3       | pro annual    | 2020-08-29   | 199.00 | 3             |

</details>

**Click** the badge below to view my solution for this set of questions.

[![badge](https://img.shields.io/badge/Solution-CLICK%20HERE!-%23fc657e?style=for-the-badge&labelColor=a91d22)](https://github.com/tfkachmad/8-Week-SQL-Challenge/blob/main/Case-Study-3-Foodie-Fi/Solution-C-Challenge-Payment.md)
