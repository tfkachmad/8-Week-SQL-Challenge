# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution C. Product Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. What are the top 3 products by total revenue before discount?

    - First, find the total revenue for each product by aggregating the product from `qty` and `sales` using `SUM()` function and group the result for each product.
    - Generate a row number for each product where each number representing the order of the total revenue from the highest to the lowest.
    - Find the row number that is less than or equal to 3 to find the top 3 product with highest total revenue.

    Query:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT p.product_name
            ,SUM((s.qty * s.price)) AS revenue_total
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.product_name
        )
        ,row_CTE
    AS (
        SELECT ROW_NUMBER() OVER (
                ORDER BY revenue_total DESC
                ) AS row_num
            ,product_name
            ,FORMAT(revenue_total, '#,#') AS revenue_total
        FROM revenue_CTE
        )
    SELECT product_name
        ,revenue_total
    FROM row_CTE
    WHERE row_num <= 3;
    ```

    Output:

    | product_name                 | revenue_total |
    | ---------------------------- | ------------- |
    | Blue Polo Shirt - Mens       | 217,683       |
    | Grey Fashion Jacket - Womens | 209,304       |
    | White Tee Shirt - Mens       | 152,000       |

    <br/>

2. What is the total quantity, revenue and discount for each segment?

    - The total quantity acquired by aggregating the `qty` column using `SUM()` function, the revenue acquired from aggregating the product of qty and price using `SUM()` function, and the discount acquired by aggregating the product of the revenue and the discount for each product using `SUM()` function.
    - The result than grouped for each segment.

    Query:

    ```sql
    WITH sub_CTE
    AS (
        SELECT p.segment_id
            ,p.segment_name
            ,SUM(s.qty) AS quantity
            ,SUM(s.qty * s.price) AS revenue
            ,SUM(s.qty * s.price * (CAST(s.discount AS FLOAT) / 100)) AS discount
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.segment_id
            ,p.segment_name
        )
    SELECT segment_name
        ,quantity
        ,FORMAT(revenue, '#,#') AS revenue
        ,FORMAT(discount, '#,#.##') AS discount
    FROM sub_CTE
    ORDER BY segment_id;
    ```

    Output:

    | segment_name | total_quantity | total_revenue | total_discount |
    | ------------ | -------------- | ------------- | -------------- |
    | Jeans        | 11349          | 208,350       | 25,343.97      |
    | Jacket       | 11385          | 366,983       | 44,277.46      |
    | Shirt        | 11265          | 406,143       | 49,594.27      |
    | Socks        | 11217          | 307,977       | 37,013.44      |

    <br/>

3. What is the top selling product for each segment?

    - Find the highests quantity sold for each product for each segment by aggregating the `qty` column with `SUM()` function and group the result for each product for each segments.
    - Generate a numbered column, `row_num`, that represent the order of total item sold for each product for each segment from highest to lowest.
    - Show the result by finding the row `row_num` that equal to 1.

    Query:

    ```sql
    WITH sold_CTE
    AS (
        SELECT p.segment_id
            ,p.segment_name
            ,p.product_name
            ,SUM(s.qty) AS sold
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.segment_id
            ,p.segment_name
            ,p.product_name
        )
        ,row_CTE
    AS (
        SELECT ROW_NUMBER() OVER (
                PARTITION BY segment_id ORDER BY sold DESC
                ) AS row_num
            ,*
        FROM sold_CTE
        )
    SELECT segment_name
        ,product_name
        ,sold
    FROM row_CTE
    WHERE row_num = 1
    ORDER BY segment_id;
    ```

    Output:

    | segment_name | product_name                  | sold |
    | ------------ | ----------------------------- | ---- |
    | Jeans        | Navy Oversized Jeans - Womens | 3856 |
    | Jacket       | Grey Fashion Jacket - Womens  | 3876 |
    | Shirt        | Blue Polo Shirt - Mens        | 3819 |
    | Socks        | Navy Solid Socks - Mens       | 3792 |

    <br/>

4. What is the total quantity, revenue and discount for each category?

    - Use the same query as question 2. But, change the grouping result by the category rather than segment.

    Query:

    ```sql
    WITH sub_CTE
    AS (
        SELECT p.category_id
            ,p.category_name
            ,SUM(s.qty) AS quantity
            ,SUM(s.qty * s.price) AS revenue
            ,SUM(s.qty * s.price * (CAST(s.discount AS FLOAT) / 100)) AS discount
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.category_id
            ,p.category_name
        )
    SELECT category_name
        ,quantity
        ,FORMAT(revenue, '#,#') AS revenue
        ,FORMAT(discount, '#,#.##') AS discount
    FROM sub_CTE
    ORDER BY category_id;
    SELECT TOP 100 *
    FROM balanced_tree.sales AS s
    JOIN balanced_tree.product_details AS p
        ON s.prod_id = p.product_id;
    ```

    Output:

    | category_name | total_quantity | total_revenue | total_discount |
    | ------------- | -------------- | ------------- | -------------- |
    | Womens        | 22734          | 575,333       | 69,621.43      |
    | Mens          | 22482          | 714,120       | 86,607.71      |

    <br/>

5. What is the top selling product for each category?

    - Use the same query as question 3. But, group the aggregate result by the product for each category.

    Query:

    ```sql
    WITH sold_CTE
    AS (
        SELECT p.category_id
            ,p.category_name
            ,p.product_name
            ,SUM(s.qty) AS sold
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.category_id
            ,p.category_name
            ,p.product_name
        )
        ,row_CTE
    AS (
        SELECT ROW_NUMBER() OVER (
                PARTITION BY category_id ORDER BY sold DESC
                ) AS row_num
            ,*
        FROM sold_CTE
        )
    SELECT category_name
        ,product_name
        ,sold
    FROM row_CTE
    WHERE row_num = 1
    ORDER BY category_id;
    ```

    Output:

    | category_name | product_name                 | sold |
    | ------------- | ---------------------------- | ---- |
    | Womens        | Grey Fashion Jacket - Womens | 3876 |
    | Mens          | Blue Polo Shirt - Mens       | 3819 |

    <br/>

6. What is the percentage split of revenue by product for each segment?

    - First, find the total revenue after discount each product for each segment by aggregating the revenue after discount for each product for each segment using `SUM()` function and group the result by product and segment.
    - Calculate the percentage by dividing each product for each segment total revenue by the total revenue.

    Query:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT p.segment_id
            ,p.segment_name
            ,p.product_id
            ,p.product_name
            ,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.segment_id
            ,p.segment_name
            ,p.product_id
            ,p.product_name
        )
        ,calc_CTE
    AS (
        SELECT segment_id
            ,segment_name
            ,product_id
            ,product_name
            ,revenue
            ,(
                revenue / (
                    SELECT SUM(revenue)
                    FROM revenue_CTE
                    )
                ) AS revenue_pct
        FROM revenue_CTE
        )
    SELECT segment_name
        ,product_name
        ,FORMAT(revenue, '#,#.#0') AS revenue
        ,FORMAT(revenue_pct, 'p') AS revenue_pct
    FROM calc_CTE
    ORDER BY segment_id
        ,product_id;
    ```

    Output:

    | segment_name | product_name                     | revenue    | revenue_pct |
    | ------------ | -------------------------------- | ---------- | ----------- |
    | Jeans        | Navy Oversized Jeans - Womens    | 43,992.39  | 3.88%       |
    | Jeans        | Cream Relaxed Jeans - Womens     | 32,606.60  | 2.88%       |
    | Jeans        | Black Straight Jeans - Womens    | 106,407.04 | 9.39%       |
    | Jacket       | Indigo Rain Jacket - Womens      | 62,740.47  | 5.54%       |
    | Jacket       | Grey Fashion Jacket - Womens     | 183,912.12 | 16.23%      |
    | Jacket       | Khaki Suit Jacket - Womens       | 76,052.95  | 6.71%       |
    | Shirt        | Blue Polo Shirt - Mens           | 190,863.93 | 16.84%      |
    | Shirt        | White Tee Shirt - Mens           | 133,622.40 | 11.79%      |
    | Shirt        | Teal Button Up Shirt - Mens      | 32,062.40  | 2.83%       |
    | Socks        | Pink Fluro Polkadot Socks - Mens | 96,377.73  | 8.50%       |
    | Socks        | White Striped Socks - Mens       | 54,724.19  | 4.83%       |
    | Socks        | Navy Solid Socks - Mens          | 119,861.64 | 10.58%      |

    <br/>

