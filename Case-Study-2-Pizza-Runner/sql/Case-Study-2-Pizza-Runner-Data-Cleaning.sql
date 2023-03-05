SET search_path = pizza_runner;

-- Cleaning customer_orders table
DROP TABLE IF EXISTS customer_orders_clean;

CREATE TABLE customer_orders_clean (
    unique_id INTEGER,
    order_id INTEGER,
    customer_id INTEGER,
    pizza_id INTEGER,
    exclusions VARCHAR(4),
    extras VARCHAR(4),
    order_time TIMESTAMP
);

INSERT INTO customer_orders_clean (unique_id, order_id, customer_id, pizza_id, exclusions, extras, order_time)
SELECT
    ROW_NUMBER() OVER (ORDER BY order_id),
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IN ('', 'null', NULL) THEN
        NULL
    ELSE
        exclusions
    END AS exclusions,
    CASE WHEN extras IN ('', 'null', NULL) THEN
        NULL
    ELSE
        extras
    END AS extras,
    order_time
FROM
    customer_orders;

--
-- Cleaning runner_orders table
DROP TABLE IF EXISTS runner_orders_clean;

CREATE TABLE runner_orders_clean (
    order_id INTEGER,
    runner_id INTEGER,
    pickup_time TIMESTAMP,
    distance FLOAT,
    duration INTEGER,
    cancellation VARCHAR(23)
);

INSERT INTO runner_orders_clean (order_id, runner_id, pickup_time, distance, duration, cancellation)
SELECT
    order_id,
    runner_id,
    CASE WHEN pickup_time IN ('', 'null', NULL) THEN
        NULL
    ELSE
        pickup_time::TIMESTAMP
    END AS pickup_time2,
    CASE WHEN distance IN ('', 'null', NULL) THEN
        NULL
    ELSE
        TRIM(REPLACE(distance, 'km', ''))::FLOAT
    END AS distance2,
    CASE WHEN duration IN ('', 'null', NULL) THEN
        NULL
    ELSE
        TRIM(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'minute', ''), 'mins', ''))::INTEGER
    END AS duration2, CASE WHEN cancellation IN ('', 'null', NULL) THEN
        NULL
    ELSE
        cancellation
    END AS cancellation FROM runner_orders;

-- Creating pizza_recipes_long table
DROP TABLE IF EXISTS pizza_recipes_long;

CREATE TABLE pizza_recipes_long (
    pizza_id INTEGER,
    topping_id INTEGER
);

INSERT INTO pizza_recipes_long (pizza_id, topping_id)
SELECT
    pizza_id,
    UNNEST(STRING_TO_ARRAY(toppings, ','))::INTEGER AS topping_id
FROM
    pizza_runner.pizza_recipes;
SET search_path = pizza_runner;

-- Cleaning customer_orders table
DROP TABLE IF EXISTS customer_orders_clean;

CREATE TABLE customer_orders_clean (
    unique_id INTEGER,
    order_id INTEGER,
    customer_id INTEGER,
    pizza_id INTEGER,
    exclusions VARCHAR(4),
    extras VARCHAR(4),
    order_time TIMESTAMP
);

INSERT INTO customer_orders_clean (unique_id, order_id, customer_id, pizza_id, exclusions, extras, order_time)
SELECT
    ROW_NUMBER() OVER (ORDER BY order_id),
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IN ('', 'null', NULL) THEN
        NULL
    ELSE
        exclusions
    END AS exclusions,
    CASE WHEN extras IN ('', 'null', NULL) THEN
        NULL
    ELSE
        extras
    END AS extras,
    order_time
FROM
    customer_orders;

--
-- Cleaning runner_orders table
DROP TABLE IF EXISTS runner_orders_clean;

CREATE TABLE runner_orders_clean (
    order_id INTEGER,
    runner_id INTEGER,
    pickup_time TIMESTAMP,
    distance FLOAT,
    duration INTEGER,
    cancellation VARCHAR(23)
);

INSERT INTO runner_orders_clean (order_id, runner_id, pickup_time, distance, duration, cancellation)
SELECT
    order_id,
    runner_id,
    CASE WHEN pickup_time IN ('', 'null', NULL) THEN
        NULL
    ELSE
        pickup_time::TIMESTAMP
    END AS pickup_time2,
    CASE WHEN distance IN ('', 'null', NULL) THEN
        NULL
    ELSE
        TRIM(REPLACE(distance, 'km', ''))::FLOAT
    END AS distance2,
    CASE WHEN duration IN ('', 'null', NULL) THEN
        NULL
    ELSE
        TRIM(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'minute', ''), 'mins', ''))::INTEGER
    END AS duration2, CASE WHEN cancellation IN ('', 'null', NULL) THEN
        NULL
    ELSE
        cancellation
    END AS cancellation FROM runner_orders;

-- Creating pizza_recipes_long table
DROP TABLE IF EXISTS pizza_recipes_long;

CREATE TABLE pizza_recipes_long (
    pizza_id INTEGER,
    topping_id INTEGER
);

INSERT INTO pizza_recipes_long (pizza_id, topping_id)
SELECT
    pizza_id,
    UNNEST(STRING_TO_ARRAY(toppings, ','))::INTEGER AS topping_id
FROM
    pizza_runner.pizza_recipes;
