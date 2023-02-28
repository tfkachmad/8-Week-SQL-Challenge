# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution C. Product Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. What are the top 3 products by total revenue before discount?

    Query:

    ```sql
    SELECT
        p.product_name,
        TO_CHAR(SUM(s.qty * s.price), '999,999') AS gross_revenue_total
    FROM
        balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
    GROUP BY
        1
    ORDER BY
        2 DESC
    LIMIT 3;
    ```

    Output:

    | "product_name"               | "gross_revenue_total" |
    |------------------------------|-----------------------|
    | Blue Polo Shirt - Mens       |  217,683              |
    | Grey Fashion Jacket - Womens |  209,304              |
    | White Tee Shirt - Mens       |  152,000              |

    <br>

2. What is the total quantity, revenue and discount for each segment?

    Query:

    ```sql
    WITH segment_subset AS (
        SELECT
            p.segment_name,
            s.qty,
            (s.qty * s.price) AS gross_revenue,
            ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
        FROM
            balanced_tree.sales AS s
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
    ```

    Output:

    | "segment_name" | "quantity_total" | "net_revenue_total" | "discount_total" |
    |----------------|------------------|---------------------|------------------|
    | Jacket         |   11,385         |  322,686.3          |   44,296.7       |
    | Jeans          |   11,349         |  182,996.5          |   25,353.5       |
    | Shirt          |   11,265         |  356,540.8          |   49,602.2       |
    | Socks          |   11,217         |  270,947.8          |   37,029.2       |

    <br>

3. What is the top selling product for each segment?

    Query:

    ```sql
    WITH segment_product_sales AS (
        SELECT
            p.segment_name,
            p.product_name,
            TO_CHAR(SUM(qty), '999,999') AS quantity_sold
        FROM
            balanced_tree.sales AS s
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
        rank_num = 1
    ORDER BY
        3 DESC;
    ```

    Output:

    | "segment_name" | "top_selling_product"         | "quantity_sold" |
    |----------------|-------------------------------|-----------------|
    | Jacket         | Grey Fashion Jacket - Womens  |    3,876        |
    | Jeans          | Navy Oversized Jeans - Womens |    3,856        |
    | Shirt          | Blue Polo Shirt - Mens        |    3,819        |
    | Socks          | Navy Solid Socks - Mens       |    3,792        |

    <br>

4. What is the total quantity, revenue and discount for each category?

    Query:

    ```sql
    WITH category_subset AS (
        SELECT
            p.category_name,
            s.qty,
            (s.qty * s.price) AS gross_revenue,
            ROUND(((s.qty * s.price) * (s.discount::NUMERIC / 100)), 1) AS discount
        FROM
            balanced_tree.sales AS s
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
    ```

    Output:

    | "category_name" | "quantity_total" | "net_revenue_total" | "discount_total" |
    |-----------------|------------------|---------------------|------------------|
    | Womens          |   22,734         |  505,682.8          |   69,650.2       |
    | Mens            |   22,482         |  627,488.6          |   86,631.4       |

    <br>

5. What is the top selling product for each category?

    Query:

    ```sql
    WITH category_product_sales AS (
        SELECT
            p.category_name,
            p.product_name,
            TO_CHAR(SUM(qty), '999,999') AS quantity_sold
        FROM
            balanced_tree.sales AS s
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
        rank_num = 1;
    ```

    Output:

    | "category_name" | "top_selling_product"        | "quantity_sold" |
    |-----------------|------------------------------|-----------------|
    | Mens            | Blue Polo Shirt - Mens       |    3,819        |
    | Womens          | Grey Fashion Jacket - Womens |    3,876        |

    <br>

6. What is the percentage split of revenue by product for each segment?

    Query:

    ```sql
    WITH segment_product_subset AS (
        SELECT
            p.segment_name,
            p.product_name,
            (s.qty * s.price) AS gross_revenue,
            ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
        FROM
            balanced_tree.sales AS s
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
    ```

    Output:

    | "segment_name" | "product_name"                   | "revenue_share_percentage" |
    |----------------|----------------------------------|----------------------------|
    | Jacket         | Grey Fashion Jacket - Womens     | 56.99                      |
    | Jacket         | Khaki Suit Jacket - Womens       | 23.57                      |
    | Jacket         | Indigo Rain Jacket - Womens      | 19.44                      |
    | Jeans          | Black Straight Jeans - Womens    | 58.14                      |
    | Jeans          | Navy Oversized Jeans - Womens    | 24.04                      |
    | Jeans          | Cream Relaxed Jeans - Womens     | 17.82                      |
    | Shirt          | Blue Polo Shirt - Mens           | 53.53                      |
    | Shirt          | White Tee Shirt - Mens           | 37.48                      |
    | Shirt          | Teal Button Up Shirt - Mens      | 8.99                       |
    | Socks          | Navy Solid Socks - Mens          | 44.24                      |
    | Socks          | Pink Fluro Polkadot Socks - Mens | 35.57                      |
    | Socks          | White Striped Socks - Mens       | 20.20                      |

    <br>

