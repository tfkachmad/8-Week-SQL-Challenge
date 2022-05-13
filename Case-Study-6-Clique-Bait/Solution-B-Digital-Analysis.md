# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution B. Digital Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. How many users are there?

    - Counting the distinct values of `user_id` will show the number of Clique Bait users.

    Code:

    ```sql
    SELECT COUNT(DISTINCT [user_id]) AS users_count
    FROM clique_bait.users;
    ```

    Output:

    | users_count |
    | ----------- |
    | 500         |

    <br/>

2. How many cookies does each user have on average?

    - First, find the number of `cookie_id` of each user by aggregate the `cookie_id` using `COUNT()` function and group the result by the `user_id`.
    - Use `AVG()` on the result to get the average result.

    Code:

    ```sql
    WITH user_cookies_CTE
    AS (
        SELECT [user_id]
            ,COUNT(cookie_id) AS cookies
        FROM clique_bait.users
        GROUP BY [user_id]
        )
    SELECT AVG(cookies) AS user_average_cookies
    FROM user_cookies_CTE;
    ```

    Output:

    | user_average_cookies |
    | -------------------- |
    | 3                    |

    <br/>

3. What is the unique number of visits by all users per month?

    - Find the month name using `DATENAME(`) function.
    - Aggregate the unique value from `visit_id` with `COUNT()` function and group the result by the month name.

    Code:

    ```sql
    WITH month_cte
    AS (
        SELECT visit_id
            ,event_time
            ,DATEPART(MONTH, event_time) AS month_num
            ,DATENAME(MONTH, event_time) AS [month]
        FROM clique_bait.[events]
        )
    SELECT [month]
        ,COUNT(DISTINCT visit_id) AS unique_visits_count
    FROM month_cte
    GROUP BY month_num
        ,[month]
    ORDER BY month_num;
    ```

    Output:

    | month    | unique_visits_count |
    | -------- | ------------------- |
    | January  | 876                 |
    | February | 1488                |
    | March    | 916                 |
    | April    | 248                 |
    | May      | 36                  |

    <br/>

4. What is the number of events for each event type?

    - JOIN the event_identifier with the events table to get `event_name` column.
    - `COUNT(*)` the resulted table to find the number of events and group the result by the `event_name`.

    Code:

    ```sql
    SELECT ei.event_name
        ,COUNT(*) AS events_count
    FROM clique_bait.events AS e
    JOIN clique_bait.event_identifier AS ei
        ON e.event_type = ei.event_type
    GROUP BY ei.event_type
        ,ei.event_name
    ORDER BY ei.event_type;
    ```

    Output:

    | event_name    | events_count |
    | ------------- | ------------ |
    | Page View     | 20928        |
    | Add to Cart   | 8451         |
    | Purchase      | 1777         |
    | Ad Impression | 876          |
    | Ad Click      | 702          |

    <br/>

5. What is the percentage of visits which have a purchase event?

    - Create a CTE, `purchase_CTE`, to find the number of purchase events.

        ```sql
        SELECT CAST(COUNT(*) AS FLOAT) AS purchase_events
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        ```

    - Create another CTE, `total_events_CTE`, to find the number of events.

        ```sql
        SELECT COUNT(*) AS total_events
        FROM clique_bait.events
        ```

    - Calculate the result from the two CTEs to find the result by dividing the number of purchase events and the number of total events.

        ```sql
        SELECT CONCAT (
                    ROUND((
                            purchase_events / (
                                SELECT total_events
                                FROM total_events_CTE
                                ) * 100
                            ), 2)
                    ,'%'
                    ) AS purchase_events_percentage
            FROM purchase_CTE;
        ```

    <details>
    <summary>Code</summary>

    ```sql
    WITH purchase_CTE
    AS (
        SELECT CAST(COUNT(*) AS FLOAT) AS purchase_events
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        )
        ,total_events_CTE
    AS (
        SELECT COUNT(*) AS total_events
        FROM clique_bait.events
        )
    SELECT CONCAT (
            ROUND((
                    purchase_events / (
                        SELECT total_events
                        FROM total_events_CTE
                        ) * 100
                    ), 2)
            ,'%'
            ) AS purchase_events_percentage
    FROM purchase_CTE;
    ```

    </details>

    Output:

    | purchase_events_percentage |
    | -------------------------- |
    | 5.43%                      |

    <br/>

