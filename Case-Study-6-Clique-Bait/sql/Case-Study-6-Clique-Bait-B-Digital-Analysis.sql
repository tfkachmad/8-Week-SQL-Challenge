--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 6 - Clique Bait
-- Part B - Digital Analysis
--
-- Using the available datasets - answer the following questions using a single
-- query for each one:
--
-- 1. How many users are there?
SELECT
    COUNT(DISTINCT user_id) AS user_total
FROM
    clique_bait.users;

--
-- 2. How many cookies does each user have on average?
WITH cookies_count AS (
    SELECT
        user_id,
        COUNT(*) AS cookies_num
    FROM
        clique_bait.users
    GROUP BY
        user_id
)
SELECT
    ROUND(AVG(cookies_num)) AS cookies_average
FROM
    cookies_count;

--
-- 3. What is the unique number of visits by all users per month?
SELECT
    TO_CHAR(event_time, 'Month') AS month_name,
    COUNT(DISTINCT cookie_id) AS visits_num
FROM
    clique_bait.events
GROUP BY
    EXTRACT('month' FROM event_time),
    TO_CHAR(event_time, 'Month')
ORDER BY
    EXTRACT('month' FROM event_time);

--
-- 4. What is the number of events for each event type?
SELECT
    e2.event_name,
    COUNT(*) AS events_num
FROM
    clique_bait.events AS e1
    JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
GROUP BY
    e2.event_type,
    e2.event_name
ORDER BY
    e2.event_type;

--
-- 5. What is the percentage of visits which have a purchase event?
WITH visit_with_purchase AS (
    SELECT
        COUNT(DISTINCT e1.visit_id) AS visit_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
    WHERE
        e2.event_name = 'Purchase'
)
SELECT
    ROUND((100 * visit_num::NUMERIC / (
            SELECT
                COUNT(DISTINCT visit_id)
            FROM clique_bait.events)), 2) AS visit_with_purchase_percentage
FROM
    visit_with_purchase;

--
-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH checkout_no_purchase_visits AS (
    SELECT
        COUNT(DISTINCT visit_id) AS visit_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
    WHERE
        p.page_name = 'Checkout'
        AND e2.event_name != 'Purchase'
)
SELECT
    ROUND((100 * visit_num::NUMERIC / (
            SELECT
                COUNT(DISTINCT visit_id)
            FROM clique_bait.events)), 2) AS checkout_no_purchase_percent
FROM
    checkout_no_purchase_visits;

--
-- 7. What are the top 3 pages by number of views?
SELECT
    p.page_name,
    COUNT(*) AS views_num
FROM
    clique_bait.events AS e1
    JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
    JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
WHERE
    e2.event_name LIKE '%View'
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 3;

--
-- 8. What is the number of views and cart adds for each product category?
WITH category_views_num AS (
    SELECT
        p.product_category,
        COUNT(*) AS page_view_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
    WHERE
        e2.event_name LIKE '%View'
    GROUP BY
        1
),
category_cart_num AS (
    SELECT
        p.product_category,
        COUNT(*) AS add_to_cart_num
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
        JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
    WHERE
        e2.event_name LIKE '%Cart'
    GROUP BY
        1
)
SELECT
    c1.product_category,
    c1.page_view_num,
    c2.add_to_cart_num
FROM
    category_views_num AS c1
    LEFT JOIN category_cart_num AS c2 ON c1.product_category = c2.product_category
ORDER BY
    2 DESC;

--
-- 9. What are the top 3 products by purchases?
WITH visit_with_purchase AS (
    SELECT DISTINCT
        visit_id
    FROM
        clique_bait.events
    WHERE
        event_type = (
            SELECT
                event_type
            FROM
                clique_bait.event_identifier
            WHERE
                event_name = 'Purchase'))
SELECT
    p.page_name,
    COUNT(*) AS purchased_total
FROM
    clique_bait.events AS e
    JOIN clique_bait.page_hierarchy AS p ON e.page_id = p.page_id
WHERE
    p.product_category IS NOT NULL
    AND e.event_type = (
        SELECT
            event_type
        FROM
            clique_bait.event_identifier
        WHERE
            event_name LIKE 'Add%')
    AND e.visit_id IN (
        SELECT
            visit_id
        FROM
            visit_with_purchase)
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 3;
