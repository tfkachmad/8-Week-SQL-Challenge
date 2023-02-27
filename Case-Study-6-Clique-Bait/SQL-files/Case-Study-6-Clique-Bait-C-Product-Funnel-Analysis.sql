--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 6 - Clique Bait
-- Part C - Product Funnel Analysis
--
-- Using a single SQL query - create a new output table which has the following details:
--  - How many times was each product viewed?
--  - How many times was each product added to cart?
--  - How many times was each product added to a cart but not purchased (abandoned)?
--  - How many times was each product purchased?
SET search_path = 'clique_bait';

CREATE TEMPORARY TABLE IF NOT EXISTS product_funnel AS
WITH product_views AS (
    SELECT
        p.page_name AS product_name,
        COUNT(*) AS viewed_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%View'
        AND p.product_category IS NOT NULL
    GROUP BY
        1
),
product_added_to_cart AS (
    SELECT
        p.page_name AS product_name,
        COUNT(*) AS added_to_cart_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
    GROUP BY
        1
),
visit_with_purchase AS (
    SELECT
        visit_id
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name = 'Purchase'
),
product_abandoned AS (
    SELECT
        p.page_name AS product_name,
        COUNT(*) AS added_to_cart_only_num
FROM
    clique_bait.events AS e1
    JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
    JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
        AND e1.visit_id NOT IN (
            SELECT
                visit_id
            FROM
                visit_with_purchase)
        GROUP BY
            1
),
product_purchased AS (
    SELECT
        p.page_name AS product_name,
        COUNT(*) AS purchased_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
        AND e1.visit_id IN (
            SELECT
                visit_id
            FROM
                visit_with_purchase)
        GROUP BY
            1
)
SELECT
    p1.product_name,
    p1.viewed_num,
    p2.added_to_cart_num,
    p3.added_to_cart_only_num,
    p4.purchased_num
FROM
    product_views AS p1
    JOIN product_added_to_cart AS p2 ON p1.product_name = p2.product_name
    JOIN product_abandoned AS p3 ON p1.product_name = p3.product_name
    JOIN product_purchased AS p4 ON p1.product_name = p4.product_name
ORDER BY
    2 DESC;

SELECT
    *
FROM
    product_funnel;

--
-- Additionally, create another table which further aggregates the data for the above
-- points but this time for each product category instead of individual products.
CREATE TEMPORARY TABLE IF NOT EXISTS category_funnel AS
WITH product_category_views AS (
    SELECT
        p.product_category,
        COUNT(*) AS viewed_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%View'
        AND p.product_category IS NOT NULL
    GROUP BY
        1
),
product_category_added_to_cart AS (
    SELECT
        p.product_category,
        COUNT(*) AS added_to_cart_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
    GROUP BY
        1
),
visit_with_purchase AS (
    SELECT
        visit_id
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name = 'Purchase'
),
product_category_abandoned AS (
    SELECT
        p.product_category,
        COUNT(*) AS added_to_cart_only_num
FROM
    clique_bait.events AS e1
    JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
    JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
        AND e1.visit_id NOT IN (
            SELECT
                visit_id
            FROM
                visit_with_purchase)
        GROUP BY
            1
),
product_category_purchased AS (
    SELECT
        p.product_category,
        COUNT(*) AS purchased_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e2.event_type = e1.event_type
    WHERE
        e2.event_name LIKE '%Cart'
        AND p.product_category IS NOT NULL
        AND e1.visit_id IN (
            SELECT
                visit_id
            FROM
                visit_with_purchase)
        GROUP BY
            1
)
SELECT
    p1.product_category,
    p1.viewed_num,
    p2.added_to_cart_num,
    p3.added_to_cart_only_num,
    p4.purchased_num
FROM
    product_category_views AS p1
    JOIN product_category_added_to_cart AS p2 ON p1.product_category = p2.product_category
    JOIN product_category_abandoned AS p3 ON p1.product_category = p3.product_category
    JOIN product_category_purchased AS p4 ON p1.product_category = p4.product_category
ORDER BY
    2 DESC;

SELECT
    *
FROM
    category_funnel;

-- Use your 2 new output tables - answer the following questions:
--  - Which product had the most views, cart adds and purchases?
WITH product_ranking AS (
    SELECT
        product_name,
        RANK() OVER (ORDER BY viewed_num DESC,
            added_to_cart_num DESC,
            purchased_num DESC) AS rank1,
        RANK() OVER (ORDER BY added_to_cart_num DESC) AS rank2,
        RANK() OVER (ORDER BY purchased_num DESC) AS rank3
    FROM
        product_funnel
)
SELECT
    p1.product_name AS most_viewed_product,
    p2.product_name AS most_added_to_cart_product,
    p3.product_name AS most_purchased_product
FROM
    product_ranking AS p1
    JOIN product_ranking AS p2 ON p1.rank1 = p2.rank2
    JOIN product_ranking AS p3 ON p2.rank2 = p3.rank3
WHERE
    p1.rank1 = 1;

--  - Which product was most likely to be abandoned?
WITH product_purchase_rank AS (
    SELECT
        product_name,
        RANK() OVER (ORDER BY purchased_num) AS product_rank
    FROM
        product_funnel
)
SELECT
    product_name
FROM
    product_purchase_rank
WHERE
    product_rank = 1;

--  - Which product had the highest view to purchase percentage?
SELECT
    product_name,
    ROUND((purchased_num::NUMERIC / viewed_num), 2) * 100 AS view_to_purchase_percentage
FROM
    product_funnel
ORDER BY
    2 DESC
LIMIT 1;

--  - What is the average conversion rate from view to cart add?
SELECT
    ROUND(AVG(100 * added_to_cart_num::NUMERIC / viewed_num), 2) AS view_to_cart_add_percentage
FROM
    product_funnel;

--  - What is the average conversion rate from cart add to purchase?
SELECT
    ROUND(AVG(100 * purchased_num::NUMERIC / added_to_cart_num), 2) AS cart_to_purchase_percentage
FROM
    product_funnel;
