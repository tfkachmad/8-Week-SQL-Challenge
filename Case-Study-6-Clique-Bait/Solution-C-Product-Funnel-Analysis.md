# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution C. Product Funnel Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Create `product_funnel` table to display the aggregated result on product name level.

```sql
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
```

`product_funnel` table:

| "product_name" | "viewed_num" | "added_to_cart_num" | "added_to_cart_only_num" | "purchased_num" |
|----------------|--------------|---------------------|--------------------------|-----------------|
| Oyster         | 1568         | 943                 | 217                      | 726             |
| Crab           | 1564         | 949                 | 230                      | 719             |
| Russian Caviar | 1563         | 946                 | 249                      | 697             |
| Salmon         | 1559         | 938                 | 227                      | 711             |
| Kingfish       | 1559         | 920                 | 213                      | 707             |
| Lobster        | 1547         | 968                 | 214                      | 754             |
| Abalone        | 1525         | 932                 | 233                      | 699             |
| Tuna           | 1515         | 931                 | 234                      | 697             |
| Black Truffle  | 1469         | 924                 | 217                      | 707             |

<br>

- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Create `category_funnel` table that display the aggregated result on the product category level:

```sql
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
```

`product_category_details` table:

| "product_category" | "viewed_num" | "added_to_cart_num" | "added_to_cart_only_num" | "purchased_num" |
|--------------------|--------------|---------------------|--------------------------|-----------------|
| Shellfish          | 6204         | 3792                | 894                      | 2898            |
| Fish               | 4633         | 2789                | 674                      | 2115            |
| Luxury             | 3032         | 1870                | 466                      | 1404            |

<br>

Use your 2 new output tables - answer the following questions:

1. Which product had the most views, cart adds and purchases?

    Query:

    ```sql
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
    ```

    Output:

    | "most_viewed_product" | "most_added_to_cart_product" | "most_purchased_product" |
    |-----------------------|------------------------------|--------------------------|
    | Oyster                | Lobster                      | Lobster                  |

    <br>

2. Which product was most likely to be abandoned?

    Query:

    ```sql
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
    ```

    Output:

    | "product_name" |
    |----------------|
    | Tuna           |
    | Russian Caviar |

    <br>

3. Which product had the highest view to purchase percentage?

    Query:

    ```sql
    SELECT
        product_name,
        ROUND((purchased_num::NUMERIC / viewed_num), 2) * 100 AS view_to_purchase_percentage
    FROM
        product_funnel
    ORDER BY
        2 DESC
    LIMIT 1;
    ```

    Output:

    | "product_name" | "view_to_purchase_percentage" |
    |----------------|-------------------------------|
    | Lobster        | 49.00                         |

    <br>

4. What is the average conversion rate from view to cart add?

    Query:

    ```sql
    SELECT
        ROUND(AVG(100 * added_to_cart_num::NUMERIC / viewed_num), 2) AS view_to_cart_add_percentage
    FROM
        product_funnel;
    ```

    Output:

    | "view_to_cart_add_percentage" |
    |-------------------------------|
    | 60.95                         |

    <br>

5. What is the average conversion rate from cart add to purchase?

    Query:

    ```sql
    SELECT
        ROUND(AVG(100 * purchased_num::NUMERIC / added_to_cart_num), 2) AS cart_to_purchase_percentage
    FROM
        product_funnel;
    ```

    Output:

    | "cart_to_purchase_percentage" |
    |-------------------------------|
    | 75.93                         |

---
