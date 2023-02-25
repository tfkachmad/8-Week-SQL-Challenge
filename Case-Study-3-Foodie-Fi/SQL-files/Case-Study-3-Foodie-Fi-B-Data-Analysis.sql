--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 3 - Foodie-Fi
-- Part B - Data Analysis Questions
--
-- 1. How many customers has Foodie-Fi ever had?
SELECT
    COUNT(DISTINCT customer_id) AS customer_total
FROM
    foodie_fi.subscriptions;

--
-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT
    TO_CHAR(start_date, 'Month') AS month_name,
    COUNT(*) AS customer_count
FROM
    foodie_fi.subscriptions
WHERE
    plan_id = (
        SELECT
            plan_id
        FROM
            foodie_fi.plans
        WHERE
            plan_name LIKE 't%')
GROUP BY
    1,
    EXTRACT('Month' FROM start_date)
ORDER BY
    EXTRACT('Month' FROM start_date);

--
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
    p.plan_name,
    COUNT(*) AS customer_count
FROM
    foodie_fi.subscriptions AS s
    JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
GROUP BY
    p.plan_id,
    p.plan_name
ORDER BY
    p.plan_id;

--
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
WITH customers AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customer_total
    FROM
        foodie_fi.subscriptions
)
SELECT
    COUNT(customer_id) AS churned_total,
    ROUND((COUNT(customer_id) / (
        SELECT
            customer_total
        FROM customers)::NUMERIC * 100), 1) AS churned_percentage
FROM
    foodie_fi.subscriptions AS s
    JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE
    p.plan_name LIKE 'c%';

--
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH customers AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customer_total
    FROM
        foodie_fi.subscriptions
),
customer_plans AS (
    SELECT
        s.customer_id,
        s.start_date,
        p.plan_name,
        p.price,
        LEAD(p.plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM
        foodie_fi.subscriptions AS s
        JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
)
SELECT
    COUNT(customer_id) AS customer_total,
    ROUND((COUNT(customer_id) / (
        SELECT
            customer_total
        FROM customers)::NUMERIC * 100)) AS customer_percentage
FROM
    customer_plans
WHERE
    plan_name LIKE 't%'
    AND next_plan LIKE 'c%';

--
-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH customer_plans AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS row_num
    FROM
        foodie_fi.subscriptions
    WHERE
        plan_id > 0
),
customers AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customer_total
    FROM
        foodie_fi.subscriptions
    WHERE
        plan_id > 0
)
SELECT
    p.plan_name,
    COUNT(*) AS customer_total,
    ROUND((100 * COUNT(*) / (
            SELECT
                customer_total
            FROM customers)::NUMERIC), 2) AS customer_pct
FROM
    customer_plans AS c
    JOIN foodie_fi.plans AS p ON c.plan_id = p.plan_id
WHERE
    c.row_num = 1
GROUP BY
    1,
    p.plan_id
ORDER BY
    p.plan_id;

--
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH customer_plans AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS row_num
    FROM
        foodie_fi.subscriptions
    WHERE
        EXTRACT('year' FROM start_date) < 2021
),
customers AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customer_total
    FROM
        foodie_fi.subscriptions
    WHERE
        EXTRACT('year' FROM start_date) < 2021
)
SELECT
    p.plan_name,
    COUNT(*) AS customer_total,
    ROUND((100 * COUNT(*) / (
            SELECT
                customer_total
            FROM customers)::NUMERIC), 2) AS customer_pct
FROM
    customer_plans AS c
    JOIN foodie_fi.plans AS p ON c.plan_id = p.plan_id
WHERE
    c.row_num = 1
GROUP BY
    p.plan_name,
    p.plan_id
ORDER BY
    p.plan_id;

--
-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT
    COUNT(*) AS customer_total
FROM
    foodie_fi.subscriptions
