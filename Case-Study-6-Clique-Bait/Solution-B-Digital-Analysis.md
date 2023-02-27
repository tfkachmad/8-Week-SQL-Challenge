# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution B. Digital Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. How many users are there?

    Query:

    ```sql
    SELECT
        COUNT(DISTINCT user_id) AS user_total
    FROM
        clique_bait.users;
    ```

    Output:

    | "user_total" |
    |--------------|
    | 500          |

    <br>

2. How many cookies does each user have on average?

    Query:

    ```sql
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
    ```

    Output:

    | "cookies_average" |
    |-------------------|
    | 4                 |

    <br>

3. What is the unique number of visits by all users per month?

    Query:

    ```sql
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
    ```

    Output:

    | "month_name" | "visits_num" |
    |--------------|--------------|
    | January      | 438          |
    | February     | 744          |
    | March        | 458          |
    | April        | 124          |
    | May          | 18           |

    <br>

4. What is the number of events for each event type?

    Query:

    ```sql
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
    ```

    Output:

    | "event_name"  | "events_num" |
    |---------------|--------------|
    | Page View     | 20928        |
    | Add to Cart   | 8451         |
    | Purchase      | 1777         |
    | Ad Impression | 876          |
    | Ad Click      | 702          |

    <br>

5. What is the percentage of visits which have a purchase event?

    Query:

    ```sql
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
    ```

    Output:

    | "visit_with_purchase_percentage" |
    |----------------------------------|
    | 49.86                            |

    <br>

6. What is the percentage of visits which view the checkout page but do not have a purchase event?

    Query:

    ```sql
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
                FROM clique_bait.events)), 2) AS checkout_no_purchase_percentage
    FROM
        checkout_no_purchase_visits;
    ```

    Output:

    | "checkout_no_purchase_percentage" |
    |-----------------------------------|
    | 59.01                             |

    <br>

7. What are the top 3 pages by number of views?

    Query:

    ```sql
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
    ```

    Output:

    | "page_name"  | "views_num" |
    |--------------|-------------|
    | All Products | 3174        |
    | Checkout     | 2103        |
    | Home Page    | 1782        |

    <br>

8. What is the number of views and cart adds for each product category?

    Query:

    ```sql
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
    ```

    Output:

    | "product_category" | "page_view_num" | "add_to_cart_num" |
    |--------------------|-----------------|-------------------|
    |                    | 7059            |                   |
    | Shellfish          | 6204            | 3792              |
    | Fish               | 4633            | 2789              |
    | Luxury             | 3032            | 1870              |

    <br>

9. What are the top 3 products by purchases?

    Query:

    ```sql
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
    ```

    Output:

    | "page_name" | "purchased_total" |
    |-------------|-------------------|
    | Lobster     | 754               |
    | Oyster      | 726               |
    | Crab        | 719               |

---
