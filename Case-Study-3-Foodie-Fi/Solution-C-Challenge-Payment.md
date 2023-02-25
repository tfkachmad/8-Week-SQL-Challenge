# :avocado: Case Study 3 - Foodie-Fi: Solution B. Data Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:

- monthly payments always occur on the same day of month as the original `start_date` of any monthly paid plan
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

Query:

```sql
WITH RECURSIVE customer_plans (
    customer_id,
    plan_id,
    plan_name,
    start_date,
    leading_plan_start_date
) AS (
    SELECT
        s.customer_id,
        p.plan_id,
        p.plan_name,
        s.start_date::TIMESTAMP,
        LEAD(s.start_date, 1, '2020-12-31') OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS leading_plan_start_date
    FROM
        foodie_fi.subscriptions AS s
        JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id

    UNION ALL

    SELECT
        customer_id,
        plan_id,
        plan_name,
        CASE WHEN plan_name LIKE '%monthly' THEN
            start_date + INTERVAL '1 month'
        ELSE
            '2021-01-01'
        END,
        leading_plan_start_date
    FROM
        customer_plans
        WHERE
            start_date + INTERVAL '1 month' < leading_plan_start_date
            AND start_date < '2020-12-31'
),
plans_price AS (
    SELECT
        c.customer_id,
        c.plan_id,
        c.plan_name,
        c.start_date,
        p.price AS plan_price,
        LAG(c.plan_name) OVER (PARTITION BY c.customer_id ORDER BY c.start_date) AS lagging_plan_name,
        LAG(p.price) OVER (PARTITION BY c.customer_id ORDER BY c.start_date) AS lagging_plan_price
    FROM
        customer_plans AS c
        JOIN foodie_fi.plans AS p ON c.plan_id = p.plan_id
    WHERE
        EXTRACT('YEAR' FROM start_date) < '2021'
        AND c.plan_name NOT IN ('trial', 'churn')
)
SELECT
    customer_id,
    plan_id,
    plan_name,
    start_date AS payment_date,
    CASE WHEN lagging_plan_name LIKE 'basic%'
        AND plan_name LIKE 'pro%' THEN
        (plan_price - lagging_plan_price)
    ELSE
        plan_price
    END AS amount
FROM
    plans_price
ORDER BY
    customer_id,
    start_date;
```
