# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution B. Transaction Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. How many unique transactions were there?

    Query:

    ```sql
    SELECT
        COUNT(DISTINCT txn_id) AS transactions_num
    FROM
        balanced_tree.sales;
    ```

    Output:

    | "transactions_num" |
    |--------------------|
    | 2500               |

    <br>

2. What is the average unique products purchased in each transaction?

    Query:

    ```sql
    WITH products_per_transactions AS (
        SELECT
            txn_id,
            COUNT(DISTINCT prod_id) AS products_num
        FROM
            balanced_tree.sales
        GROUP BY
            1
    )
    SELECT
        ROUND(AVG(products_num)) AS product_purchased_average
    FROM
        products_per_transactions;
    ```

    Output:

    | "product_purchased_average" |
    |-----------------------------|
    | 6                           |

    <br>

3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

    Query:

    ```sql
    WITH transaction_revenue AS (
        SELECT
            ROUND(((qty * price) - ((qty * price * discount)::NUMERIC / 100)), 1) AS revenue
        FROM
            balanced_tree.sales
    )
    SELECT
        PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY revenue) AS revenue_percentile_25,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_median,
        PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY revenue) AS revenue_percentile_75
    FROM
        transaction_revenue;
    ```

    Output:

    | "revenue_percentile_25" | "revenue_median" | "revenue_percentile_75" |
    |-------------------------|------------------|-------------------------|
    | 31.5                    | 55.8             | 103.7                   |

    <br>

4. What is the average discount value per transaction?

    Query:

    ```sql
    WITH discount_per_transaction AS (
        SELECT
            txn_id,
            SUM(((qty * price * discount)::NUMERIC / 100)) AS discount
        FROM
            balanced_tree.sales
        GROUP BY
            1
    )
    SELECT
        ROUND(AVG(discount), 1) AS discount_average
    FROM
        discount_per_transaction;
    ```

    Output:

    | "discount_average" |
    |--------------------|
    | 62.5               |

    <br>

5. What is the percentage split of all transactions for members vs non-members?

    Query:

    ```sql
    WITH member_txn_id AS (
        SELECT DISTINCT
            txn_id,
            CASE member
            WHEN TRUE THEN
                'Member'
            ELSE
                'Non-member'
            END AS member_status
        FROM
            balanced_tree.sales
    ),
    member_txn_num AS (
        SELECT
            member_status,
            COUNT(*) AS transaction_num
    FROM
        member_txn_id
    GROUP BY
        1
    )
    SELECT
        member_status,
        transaction_num,
        ROUND((100 * transaction_num::NUMERIC / SUM(transaction_num) OVER ()), 1) AS transaction_percentage
    FROM
        member_txn_num
    ORDER BY
        2 DESC;
    ```

    Output:

    | "member_status" | "transaction_num" | "transaction_percentage" |
    |-----------------|-------------------|--------------------------|
    | Member          | 1505              | 60.2                     |
    | Non-member      | 995               | 39.8                     |

    <br>

6. What is the average revenue for member transactions and non-member transactions?

    Query:

    ```sql
    WITH transaction_revenue AS (
        SELECT
            CASE member
            WHEN TRUE THEN
                'Member'
            ELSE
                'Non-member'
            END AS member_status,
            (qty * price) AS gross_revenue,
            (qty * price) * (discount::NUMERIC / 100) AS discount
        FROM
            balanced_tree.sales
    )
    SELECT
        member_status,
        ROUND(AVG(gross_revenue - discount), 1) AS net_revenue_average
    FROM
        transaction_revenue
    GROUP BY
        1
    ORDER BY
        2 DESC;
    ```

    Output:

    | "member_status" | "net_revenue_average" |
    |-----------------|-----------------------|
    | Member          | 75.4                  |
    | Non-member      | 74.5                  |

---
