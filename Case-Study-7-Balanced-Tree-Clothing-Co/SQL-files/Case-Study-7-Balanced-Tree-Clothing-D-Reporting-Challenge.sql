--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 7 - Balanced Tree Clothing
-- Part D - Reporting Challenge
--
--  Write a single SQL script that combines all of the previous questions into a
--  scheduled report that the Balanced Tree team can run at the beginning of each
--  month to calculate the previous month’s values.
--
--  Imagine that the Chief Financial Officer (which is also Danny) has asked for all of
--  these questions at the end of every month.
--
--  He first wants you to generate the data for January only - but then he also wants
--  you to demonstrate that you can easily run the samne analysis for February without
--  many changes (if at all).
--
--  Feel free to split up your final outputs into as many tables as you need - but be sure
--  to explicitly reference which table outputs relate to which question for full marks :)
--
DO $$
DECLARE
    month_name VARCHAR(9) := 'January';
BEGIN
    SET SEARCH_PATH = 'balanced_tree';
    DROP TABLE IF EXISTS monthly_sales;
    CREATE TEMPORARY TABLE IF NOT EXISTS monthly_sales AS
    SELECT
        *
    FROM
        balanced_tree.sales
    WHERE
        TO_CHAR(start_txn_time, 'FMMonth') = month_name;
END
$$;

--
-- ========== High level sales analysis ==========
--
-- 1. What was the total quantity sold for all products?
SELECT
    SUM(qty) AS quantity_sold_total
FROM
    monthly_sales;

--
-- 2. What is the total generated revenue for all products before discounts?
SELECT
    TO_CHAR(SUM(qty * price), '9,999,999') AS gross_revenue_total
FROM
    monthly_sales;

--
-- 3. What was the total discount amount for all products?
SELECT
    TO_CHAR(SUM(qty * price * discount::NUMERIC / 100), '9,999,999') AS discount_total
FROM
    monthly_sales;

--
-- ========== Transaction analysis ==========
--
-- 1. How many unique transactions were there?
SELECT
    COUNT(DISTINCT txn_id) AS transactions_num
FROM
    monthly_sales;

--
-- 2. What is the average unique products purchased in each transaction?
WITH products_per_transactions AS (
    SELECT
        txn_id,
        COUNT(DISTINCT prod_id) AS products_num
    FROM
        monthly_sales
    GROUP BY
        1
)
SELECT
    ROUND(AVG(products_num)) AS product_purchased_average
FROM
    products_per_transactions;

--
-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH transaction_revenue AS (
    SELECT
        qty * price AS gross_revenue,
        ROUND(((qty * price * discount)::NUMERIC / 100), 2) AS discount,
        ROUND(((qty * price) - ((qty * price * discount)::NUMERIC / 100)), 2) AS revenue
    FROM
        monthly_sales
)
SELECT
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY revenue) AS revenue_percentile_25,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_median,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY revenue) AS revenue_percentile_75
FROM
    transaction_revenue;

--
-- 4. What is the average discount value per transaction?
WITH discount_per_transaction AS (
    SELECT
        txn_id,
        SUM(((qty * price * discount)::NUMERIC / 100)) AS discount
    FROM
        monthly_sales
    GROUP BY
        1
)
SELECT
    ROUND(AVG(discount), 2) AS discount_average
FROM
    discount_per_transaction;

--
-- 5. What is the percentage split of all transactions for members vs non-members?
WITH member_txn_id AS (
    SELECT DISTINCT
        txn_id,
        CASE member
        WHEN TRUE THEN
            'Member'
        ELSE
            'Non-member'
        END AS member_status
    FROM
        monthly_sales
),
member_txn_num AS (
    SELECT
        member_status,
        COUNT(*) AS transaction_num
FROM
    member_txn_id
GROUP BY
    1
)
SELECT
    member_status,
    transaction_num,
    ROUND((100 * transaction_num::NUMERIC / SUM(transaction_num) OVER ()), 1) AS transaction_percentage
FROM
    member_txn_num
ORDER BY
    2 DESC;

--
-- 6. What is the average revenue for member transactions and non-member transactions?
WITH transaction_revenue AS (
    SELECT
        CASE member
        WHEN TRUE THEN
            'Member'
        ELSE
            'Non-member'
        END AS member_status,
        (qty * price) AS gross_revenue,
        (qty * price) * (discount::NUMERIC / 100) AS discount
    FROM
        monthly_sales
)
SELECT
    member_status,
    ROUND(AVG(gross_revenue), 1) AS gross_revenue_average,
    ROUND(AVG(gross_revenue - discount), 1) AS net_revenue_average
FROM
    transaction_revenue
GROUP BY
    1
ORDER BY
    2 DESC;

--
-- ========== Product analysis ==========
--
-- 1. What are the top 3 products by total revenue before discount?
SELECT
    p.product_name,
    TO_CHAR(SUM(s.qty * s.price), '999,999') AS gross_revenue_total
FROM
    monthly_sales AS s
    JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 3;

--
-- 2. What is the total quantity, revenue and discount for each segment?
WITH segment_subset AS (
    SELECT
        p.segment_name,
        s.qty,
        (s.qty * s.price) AS gross_revenue,
        ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
)
SELECT
    segment_name,
    TO_CHAR(SUM(qty), '999,999') AS quantity_total,
    TO_CHAR(SUM(gross_revenue - discount), '999,999.9') AS net_revenue_total,
    TO_CHAR(SUM(discount), '999,999.9') AS discount_total
FROM
    segment_subset
GROUP BY
    1