7. What is the percentage split of revenue by segment for each category?

    - Use the same query as question 6. Change the aggregate grouping for segment and category.

    Query:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT p.category_id
            ,p.category_name
            ,p.segment_id
            ,p.segment_name
            ,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.category_id
            ,p.category_name
            ,p.segment_id
            ,p.segment_name
        )
        ,calc_CTE
    AS (
        SELECT segment_id
            ,segment_name
            ,category_id
            ,category_name
            ,revenue
            ,(
                revenue / (
                    SELECT SUM(revenue)
                    FROM revenue_CTE
                    )
                ) AS revenue_pct
        FROM revenue_CTE
        )
    SELECT category_name
        ,segment_name
        ,FORMAT(revenue, '#,#.#0') AS revenue
        ,FORMAT(revenue_pct, 'p') AS revenue_pct
    FROM calc_CTE
    ORDER BY segment_id
        ,category_id;
    ```

    Output:

    | category_name | segment_name | revenue    | revenue_pct |
    | ------------- | ------------ | ---------- | ----------- |
    | Womens        | Jeans        | 183,006.03 | 16.15%      |
    | Womens        | Jacket       | 322,705.54 | 28.48%      |
    | Mens          | Shirt        | 356,548.73 | 31.46%      |
    | Mens          | Socks        | 270,963.56 | 23.91%      |

    <br/>

8. What is the percentage split of total revenue by category?

    - Use the same query as question 6. But only group the aggregate result by category.

    Query:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT p.category_id
            ,p.category_name
            ,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.category_id
            ,p.category_name
        )
        ,calc_CTE
    AS (
        SELECT category_id
            ,category_name
            ,revenue
            ,(
                revenue / (
                    SELECT SUM(revenue)
                    FROM revenue_CTE
                    )
                ) AS revenue_pct
        FROM revenue_CTE
        )
    SELECT category_name
        ,FORMAT(revenue, '#,#.##') AS revenue
        ,FORMAT(revenue_pct, 'p') AS revenue_pct
    FROM calc_CTE
    ORDER BY category_id;
    ```

    Output:

    | category_name | revenue    | revenue_pct |
    | ------------- | ---------- | ----------- |
    | Womens        | 505,711.57 | 44.63%      |
    | Mens          | 627,512.29 | 55.37%      |

    <br/>

