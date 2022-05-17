# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution B. Transaction Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. How many unique transactions were there?

    - Count the distinct values of `txn_id` to find the number of unique transations.

    Code:

    ```sql
    SELECT COUNT(DISTINCT txn_id) AS unique_transaction_cnt
    FROM balanced_tree.sales;
    ```

    Output:

    | unique_transaction_cnt |
    | ---------------------- |
    | 2500                   |

    <br/>

2. What is the average unique products purchased in each transaction?

    - First, find the distinct product for each transactions ever happened using `COUNT(DISTINCT prod_id)` and group the result by the transaction id (`txn_id`).
    - Next, use `AVG()` function on the count result to get the average unique products in each transactions.

    Code:

    ```sql
    WITH products_CTE
    AS (
        SELECT txn_id
            ,COUNT(DISTINCT prod_id) AS unique_product_cnt
        FROM balanced_tree.sales
        GROUP BY txn_id
        )
    SELECT AVG(unique_product_cnt) AS unique_products_purchased_avg
    FROM products_CTE;
    ```

    Output:

    | unique_products_purchased_avg |
    | ----------------------------- |
    | 6                             |

    <br/>

3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

    - The revenue is calculated by finding the total revenue for each transactions.
    - Then, use `PERCENTILE_CONT()` function on the total revenue result for each percentile asked by the question to get the result.

    Code:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT txn_id
            ,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
        FROM balanced_tree.sales
        GROUP BY txn_id
        )
        ,percentile_CTE
    AS (
        SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN
        GROUP (
                ORDER BY revenue
                ) OVER () AS revenue_25_percentile
            ,PERCENTILE_CONT(0.5) WITHIN
        GROUP (
                ORDER BY revenue
                ) OVER () AS median
            ,PERCENTILE_CONT(0.75) WITHIN
        GROUP (
                ORDER BY revenue
                ) OVER () AS revenue_75_percentile
        FROM revenue_CTE
        )
    SELECT FORMAT(revenue_25_percentile, '##.##') AS revenue_25_percentile
        ,FORMAT(median, '##.##') AS revenue_median
        ,FORMAT(revenue_75_percentile, '##.##') AS revenue_75_percentile
    FROM percentile_CTE;
    ```

    Output:

    | revenue_25_percentile | revenue_median | revenue_75_percentile |
    | --------------------- | -------------- | --------------------- |
    | 326.41                | 441.23         | 572.76                |

    <br/>

4. What is the average discount value per transaction?

    - Find discount value for each transactions by aggregating `(qty * price * (CAST(discount AS FLOAT) / 100))` equation using `SUM()` function and group it by the transaction id (`txn_id`).
    - Use `AVG()` on the result to find the average discount value per transactions.

    Code:

    ```sql
    WITH discount_CTE
    AS (
        SELECT txn_id
            ,SUM((qty * price * (CAST(discount AS FLOAT) / 100))) AS discount
        FROM balanced_tree.sales
        GROUP BY txn_id
        )
    SELECT FORMAT(AVG(discount), '##.##') discount_avg
    FROM discount_CTE;
    ```

    Output:

    | discount_avg |
    | ------------ |
    | 62.49        |

    <br/>

5. What is the percentage split of all transactions for members vs non-members?

    - Because the `member` column are displaying 0 and 1 value for representing the member or non-member status, those value need to be converted first. Use `CASE WHEN` statements to do that.
    - Use `COUNT(*)` to find the number of transactions for each members vs non_members.
    - Use the number of transaction for each member / non-members and devide it with the total transactions Balanced Tree Clothing Co. ever had to get the percentage split for members vs non-members.

    Code:

    ```sql
    WITH trx_CTE
    AS (
        SELECT CASE
                WHEN member = 1
                    THEN 'Members'
                ELSE 'Non-Members'
                END AS members
            ,COUNT(*) AS trx_cnt
        FROM balanced_tree.sales
        GROUP BY CASE
                WHEN member = 1
                    THEN 'Members'
                ELSE 'Non-Members'
                END
        )
        ,calc_CTE
    AS (
        SELECT members
            ,trx_cnt
            ,(
                CAST(trx_cnt AS FLOAT) / (
                    SELECT SUM(trx_cnt)
                    FROM trx_CTE
                    )
                ) AS transaction_pct
        FROM trx_CTE
        )
    SELECT members
        ,trx_cnt
        ,FORMAT(transaction_pct, 'p') AS transaction_pct
    FROM calc_CTE;
    ```

    Output:

    | members     | trx_cnt | transaction_pct |
    | ----------- | ------- | --------------- |
    | Members     | 9061    | 60.03%          |
    | Non-Members | 6034    | 39.97%          |

    <br/>

6. What is the average revenue for member transactions and non-member transactions?

    - use the `(qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))` equation to get the revenue for transactions.
    - Aggregate the result from the equation using AVG() function and group the result by members / non-members to get the avereage revenue.

    Code:

    ```sql
    WITH revenue_CTE
    AS (
        SELECT CASE
                WHEN member = 1
                    THEN 'Members'
                ELSE 'Non-Members'
                END AS members
            ,(qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100)) AS revenue
        FROM balanced_tree.sales
        )
    SELECT members
        ,FORMAT(AVG(revenue), '#.##') AS revenue_avg
    FROM revenue_CTE
    GROUP BY members;

    ```

    Output:

    | members     | revenue_avg |
    | ----------- | ----------- |
    | Members     | 75.43       |
    | Non-Members | 74.54       |
