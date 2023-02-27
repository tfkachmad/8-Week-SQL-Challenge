# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution D. Campaign Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

Generate a table that has 1 single row for every unique `visit_id` record and has the following columns:

- `user_id`
- `visit_id`
- `visit_start_time`: the earliest `event_time` for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the - `visit_start_time` falls between the `start_date` and `end_date`
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the `sequence_number`)

Create `campaign_result` table:

```sql
DROP TABLE IF EXISTS clique_bait.campaign_data;
WITH sub_CTE
AS (
    -- user_id, visit_id, visit_start_time, page_views
    SELECT u.[user_id]
        ,e.visit_id
        ,MIN(e.event_time) AS visit_start_time
        ,COUNT(DISTINCT e.page_id) AS page_views
        -- Finding the value for cart_adds column
        ,COUNT(CASE
                WHEN ei.event_name LIKE 'Add to Cart'
                    THEN 1
                ELSE NULL
                END) AS cart_adds
        -- Finding the value for impression column
        ,COUNT(CASE
                WHEN ei.event_name LIKE 'Ad Impression'
                    THEN 1
                ELSE NULL
                END) AS impression
        -- Finding the value for click column
        ,COUNT(CASE
                WHEN ei.event_name LIKE 'Ad Click'
                    THEN 1
                ELSE NULL
                END) AS click
    FROM clique_bait.events AS e
    JOIN clique_bait.event_identifier AS ei
        ON e.event_type = ei.event_type
    JOIN clique_bait.users AS u
        ON e.cookie_id = u.cookie_id
    GROUP BY u.[user_id]
        ,e.visit_id
    )
    ,find_purchase_CTE
AS (
    SELECT DISTINCT e.visit_id
    FROM clique_bait.events AS e
    JOIN clique_bait.event_identifier AS ei
        ON e.event_type = ei.event_type
    WHERE ei.event_name LIKE 'Purchase'
    )
    ,purchase_CTE
AS (
    SELECT *
        -- Finding the value of purchase column
        ,CASE
            WHEN visit_id IN (
                    SELECT visit_id
                    FROM find_purchase_CTE
                    )
                THEN 1
            ELSE 0
            END AS purchase
    FROM sub_CTE
    )
    ,campaign_CTE
AS (
    SELECT sub.*
        -- Creating campaign_name column
        ,c.campaign_name
    FROM purchase_CTE AS sub
    LEFT JOIN clique_bait.campaign_identifier AS c
        ON sub.visit_start_time BETWEEN c.start_date
                AND c.end_date
    )
    ,products_CTE
AS (
    SELECT e.visit_id
        -- Creating products column
        ,STRING_AGG(p.page_name, ', ') WITHIN
    GROUP (
            ORDER BY e.sequence_number
            ) AS products
    FROM clique_bait.events AS e
    JOIN clique_bait.page_hierarchy AS p
        ON e.page_id = p.page_id
    JOIN clique_bait.event_identifier AS ei
        ON e.event_type = ei.event_type
    WHERE p.product_category IS NOT NULL
        AND ei.event_name LIKE 'Add to Cart'
    GROUP BY e.visit_id
    )
SELECT [user_id]
    ,c.visit_id
    ,visit_start_time
    ,page_views
    ,cart_adds
    ,purchase
    ,campaign_name
    ,impression
    ,click
    ,products
INTO clique_bait.campaign_data
FROM campaign_CTE AS c
JOIN products_CTE AS p
    ON c.visit_id = p.visit_id;
--
-- campaign_data table result
SELECT *
FROM clique_bait.campaign_data;
```

`campaign_result` table (first 5 rows):

| user_id | visit_id | visit_start_time            | page_views | cart_adds | purchase | campaign_name                     | impression | click | products                                                     |
| ------- | -------- | --------------------------- | ---------- | --------- | -------- | --------------------------------- | ---------- | ----- | ------------------------------------------------------------ |
| 155     | 001597   | 2020-02-17 00:21:45.2951410 | 11         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Russian Caviar, Black Truffle, Lobster, Crab, Oyster |
| 78      | 0048b2   | 2020-02-10 02:59:51.3354520 | 6          | 4         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Kingfish, Russian Caviar, Abalone, Lobster                   |
| 228     | 004aaf   | 2020-03-18 13:23:07.9739400 | 7          | 2         | 1        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Tuna, Lobster                                                |
| 237     | 005fe7   | 2020-04-02 18:14:08.2577110 | 10         | 4         | 1        | NULL                              | 0          | 0     | Kingfish, Black Truffle, Crab, Oyster                        |
| 420     | 006a61   | 2020-01-25 20:54:14.6302530 | 10         | 5         | 1        | 25% Off - Living The Lux Life     | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Crab           |

<br>

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event

    ```sql
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
    ```

    Result:

    | "received_impressions" | "visits_total" | "page_views_average" | "cart_adds_average" | "purchase_rate_percentage" |
    |------------------------|----------------|----------------------|---------------------|----------------------------|
    | Yes                    | 876            | 9                    | 12                  | 84.1                       |
    | No                     | 2688           | 5                    | 4                   | 38.7                       |

    > The average number of page views, cart adds, and purchase rate is higher on users that received impression ad

    <br>

- Does clicking on an impression lead to higher purchase rates?

    ```sql
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
    ```

    Result:

    | "clicked_ad_impressions" | "purchase_rate_percentage" |
    |--------------------------|----------------------------|
    | Yes                      | 84.1                       |
    | No                       | 38.7                       |

    > The purchase rate for users that clicked ad impressions is higher than for users that not.

    <br>

- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just see an impression but do not click?

    ```sql
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
    ```

    Result:

    | "user_comparison" | "purchase_rate_percentage" |
    |-------------------|----------------------------|
    | Clicking the ads  | 89.6                       |
    | Only see the ads  | 66.2                       |
    | Received no ads   | 37.9                       |

    > The purchase rate for users that click the ads impression and only viewed the ads impression is higher than user that not received any ads impression.

    <br>

- What metrics can you use to quantify the success or failure of each campaign compared to eachother?

    ```sql
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
    ```

    Result:

    | "campaigns"                       | "visits_total" | "purchase_total" | "page_views_average" | "cart_adds_average" | "purchase_rate_percentage" |
    |-----------------------------------|----------------|------------------|----------------------|---------------------|----------------------------|
    | No Campaign                       | 512            | 268              | 7                    | 6                   | 52.3                       |
    | BOGOF - Fishing For Compliments   | 260            | 127              | 6                    | 6                   | 48.8                       |
    | Half Off - Treat Your Shellf(ish) | 2388           | 1180             | 6                    | 6                   | 49.4                       |
    | 25% Off - Living The Lux Life     | 404            | 202              | 7                    | 7                   | 50.0                       |

    > The number of visits for each campaign could be the indicator on how effective a campaign is. From the result, the Half Off - Treat Your Shellf(ish) campaign attracted more than 2000 visits, which is 4 times more web visits than when there's no campaign.

---