WHERE
    plan_id = (
        SELECT
            plan_id
        FROM
            foodie_fi.plans
        WHERE
            plan_name LIKE '%annual%')
            AND EXTRACT('YEAR' FROM start_date) < 2021;

--
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH customer_annual_plans AS (
    SELECT
        s.customer_id,
        s.start_date,
        p.plan_id,
        LEAD(p.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan,
        LEAD(s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan_start_date
    FROM
        foodie_fi.subscriptions AS s
        JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        p.plan_id IN (
            SELECT
                plan_id
            FROM
                foodie_fi.plans
            WHERE
                plan_name LIKE '%annual%'
                OR plan_name LIKE 'trial'))
SELECT
    ROUND(AVG(next_plan_start_date - start_date)) AS days
FROM
    customer_annual_plans
WHERE
    next_plan IS NOT NULL;

--
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH customer_annual_plans AS (
    SELECT
        s.customer_id,
        s.start_date,
        p.plan_id,
        LEAD(p.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan,
        LEAD(s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan_start_date
    FROM
        foodie_fi.subscriptions AS s
        JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        p.plan_id IN (
            SELECT
                plan_id
            FROM
                foodie_fi.plans
            WHERE
                plan_name LIKE '%annual%'
                OR plan_name LIKE '%trial%')
),
days_to_annual AS (
    SELECT
        (next_plan_start_date - start_date) AS days_diff
    FROM
        customer_annual_plans
    WHERE
        next_plan IS NOT NULL
),
days_interval AS (
    SELECT
        days_diff,
        CASE WHEN days_diff BETWEEN 0 AND 30 THEN
            '0-30 days'
        WHEN days_diff BETWEEN 31 AND 60 THEN
            '31-60 days'
        WHEN days_diff BETWEEN 61 AND 90 THEN
            '61-90 days'
        WHEN days_diff BETWEEN 91 AND 120 THEN
            '91-120 days'
        WHEN days_diff BETWEEN 121 AND 150 THEN
            '121-150 days'
        WHEN days_diff BETWEEN 151 AND 180 THEN
            '151-180 days'
        WHEN days_diff BETWEEN 181 AND 210 THEN
            '181-210 days'
        WHEN days_diff BETWEEN 211 AND 240 THEN
            '211 - 240 days'
        WHEN days_diff BETWEEN 241 AND 270 THEN
            '241 - 270 days'
        WHEN days_diff BETWEEN 271 AND 300 THEN
            '271 - 300 days'
        WHEN days_diff BETWEEN 301 AND 330 THEN
            '301 - 330 days'
        ELSE
            '331 - 360 days'
        END AS days_bins
    FROM
        days_to_annual
)
SELECT
    days_bins,
    ROUND(AVG(days_diff)) AS days_average
FROM
    days_interval
GROUP BY
    1
ORDER BY
    CASE WHEN days_bins = '0-30 days' THEN
        1
    WHEN days_bins = '31-60 days' THEN
        2
    WHEN days_bins = '61-90 days' THEN
        3
    WHEN days_bins = '91-120 days' THEN
        4
    WHEN days_bins = '121-150 days' THEN
        5
    WHEN days_bins = '151-180 days' THEN
        6
    WHEN days_bins = '181-210 days' THEN
        7
    WHEN days_bins = '211 - 240 days' THEN
        8
    WHEN days_bins = '241 - 270 days' THEN
        9
    WHEN days_bins = '271 - 300 days' THEN
        10
    WHEN days_bins = '301 - 330 days' THEN
        11
    ELSE
        12
    END;

--
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH customer_plans AS (
    SELECT
        s.customer_id,
        p.plan_name,
        LEAD(p.plan_name) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan
    FROM
        foodie_fi.subscriptions AS s
        JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        EXTRACT('year' FROM s.start_date) < 2021
)
SELECT
    COUNT(*) AS customer_total
FROM
    customer_plans
WHERE
    next_plan IS NOT NULL
    AND plan_name LIKE 'pro m%'
    AND next_plan LIKE 'basic m%';