9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions).

    - First, find the number of transaction for each product by aggregating using COUNT() function and group the result for each category.
    - Divide that value with the number of unique transaction Balanced Tree Clothing Co. ever had. This will be the value for each products penetration percentage.

    Query:

    ```sql
    WITH trx_CTE
    AS (
        SELECT p.product_id
            ,p.product_name
            ,CAST(COUNT(p.product_name) AS FLOAT) AS trx_cnt
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        GROUP BY p.product_id
            ,p.product_name
        )
    SELECT product_name
        ,FORMAT((
                trx_cnt / (
                    SELECT COUNT(DISTINCT txn_id)
                    FROM balanced_tree.sales
                    )
                ), 'p') AS penetration_pct
    FROM trx_CTE
    ORDER BY product_id;
    ```

    Output:

    | product_name                     | penetration_pct |
    | -------------------------------- | --------------- |
    | Blue Polo Shirt - Mens           | 50.72%          |
    | Pink Fluro Polkadot Socks - Mens | 50.32%          |
    | White Tee Shirt - Mens           | 50.72%          |
    | Indigo Rain Jacket - Womens      | 50.00%          |
    | Grey Fashion Jacket - Womens     | 51.00%          |
    | White Striped Socks - Mens       | 49.72%          |
    | Navy Oversized Jeans - Womens    | 50.96%          |
    | Teal Button Up Shirt - Mens      | 49.68%          |
    | Khaki Suit Jacket - Womens       | 49.88%          |
    | Cream Relaxed Jeans - Womens     | 49.72%          |
    | Black Straight Jeans - Womens    | 49.84%          |
    | Navy Solid Socks - Mens          | 51.24%          |

    <br/>

10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

    - First, generate a sub table that consist of only txn_id, product_id, and product_name.
    - Join this table twice with itself where each join would match the `txn_id`, *meaning each product has to be in a same transaction*, but the `product_id` for the first/left table must be smaller than the second/right. This will result in a combination of 3 products for each transactions. Aggregate to find the number of transaction for each combination using `COUNT()` function and group the result by the product combination.
    - Generate a numbered column that represent the number of transaction for each product combination from highest number of transation to the lowest, called `rn`.
    - Show the result where `rn` is equal to 1.

    Query:

    ```sql
    WITH product_CTE
    AS (
        SELECT s.txn_id
            ,p.product_id
            ,p.product_name
        FROM balanced_tree.sales AS s
        JOIN balanced_tree.product_details AS p
            ON s.prod_id = p.product_id
        )
        ,combination_CTE
    AS (
        SELECT p1.product_name AS product_name_1
            ,p2.product_name AS product_name_2
            ,p3.product_name AS product_name_3
            ,COUNT(*) AS cnt
        FROM product_CTE AS p1
        JOIN product_CTE AS p2
            ON p1.txn_id = p2.txn_id
                AND p1.product_id < p2.product_id
        JOIN product_CTE AS p3
            ON p2.txn_id = p3.txn_id
                AND p2.product_id < p3.product_id
        GROUP BY p1.product_name
            ,p2.product_name
            ,p3.product_name
        )
        ,row_CTE
    AS (
        SELECT ROW_NUMBER() OVER (
                ORDER BY cnt DESC
                ) AS rn
            ,*
        FROM combination_CTE
        )
    SELECT product_name_1
        ,product_name_2
        ,product_name_3
        ,cnt AS trx_cnt
    FROM row_CTE
    WHERE rn = 1;
    ```

    Output:

    | product_name_1         | product_name_2               | product_name_3              | trx_cnt |
    | ---------------------- | ---------------------------- | --------------------------- | ------- |
    | White Tee Shirt - Mens | Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens | 352     |