6. What is the percentage of visits which view the checkout page but do not have a purchase event?

    - Create a CTE, `purchase_CTE`, to find every user that purchasing product from Clique Bait website by their `visit_id`.

        ```sql
        SELECT DISTINCT e.visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        ```

    - Create another CTE, `checkout_CTE`, to find the number of visit that have accessed `checkout` page and that `visit_id` is not on the first CTE.

        ```sql
        SELECT CAST(COUNT(*) AS FLOAT) AS checkout_only_events
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        WHERE p.page_name LIKE 'checkout'
            AND e.visit_id NOT IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        ```

    - Create another CTE, `total_events_CTE`, to find the total number of events.

        ```sql
        SELECT COUNT(*) AS total_events
        FROM clique_bait.events
        ```

    - Calculate the result from the two CTEs to find the result by dividing the number of purchase events and the number of total events.

        ```sql
        SELECT CONCAT (
                ROUND((
                        checkout_only_events / (
                            SELECT total_events
                            FROM total_events_CTE
                            ) * 100
                        ), 2)
                ,'%'
                ) AS checkout_only_events_percentage
        FROM checkout_CTE;
        ```

    <details>
    <summary>Code</summary>

    ```sql
    WITH purchase_CTE
    AS (
        SELECT DISTINCT e.visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        )
        ,checkout_CTE
    AS (
        SELECT CAST(COUNT(*) AS FLOAT) AS checkout_only_events
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        WHERE p.page_name LIKE 'checkout'
            AND e.visit_id NOT IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        )
        ,total_events_CTE
    AS (
        SELECT COUNT(*) AS total_events
        FROM clique_bait.events
        )
    SELECT CONCAT (
            ROUND((
                    checkout_only_events / (
                        SELECT total_events
                        FROM total_events_CTE
                        ) * 100
                    ), 2)
            ,'%'
            ) AS checkout_only_events_percentage
    FROM checkout_CTE;
    ```

    </details>

    Output:

    | checkout_only_events_percentage |
    | ------------------------------- |
    | 1%                              |

    <br/>

7. What are the top 3 pages by number of views?

    - Create another CTE, `pages_view_CTE`, to find number of events for each page_name on Clique Bait website.

        ```sql
        SELECT p.page_name
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        GROUP BY p.page_name
        ```

    - Create another CTE, `rank_CTE`, to give rank the result from the first CTE based on the views_count.

        ```sql
        SELECT page_name
            ,views_count
            ,RANK() OVER (
                ORDER BY views_count DESC
                ) AS views_count_rank
        FROM pages_view_CTE
        ```

    - Finally, display the page_name, views_count for only the rank that is less than or equal to 3 to get the top 3 pages by number of views.

        ```sql
        SELECT page_name
            ,views_count
        FROM rank_CTE
        WHERE views_count_rank <= 3
        ORDER BY views_count_rank;
        ```

    <details>
    <summary>Code</summary>

    ```sql
    WITH pages_view_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        GROUP BY p.page_name
        )
        ,rank_CTE
    AS (
        SELECT page_name
            ,views_count
            ,RANK() OVER (
                ORDER BY views_count DESC
                ) AS views_count_rank
        FROM pages_view_CTE
        )
    SELECT page_name
        ,views_count
    FROM rank_CTE
    WHERE views_count_rank <= 3
    ORDER BY views_count_rank;
    ```

    </details>

    Output:

    | page_name    | views_count |
    | ------------ | ----------- |
    | All Products | 4752        |
    | Lobster      | 2515        |
    | Crab         | 2513        |

    <br/>

