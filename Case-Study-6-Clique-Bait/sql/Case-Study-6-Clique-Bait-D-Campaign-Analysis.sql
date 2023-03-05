--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 6 - Clique Bait
-- Part D - Campaign Analysis
--
-- Generate a table that has 1 single row for every unique visit_id record and has
-- the following columns:
--      - user_id
--      - visit_id
--      - visit_start_time: the earliest event_time for each visit
--      - page_views: count of page views for each visit
--      - cart_adds: count of product cart add events for each visit
--      - purchase: 1/0 flag if a purchase event exists for each visit
--      - campaign_name: map the visit to a campaign if the visit_start_time falls
--          between the start_date and end_date
--      - impression: count of ad impressions for each visit
--      - click: count of ad clicks for each visit
--      - (Optional column) cart_products: a comma separated text value with products
--          added to the cart sorted by the order they were added to the cart
--          (hint: use the sequence_number)
SET search_path = 'clique_bait';

CREATE TEMPORARY TABLE IF NOT EXISTS campaign_result AS
WITH visit_with_purchase AS (
    SELECT DISTINCT
        visit_id
    FROM
        clique_bait.events AS e1
        JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
    WHERE
        e2.event_name = 'Purchase'
)
SELECT
    u.user_Id,
    e1.visit_id,
    MIN(e1.event_time) AS visit_start_time,
    COUNT(DISTINCT e1.page_id) AS page_views,
    SUM(
        CASE WHEN p.product_category IS NOT NULL THEN
            1
        ELSE
            0
        END) AS cart_adds,
    MAX(
        CASE WHEN e1.visit_id IN (
            SELECT
                visit_id
            FROM visit_with_purchase) THEN
            1
        ELSE
            0
        END) AS purchase,
    MIN(c.campaign_name) AS campaign_name,
    SUM(
        CASE WHEN e2.event_name = 'Ad Impression' THEN
            1
        ELSE
            0
        END) AS ad_impression,
    SUM(
        CASE WHEN e2.event_name = 'Ad Click' THEN
            1
        ELSE
            0
        END) AS ad_click,
    STRING_AGG(
        CASE WHEN p.product_category IS NOT NULL THEN
            p.page_name
        ELSE
            NULL
        END, ', ' ORDER BY e1.sequence_number)
FROM
    clique_bait.events AS e1
    JOIN clique_bait.users AS u ON e1.cookie_id = u.cookie_id
    LEFT JOIN clique_bait.campaign_identifier AS c ON e1.event_time BETWEEN c.start_date AND c.end_date
    JOIN clique_bait.event_identifier AS e2 ON e1.event_type = e2.event_type
    JOIN clique_bait.page_hierarchy AS p ON e1.page_id = p.page_id
GROUP BY
    u.user_Id,
    e1.visit_id,
    c.campaign_name;

-- Use the subsequent dataset to generate at least 5 insights for the Clique Bait team
-- Some ideas you might want to investigate further include:
--      - Identifying users who have received impressions during each campaign period and
--      comparing each metric with other users who did not have an impression event
WITH impressions_agg AS (
    SELECT
        CASE ad_impression
        WHEN 1 THEN
            'Yes'
        ELSE
            'No'
        END AS received_impressions,
        COUNT(*) AS visits_total,
        ROUND(AVG(page_views)) AS page_views_average,
        ROUND(AVG(cart_adds)) AS cart_adds_average,
        SUM(purchase) AS purchase_total
    FROM
        campaign_result
    GROUP BY
        1
)
SELECT
    received_impressions,
    visits_total,
    page_views_average,
    cart_adds_average,
    ROUND((100 * purchase_total / visits_total::NUMERIC), 1) AS purchase_rate_percentage
FROM
    impressions_agg
ORDER BY
    2;

--      - Does clicking on an impression lead to higher purchase rates?
WITH ad_click_agg AS (
    SELECT
        CASE ad_impression
        WHEN 1 THEN
            'Yes'
        ELSE
            'No'
        END AS clicked_ad_impressions,
        COUNT(*) AS visits_total,
        SUM(purchase) AS purchase_total
    FROM
        campaign_result
    GROUP BY
        1
)
SELECT
    clicked_ad_impressions,
    ROUND((100 * purchase_total / visits_total::NUMERIC), 1) AS purchase_rate_percentage
FROM
    ad_click_agg
ORDER BY
    2 DESC;

--      - What is the uplift in purchase rate when comparing users who click on a campaign
--      impression versus users who do not receive an impression?
--      - What if we compare them with users who just an see impression but do not click?
WITH comparison AS (
    SELECT
        CASE WHEN ad_click = 1 THEN
            'Clicking the ads'
        WHEN ad_click = 0
            AND ad_impression = 1 THEN
            'Only see the ads'
        WHEN ad_impression = 0 THEN
            'Received no ads'
        END AS user_comparison,
        COUNT(*) AS visits_total,
        SUM(purchase) AS purchase_total
    FROM
        campaign_result
    WHERE
        campaign_name IS NOT NULL
    GROUP BY
        1
)
SELECT
    user_comparison,
    ROUND((100 * purchase_total / visits_total::NUMERIC), 1) AS purchase_rate_percentage
FROM
    comparison;

--      - What metrics can you use to quantify the success or failure of each campaign compared
--      to each other?
WITH campaign_agg AS (
    SELECT
        CASE WHEN campaign_name IS NULL THEN
            'No Campaign'
        ELSE
            campaign_name
        END AS campaigns,
        COUNT(*) AS visits_total,
        SUM(purchase) AS purchase_total,
        ROUND(AVG(page_views)) AS page_views_average,
        ROUND(AVG(cart_adds)) AS cart_adds_average
    FROM
        campaign_result
    GROUP BY
        1
)
SELECT
    campaigns,
    visits_total,
    purchase_total,
    page_views_average,
    cart_adds_average,
    ROUND((100 * purchase_total / visits_total::NUMERIC), 1) AS purchase_rate_percentage
FROM
    campaign_agg;
