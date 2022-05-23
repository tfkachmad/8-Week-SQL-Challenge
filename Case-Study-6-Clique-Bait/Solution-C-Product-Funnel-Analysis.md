# :fishing_pole_and_fish: Case Study 6 - Clique Bait: Solution C. Product Funnel Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Create `products_details` table:

```sql
DROP TABLE
IF EXISTS clique_bait.products_details;
    WITH views_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        WHERE p.product_category IS NOT NULL
        GROUP BY p.page_name
        )
        ,add_to_cart_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS added_to_cart_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
        GROUP BY p.page_name
        )
        ,purchase_CTE
    AS (
        SELECT DISTINCT e.visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        )
        ,add_to_cart_only_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS added_to_cart_only_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
            AND e.visit_id NOT IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        GROUP BY p.page_name
        )
        ,purchased_CTE
    AS (
        SELECT p.page_name
            ,COUNT(*) AS purchase_count
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
    SELECT v.page_name AS product_name
        ,views_count
        ,added_to_cart_count
        ,added_to_cart_only_count
        ,purchase_count
    INTO clique_bait.products_details
    FROM views_CTE AS v
    JOIN add_to_cart_CTE AS c
        ON v.page_name = c.page_name
    JOIN add_to_cart_only_CTE AS co
        ON v.page_name = co.page_name
    JOIN purchased_CTE AS p
        ON v.page_name = p.page_name
    ORDER BY v.page_name;
--
--	products_details table result
SELECT *
FROM clique_bait.products_details;
```

`products_details` table:

| product_name   | views_count | added_to_cart_count | added_to_cart_only_count | purchase_count |
|----------------|-------------|---------------------|--------------------------|----------------|
| Abalone        | 2457        | 932                 | 233                      | 699            |
| Black Truffle  | 2393        | 924                 | 217                      | 707            |
| Crab           | 2513        | 949                 | 230                      | 719            |
| Kingfish       | 2479        | 920                 | 213                      | 707            |
| Lobster        | 2515        | 968                 | 214                      | 754            |
| Oyster         | 2511        | 943                 | 217                      | 726            |
| Russian Caviar | 2509        | 946                 | 249                      | 697            |
| Salmon         | 2497        | 938                 | 227                      | 711            |
| Tuna           | 2446        | 931                 | 234                      | 697            |

<br/>

- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Create `product_category_details` table:

```sql
DROP TABLE
IF EXISTS clique_bait.product_category_details;
    WITH views_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS views_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        WHERE p.product_category IS NOT NULL
        GROUP BY p.product_category
        )
        ,add_to_cart_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS added_to_cart_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
        GROUP BY p.product_category
        )
        ,purchase_CTE
    AS (
        SELECT DISTINCT e.visit_id
        FROM clique_bait.events AS e
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE ei.event_name LIKE 'purchase'
        )
        ,add_to_cart_only_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS added_to_cart_only_count
        FROM clique_bait.events AS e
        JOIN clique_bait.page_hierarchy AS p
            ON e.page_id = p.page_id
        JOIN clique_bait.event_identifier AS ei
            ON e.event_type = ei.event_type
        WHERE p.product_category IS NOT NULL
            AND ei.event_name LIKE 'Add%'
            AND e.visit_id NOT IN (
                SELECT visit_id
                FROM purchase_CTE
                )
        GROUP BY p.product_category
        )
        ,purchased_CTE
    AS (
        SELECT p.product_category
            ,COUNT(*) AS purchase_count
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
        GROUP BY p.product_category
        )
    SELECT v.product_category
        ,views_count
        ,added_to_cart_count
        ,added_to_cart_only_count
        ,purchase_count
    INTO clique_bait.product_category_details
    FROM views_CTE AS v
    JOIN add_to_cart_CTE AS c
        ON v.product_category = c.product_category
    JOIN add_to_cart_only_CTE AS co
        ON v.product_category = co.product_category
    JOIN purchased_CTE AS p
        ON v.product_category = p.product_category
    ORDER BY v.product_category;
--
-- product_category_details table result
SELECT *
FROM clique_bait.product_category_details;
```

`product_category_details` table:

| product_category | views_count | added_to_cart_count | added_to_cart_only_count | purchase_count |
|------------------|-------------|---------------------|--------------------------|----------------|
| Fish             | 7422        | 2789                | 674                      | 2115           |
| Luxury           | 4902        | 1870                | 466                      | 1404           |
| Shellfish        | 9996        | 3792                | 894                      | 2898           |

<br/>

Use your 2 new output tables - answer the following questions:

1. Which product had the most views, cart adds and purchases?

    Query:

    ```sql
    -- Finding the maximum from views_count, added_to_cart_count, purchase_count column
    WITH max_CTE
    AS (
        SELECT MAX(views_count) AS most_views
            ,MAX(added_to_cart_count) AS most_cart_adds
            ,MAX(purchase_count) AS most_purchases
        FROM clique_bait.products_details
        )
        -- Finding the product with maximum views_count
        ,views_CTE
    AS (
        SELECT product_name AS most_viewed_product
        FROM clique_bait.products_details
        WHERE views_count = (
                SELECT most_views
                FROM max_CTE
                )
        )
        -- Finding the product with maximum added_to_cart_count
        ,cart_CTE
    AS (
        SELECT product_name AS most_added_to_cart_product
        FROM clique_bait.products_details
        WHERE added_to_cart_count = (
                SELECT most_cart_adds
                FROM max_CTE
                )
        )
        -- Finding the product with maximum purchase_count
        ,purchase_CTE
    AS (
        SELECT product_name AS most_purchased_product
        FROM clique_bait.products_details
        WHERE purchase_count = (
                SELECT most_purchases
                FROM max_CTE
                )
        )
    SELECT *
    FROM views_CTE
        ,cart_CTE
        ,purchase_CTE;
    ```

    Output:

    | most_viewed_product | most_added_to_cart_product | most_purchased_product |
    |---------------------|----------------------------|------------------------|
    | Lobster             | Lobster                    | Lobster                |

    <br/>

2. Which product was most likely to be abandoned?

    - For this question, the products that are least purchased by the users are the products that most likely to be abandoned.

    Query:

    ```sql
    WITH min_CTE
    AS (
        SELECT MIN(purchase_count) AS least_purchases
        FROM clique_bait.products_details
        )
        ,purchase_CTE
    AS (
        SELECT product_name AS least_purchased_product
        FROM clique_bait.products_details
        WHERE purchase_count = (
                SELECT least_purchases
                FROM min_CTE
                )
        )
    SELECT *
    FROM purchase_CTE;
    ```

    Output:

    | least_purchased_product |
    |-------------------------|
    | Russian Caviar          |
    | Tuna                    |

    <br/>

3. Which product had the highest view to purchase percentage?

    - To answer this question, find the view to purchase ration percentage for every product.
    - Order the result and show the TOP 1 from the `products` and its `view_to_purchase_percentage`.

    Query:

    ```sql
    WITH percentage_CTE
    AS (
        SELECT product_name
            ,views_count
            ,purchase_count
            ,ROUND((CAST(purchase_count AS FLOAT) / views_count * 100), 2) AS view_to_purchase_percentage
        FROM clique_bait.products_details
        )
    SELECT TOP 1 product_name
        ,CONCAT(view_to_purchase_percentage, '%') AS view_to_purchase_percentage
    FROM percentage_CTE
    ORDER BY view_to_purchase_percentage DESC;
    ```

    Output:

    | product_name | view_to_purchase_percentage |
    |--------------|-----------------------------|
    | Lobster      | 29.98%                      |

4. What is the average conversion rate from view to cart add?

    - First, find every conversion rate for each visit.
    - Use `AVG()` function to find the average from the result.

    Query:

    ```sql
    WITH view_to_cart_CTE
    AS (
        SELECT product_name
            ,views_count
            ,added_to_cart_count
            ,(CAST(added_to_cart_count AS FLOAT) / views_count * 100) AS view_to_cart_add_ratio
        FROM clique_bait.products_details
        )
    SELECT ROUND(AVG(view_to_cart_add_ratio), 2) AS view_to_cart_add_ratio_avg
    FROM view_to_cart_CTE;
    ```

    Output:

    | view_to_cart_add_ratio_avg |
    |----------------------------|
    | 37.87                      |

5. What is the average conversion rate from cart add to purchase?

    - First, find every conversion rate for each visit.
    - Use `AVG()` function to find the average from the result.

    Query:

    ```sql
    WITH cart_add_to_purchase_CTE
    AS (
        SELECT product_name
            ,added_to_cart_count
            ,purchase_count
            ,(CAST(purchase_count AS FLOAT) / added_to_cart_count * 100) AS view_to_cart_add_ratio
        FROM clique_bait.products_details
        )
    SELECT ROUND(AVG(view_to_cart_add_ratio), 2) AS cart_add_to_purchase_ratio_avg
    FROM cart_add_to_purchase_CTE;
    ```

    Output:

    | cart_add_to_purchase_ratio_avg |
    |--------------------------------|
    | 75.93                          |