8. What is the number of views and cart adds for each product category?

    - First, find the of `views_count` for each `product_category` from Clique Bait website with `views_CTE` CTE.

        ```sql
        SELECT p.product_category
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        GROUP BY p.product_category
        ```

    - Next, find the of `views_count` for each `product_category` from Clique Bait website but only for the `Add to cart` event_name with `add_to_cart_CTE` CTE.

        ```sql
        SELECT p.product_category
            ,COUNT(*) AS add_to_cart_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'Add%'
        GROUP BY p.product_category
        ```

    - Joining the two CTE results based on the product_category column will display the result for the question. `LEFT JOIN` is used to display the page_category that is `NULL`. This `NULL` page_category are pages that is not product page.

        ```sql
        SELECT t1.product_category
            ,views_count
            ,add_to_cart_count
        FROM views_CTE AS t1
        LEFT JOIN add_to_cart_CTE AS t2
            ON t1.product_category = t2.product_category;
        ```

    <details>
    <summary>Code</summary>

    ```sql
    WITH views_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        GROUP BY p.product_category
        )
        ,add_to_cart_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS add_to_cart_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'Add%'
        GROUP BY p.product_category
        )
    SELECT t1.product_category
        ,views_count
        ,add_to_cart_count
    FROM views_CTE AS t1
    LEFT JOIN add_to_cart_CTE AS t2
        ON t1.product_category = t2.product_category;
    ```

    </details>

    Output:

    | product_category | views_count | add_to_cart_count |
    | ---------------- | ----------- | ----------------- |
    | NULL             | 10414       | NULL              |
    | Fish             | 7422        | 2789              |
    | Shellfish        | 9996        | 3792              |
    | Luxury           | 4902        | 1870              |

    <br/>

9. What are the top 3 products by purchases?

    - Create `purchase_CTE` to find every `visit_id` that are purchasing product from Clique Bait website.

        ```sql
        SELECT DISTINCT visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'Purchase'
        ```

    - Create `products_CTE` to find every user's `visit_id` that visit product page by finding the product_category that is not NULL. Find every products that added to cart by user on their visit. Finally, find the `visit_id` that is in the first CTE. Aggregate the result to get the number of products purchased by `COUNT()` function and group the result by each page (product name).

        ```sql
        SELECT p.page_name
            ,COUNT(*) AS product_purchased
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
            AND e.visit_id IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        ```

    - Create another CTE based on the `products_CTE`, called `rank_CTE` to rank the number of product purchased by users.

        ```sql
        SELECT page_name
            ,product_purchased
            ,RANK() OVER (
                ORDER BY product_purchased DESC
                ) AS product_rank
        FROM products_CTE
        ```

    - Finally, show the `page_name` (products name) and the number of each product purchased by only showing the rank result from previous CTE that is less than or equal to 3.

        ```sql
        SELECT page_name
            ,product_purchased
        FROM rank_CTE
        WHERE product_rank <= 3;
        ```

    <details>
    <summary>Code</summary>

    ```sql
    WITH purchase_CTE
    AS (
        SELECT DISTINCT visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'Purchase'
        )
        ,products_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS product_purchased
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
            AND e.visit_id IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        GROUP BY p.page_name
        )
        ,rank_CTE
    AS (
        SELECT page_name
            ,product_purchased
            ,RANK() OVER (
                ORDER BY product_purchased DESC
                ) AS product_rank
        FROM products_CTE
        )
    SELECT page_name
        ,product_purchased
    FROM rank_CTE
    WHERE product_rank <= 3;
    ```

    </details>

    Output:

    | page_name | product_purchased |
    | --------- | ----------------- |
    | Lobster   | 754               |
    | Oyster    | 726               |
    | Crab      | 719               |
