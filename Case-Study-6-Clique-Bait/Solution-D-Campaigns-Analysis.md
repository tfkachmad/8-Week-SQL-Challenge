# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution D. Campaign Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

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

<br/>

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event

    ```sql
    WITH sub_CTE
    AS (
        SELECT CASE
                WHEN impression = 1
                    THEN 'Received Impression'
                ELSE 'No Impression'
                END AS ad_impression
            ,CAST(COUNT(*) AS FLOAT) AS users_cnt
            ,AVG(page_views) AS page_views_avg
            ,AVG(cart_adds) AS cart_adds_avg
            ,COUNT(CASE
                    WHEN purchase = 1
                        THEN 1
                    ELSE NULL
                    END) AS purchase_count
        FROM clique_bait.campaign_data
        WHERE campaign_name IS NOT NULL
        GROUP BY CASE
                WHEN impression = 1
                    THEN 'Received Impression'
                ELSE 'No Impression'
                END
        )
    SELECT ad_impression
        ,users_cnt
        ,page_views_avg
        ,cart_adds_avg
        ,purchase_count
        ,CONCAT (
            ROUND((purchase_count / users_cnt) * 100, 2)
            ,'%'
            ) AS purchase_rate
    FROM sub_CTE;
    ```

    Result:

    | ad_impression       | users_cnt | page_views_avg | cart_adds_avg | purchase_count | purchase_rate |
    | ------------------- | --------- | -------------- | ------------- | -------------- | ------------- |
    | Received Impression | 738       | 9              | 5             | 635            | 86.04%        |
    | No Impression       | 1404      | 7              | 2             | 874            | 62.25%        |

    > The average number of page that a users view, the number of cart adds, and the purchase rate is higher on users that received impression ad

    <br/>

- Does clicking on an impression lead to higher purchase rates?

    ```sql
    WITH sub_CTE
    AS (
        SELECT CASE
                WHEN impression = 1
                    THEN 'Received Impression'
                ELSE 'No Impression'
                END AS ad_impression
            ,CAST(COUNT(*) AS FLOAT) AS users_cnt
            ,COUNT(CASE
                    WHEN purchase = 1
                        THEN 1
                    ELSE NULL
                    END) AS purchase_cnt
        FROM clique_bait.campaign_data
        WHERE campaign_name IS NOT NULL
        GROUP BY CASE
                WHEN impression = 1
                    THEN 'Received Impression'
                ELSE 'No Impression'
                END
        )
    SELECT ad_impression
        ,CONCAT (
            ROUND((purchase_cnt / users_cnt) * 100, 2)
            ,'%'
            ) AS purchase_rate
    FROM sub_CTE;
    ```

    Result:

    | ad_impression       | purchase_rate |
    | ------------------- | ------------- |
    | Received Impression | 86.04%        |
    | No Impression       | 62.25%        |

    > The purchase rate for users that received impression ad on campaign is higher than users that not.

    <br/>

- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?

    ```sql
    WITH sub_CTE
    AS (
        SELECT CASE
                WHEN click = 1 AND impression = 1
                    THEN 'Click Impression Ad'
                WHEN click = 0 AND impression = 1
                    THEN 'Just See Impression Ad'
                ELSE 'No Impression'
                END AS ad_impression
            ,CAST(COUNT(*) AS FLOAT) AS users_cnt
            ,COUNT(CASE
                    WHEN purchase = 1
                        THEN 1
                    ELSE NULL
                    END) AS purchase_cnt
        FROM clique_bait.campaign_data
        WHERE campaign_name IS NOT NULL
        GROUP BY CASE
                WHEN click = 1 AND impression = 1
                    THEN 'Click Impression Ad'
                WHEN click = 0 AND impression = 1
                    THEN 'Just See Impression Ad'
                ELSE 'No Impression'
                END
        )
    SELECT ad_impression, purchase_cnt
        ,CONCAT (
            ROUND((purchase_cnt / users_cnt) * 100, 2)
            ,'%'
            ) AS purchase_rate
    FROM sub_CTE;
    ```

    Result:

    | ad_impression          | purchase_cnt | purchase_rate |
    | ---------------------- | ------------ | ------------- |
    | Just See Impression Ad | 98           | 70.5%         |
    | No Impression          | 874          | 62.25%        |
    | Click Impression Ad    | 537          | 89.65%        |

    > The purchase rate for users that see and click the ads is higher than user that only see the ads and users that not see/clicking the ads.

    <br/>

- What metrics can you use to quantify the success or failure of each campaign compared to eachother?

    ```sql
    WITH sub_CTE
    AS (
        SELECT campaign_name
            ,CAST(COUNT(*) AS FLOAT) AS users_cnt
            ,AVG(page_views) AS page_views_avg
            ,AVG(cart_adds) AS cart_adds_avg
            ,COUNT(CASE
                    WHEN purchase = 1
                        THEN 1
                    ELSE NULL
                    END) AS purchase_count
        FROM clique_bait.campaign_data
        WHERE campaign_name IS NOT NULL
        GROUP BY campaign_name
        )
    SELECT *
        ,CONCAT (
            ROUND((purchase_count / users_cnt) * 100, 2)
            ,'%'
            ) AS purchase_rate
    FROM sub_CTE;
    ```

    Result:

    | campaign_name                     | users_cnt | page_views_avg | cart_adds_avg | purchase_count | purchase_rate |
    | --------------------------------- | --------- | -------------- | ------------- | -------------- | ------------- |
    | BOGOF - Fishing For Compliments   | 180       | 8              | 3             | 127            | 70.56%        |
    | Half Off - Treat Your Shellf(ish) | 1675      | 8              | 3             | 1180           | 70.45%        |
    | 25% Off - Living The Lux Life     | 287       | 8              | 3             | 202            | 70.38%        |

    > The number of visit by users and the number of item purchased by users can be used to quantify a campaign success or failure.

    <br/>

- What is the purchase rate when there is campaign vs. when there is no campaign?

    ```sql
    WITH sub_CTE
    AS (
        SELECT CASE
                WHEN campaign_name IS NULL
                    THEN 'No Campaign'
                ELSE 'Campaign'
                END AS campaign
            ,CAST(COUNT(*) AS FLOAT) AS users_cnt
            ,AVG(page_views) AS page_views_avg
            ,AVG(cart_adds) AS cart_adds_avg
            ,COUNT(CASE
                    WHEN purchase = 1
                        THEN 1
                    ELSE NULL
                    END) AS purchase_cnt
        FROM clique_bait.campaign_data
        GROUP BY CASE
                WHEN campaign_name IS NULL
                    THEN 'No Campaign'
                ELSE 'Campaign'
                END
        )
    SELECT campaign
        ,purchase_cnt
        ,CONCAT (
            ROUND((purchase_cnt / users_cnt) * 100, 2)
            ,'%'
            ) AS purchase_rate
    FROM sub_CTE;
    ```

    Result:

    | campaign    | purchase_cnt | purchase_rate |
    | ----------- | ------------ | ------------- |
    | No Campaign | 268          | 72.83%        |
    | Campaign    | 1509         | 70.45%        |

    > Yes. Campaign made user purchase more products from Clique Bait website than without campaign.
