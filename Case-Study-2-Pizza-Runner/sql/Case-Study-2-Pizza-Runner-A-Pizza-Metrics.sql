--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 2 - Pizza Runner
-- Part A - Pizza Metrics
--
-- 1. How many pizzas were ordered?
SELECT
    COUNT(order_id) AS orders_num
FROM
    pizza_runner.customer_orders_clean;

--
-- 2. How many unique customer orders were made?
SELECT
    COUNT(DISTINCT customer_id) AS customer_num
FROM
    pizza_runner.customer_orders_clean;

--
-- 3. How many successful orders were delivered by each runner?
SELECT
    runner_id,
    COUNT(order_id) AS orders_num
FROM
    pizza_runner.runner_orders_clean
WHERE
    cancellation IS NULL
GROUP BY
    1
ORDER BY
    1;

--
-- 4. How many of each type of pizza was delivered?
SELECT
    pizza_name,
    COUNT(order_id) AS pizza_num
FROM
    pizza_runner.customer_orders_clean AS c
    JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
GROUP BY
    1;

--
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    customer_id,
    COUNT(
        CASE WHEN p.pizza_name = 'Meatlovers' THEN
            1
        ELSE
            NULL
        END) AS meatlovers_total,
    COUNT(
        CASE WHEN p.pizza_name = 'Vegetarian' THEN
            1
        ELSE
            NULL
        END) AS vegetarian_total
FROM
    pizza_runner.customer_orders_clean AS c
    JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
GROUP BY
    1
ORDER BY
    1;

--
-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
    order_id,
    COUNT(order_id) AS pizza_num
FROM
    pizza_runner.customer_orders_clean
GROUP BY
    order_id
ORDER BY
    COUNT(order_id) DESC
LIMIT 1;

--
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
    customer_id,
    SUM(
        CASE WHEN exclusions IS NOT NULL
            OR extras IS NOT NULL THEN
            1
        ELSE
            0
        END) AS pizza_had_change_num,
    SUM(
        CASE WHEN exclusions IS NULL
            AND extras IS NULL THEN
            1
        ELSE
            0
        END) AS pizza_no_change_num
FROM
    pizza_runner.customer_orders_clean
GROUP BY
    1
ORDER BY
    1;

--
-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    SUM(
        CASE WHEN exclusions IS NOT NULL
            AND extras IS NOT NULL THEN
            1
        ELSE
            0
        END) AS pizza_num
FROM
    pizza_runner.customer_orders_clean;

--
-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    EXTRACT(HOUR FROM order_time) AS hour,
    COUNT(order_id) AS orders_total
FROM
    pizza_runner.customer_orders_clean
GROUP BY
    1
ORDER BY
    1;

--
-- 10. What was the volume of orders for each day of the week?
SELECT
    TO_CHAR(order_time, 'Day') AS day_of_week,
    COUNT(order_id) AS orders_total
FROM
    pizza_runner.customer_orders_clean
GROUP BY
    1,
    EXTRACT('dow' FROM order_time)
ORDER BY
    EXTRACT('dow' FROM order_time);