ORDER BY
    2 DESC;

--
-- 3. What is the top selling product for each segment?
WITH segment_product_sales AS (
    SELECT
        p.segment_name,
        p.product_name,
        TO_CHAR(SUM(qty), '999,999') AS quantity_sold
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
    GROUP BY
        1,
        2
),
top_selling_product AS (
    SELECT
        segment_name,
        product_name,
        quantity_sold,
        RANK() OVER (PARTITION BY segment_name ORDER BY quantity_sold DESC) AS rank_num
    FROM
        segment_product_sales
)
SELECT
    segment_name,
    product_name AS top_selling_product,
    quantity_sold
FROM
    top_selling_product
WHERE
    rank_num = 1;

--
-- 4. What is the total quantity, revenue and discount for each category?
WITH category_subset AS (
    SELECT
        p.category_name,
        s.qty,
        (s.qty * s.price) AS gross_revenue,
        ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
)
SELECT
    category_name,
    TO_CHAR(SUM(qty), '999,999') AS quantity_total,
    TO_CHAR(SUM(gross_revenue - discount), '999,999.9') AS net_revenue_total,
    TO_CHAR(SUM(discount), '999,999.9') AS discount_total
FROM
    category_subset
GROUP BY
    1
ORDER BY
    2 DESC;

--
-- 5. What is the top selling product for each category?
WITH category_product_sales AS (
    SELECT
        p.category_name,
        p.product_name,
        TO_CHAR(SUM(qty), '999,999') AS quantity_sold
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
    GROUP BY
        1,
        2
),
top_selling_product AS (
    SELECT
        category_name,
        product_name,
        quantity_sold,
        RANK() OVER (PARTITION BY category_name ORDER BY quantity_sold DESC) AS rank_num
    FROM
        category_product_sales
)
SELECT
    category_name,
    product_name AS top_selling_product,
    quantity_sold
FROM
    top_selling_product
WHERE
    rank_num = 1
ORDER BY
    3 DESC;

--
-- 6. What is the percentage split of revenue by product for each segment?
WITH segment_product_subset AS (
    SELECT
        p.segment_name,
        p.product_name,
        (s.qty * s.price) AS gross_revenue,
        ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
),
segment_product_revenue AS (
    SELECT
        segment_name,
        product_name,
        SUM(gross_revenue - discount) AS net_revenue
    FROM
        segment_product_subset
    GROUP BY
        1,
        2
)
SELECT
    segment_name,
    product_name,
    ROUND((100 * net_revenue / SUM(net_revenue) OVER (PARTITION BY segment_name)), 2) AS revenue_share_percentage
FROM
    segment_product_revenue
ORDER BY
    1,
    3 DESC;

--
-- 7. What is the percentage split of revenue by segment for each category?
WITH category_segment_subset AS (
    SELECT
        p.category_name,
        p.segment_name,
        (s.qty * s.price) AS gross_revenue,
        ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
),
category_segment_revenue AS (
    SELECT
        category_name,
        segment_name,
        SUM(gross_revenue - discount) AS net_revenue
    FROM
        category_segment_subset
    GROUP BY
        1,
        2
)
SELECT
    category_name,
    segment_name,
    ROUND((100 * net_revenue / SUM(net_revenue) OVER (PARTITION BY category_name)), 2) AS revenue_share_percentage
FROM
    category_segment_revenue
ORDER BY
    1,
    3 DESC;

--
-- 8. What is the percentage split of total revenue by category?
WITH category_subset AS (
    SELECT
        p.category_name,
        (s.qty * s.price) AS gross_revenue,
        ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
),
category_revenue AS (
    SELECT
        category_name,
        SUM(gross_revenue - discount) AS net_revenue
    FROM
        category_subset
    GROUP BY
        1
)
SELECT
    category_name,
    ROUND((100 * net_revenue / SUM(net_revenue) OVER ()), 2) AS revenue_share_percentage
FROM
    category_revenue
ORDER BY
    1;

--
--  9. What is the total transaction “penetration” for each product?
--      (hint: penetration = number of transactions where at least 1 quantity of a
--      product was purchased divided by total number of transactions)
WITH product_txn_num AS (
    SELECT
        p.product_name,
        COUNT(*) AS transactions_num
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
    GROUP BY
        1
)
SELECT
    product_name,
    ROUND((100 * transactions_num::NUMERIC / (
            SELECT
                COUNT(DISTINCT txn_id)
            FROM monthly_sales)), 2) AS penetration_rate
FROM
    product_txn_num
ORDER BY
    2 DESC;

--
--  10. What is the most common combination of at least 1 quantity of any 3 products
--      in a 1 single transaction?
WITH RECURSIVE subset AS (
    SELECT
        s.txn_id,
        p.product_name,
        p.product_id
    FROM
        monthly_sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
),
product_combo (
    txn_id, item_length, item_combo, last_item
) AS (
    SELECT
        txn_id,
        1 AS item_length,
        product_name::VARCHAR AS item_combo,
        product_name AS last_item
    FROM
        subset
UNION ALL
SELECT
    s.txn_id,
    item_length + 1 AS item_length,
    item_combo::VARCHAR || ', ' || s.product_name AS item_combo,
    s.product_name AS last_item
FROM
    product_combo AS p
    JOIN subset AS s ON p.txn_id = s.txn_id
        AND s.product_name > p.last_item
    WHERE
        item_length < 3
)
SELECT
    item_combo AS product_combination,
    COUNT(*) AS combination_total
FROM
    product_combo
WHERE
    item_length = 3
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 1;