7. What is the percentage split of revenue by segment for each category?

    Query:

    ```sql
    WITH category_segment_subset AS (
        SELECT
            p.category_name,
            p.segment_name,
            (s.qty * s.price) AS gross_revenue,
            ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
        FROM
            balanced_tree.sales AS s
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
    ```

    Output:

    | "category_name" | "segment_name" | "revenue_share_percentage" |
    |-----------------|----------------|----------------------------|
    | Mens            | Shirt          | 56.82                      |
    | Mens            | Socks          | 43.18                      |
    | Womens          | Jacket         | 63.81                      |
    | Womens          | Jeans          | 36.19                      |

    <br>

8. What is the percentage split of total revenue by category?

    Query:

    ```sql
    WITH category_subset AS (
        SELECT
            p.category_name,
            (s.qty * s.price) AS gross_revenue,
            ((s.qty * s.price) * (s.discount::NUMERIC / 100)) AS discount
        FROM
            balanced_tree.sales AS s
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
    ```

    Output:

    | "category_name" | "revenue_share_percentage" |
    |-----------------|----------------------------|
    | Mens            | 55.37                      |
    | Womens          | 44.63                      |

    <br>

9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions).

    Query:

    ```sql
    WITH product_txn_num AS (
        SELECT
            p.product_name,
            COUNT(*) AS transactions_num
        FROM
            balanced_tree.sales AS s
            JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
        GROUP BY
            1
    )
    SELECT
        product_name,
        ROUND((100 * transactions_num::NUMERIC / (
                SELECT
                    COUNT(DISTINCT txn_id)
                FROM balanced_tree.sales)), 2) AS penetration_rate
    FROM
        product_txn_num
    ORDER BY
        2 DESC;
    ```

    Output:

    | "product_name"                   | "penetration_rate" |
    |----------------------------------|--------------------|
    | Navy Solid Socks - Mens          | 51.24              |
    | Grey Fashion Jacket - Womens     | 51.00              |
    | Navy Oversized Jeans - Womens    | 50.96              |
    | White Tee Shirt - Mens           | 50.72              |
    | Blue Polo Shirt - Mens           | 50.72              |
    | Pink Fluro Polkadot Socks - Mens | 50.32              |
    | Indigo Rain Jacket - Womens      | 50.00              |
    | Khaki Suit Jacket - Womens       | 49.88              |
    | Black Straight Jeans - Womens    | 49.84              |
    | White Striped Socks - Mens       | 49.72              |
    | Cream Relaxed Jeans - Womens     | 49.72              |
    | Teal Button Up Shirt - Mens      | 49.68              |

    <br>

10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

    Query:

    ```sql
    WITH subset AS (
        SELECT
            s.txn_id,
            p.product_name,
            p.product_id
        FROM
            balanced_tree.sales AS s
            JOIN balanced_tree.product_details AS p ON s.prod_id = p.product_id
    ),
    product_combination AS (
        SELECT
            s1.product_name AS product_1,
            s2.product_name AS product_2,
            s3.product_name AS product_3,
            COUNT(*) AS combination_total
    FROM
        subset AS s1
        JOIN subset AS s2 ON s1.txn_id = s2.txn_id
            AND s1.product_id > s2.product_id
        JOIN subset AS s3 ON s2.txn_id = s3.txn_id
            AND s2.product_id > s3.product_id
    GROUP BY
        1,
        2,
        3
    ORDER BY
        4 DESC
    LIMIT 1
    )
    SELECT
        (product_1 || ', ' || product_2 || ', ' || product_3) AS product_combination,
        combination_total
    FROM
        product_combination
    ```

    Output:

    | "product_combination"                                                             | "combination_total" |
    |-----------------------------------------------------------------------------------|---------------------|
    | Teal Button Up Shirt - Mens, Grey Fashion Jacket - Womens, White Tee Shirt - Mens | 352                 |

---
