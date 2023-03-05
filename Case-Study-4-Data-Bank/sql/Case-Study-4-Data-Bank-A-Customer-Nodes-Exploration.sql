--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 4 - Data Bank
-- Part A - Customer Nodes Exploration
--
-- 1. How many unique nodes are there on the Data Bank system?
SELECT
    COUNT(DISTINCT node_id) AS unique_nodes
FROM
    data_bank.customer_nodes;

--
-- 2. What is the number of nodes per region?
SELECT
    r.region_name,
    COUNT(*) AS nodes_total
FROM
    data_bank.customer_nodes AS c
    JOIN data_bank.regions AS r ON c.region_id = r.region_id
GROUP BY
    c.region_id,
    r.region_name
ORDER BY
    c.region_id;

--
-- 3. How many customers are allocated to each region?
SELECT
    r.region_name,
    COUNT(DISTINCT customer_id) AS customer_total
FROM
    data_bank.customer_nodes AS c
    JOIN data_bank.regions AS r ON c.region_id = r.region_id
GROUP BY
    c.region_id,
    r.region_name
ORDER BY
    c.region_id;

--
-- 4. How many days on average are customers reallocated to a different node?
WITH customer_next_nodes AS (
    SELECT
        customer_id,
        node_id,
        start_date,
        LEAD(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node,
        LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node_start_date
    FROM
        data_bank.customer_nodes
)
SELECT
    ROUND(AVG(next_node_start_date - start_date)) AS reallocation_days_average
FROM
    customer_next_nodes
WHERE
    node_id != next_node;

--
-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH customer_next_nodes AS (
    SELECT
        c.start_date,
        r.region_id,
        r.region_name,
        LEAD(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node,
        LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node_start_date
    FROM
        data_bank.customer_nodes AS c
        JOIN data_bank.regions AS r ON c.region_id = r.region_id
),
reallocation_days AS (
    SELECT
        region_id,
        region_name,
        (next_node_start_date - start_date) AS days
    FROM
        customer_next_nodes
)
SELECT
    region_name,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY days) AS reallocation_median,
    PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY days) AS reallocation_percentile_80,
    PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY days) AS reallocation_percentile_95
FROM
    reallocation_days
GROUP BY
    region_id,
    region_name
ORDER BY
    region_id;
