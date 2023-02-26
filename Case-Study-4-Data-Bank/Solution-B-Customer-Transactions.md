# :classical_building: Case Study 4 - Data Bank: Solution B. Customer Transactions

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. What is the unique count and total amount for each transaction type?

    Query:

    ```sql
    SELECT
        INITCAP(txn_type) AS transaction_type,
        COUNT(*) AS transaction_total,
        SUM(txn_amount) AS amount_total
    FROM
        data_bank.customer_transactions
    GROUP BY
        1;
    ```

    Output:

    | "transaction_type" | "transaction_total" | "amount_total" |
    |--------------------|---------------------|----------------|
    | Purchase           | 1617                | 806537         |
    | Withdrawal         | 1580                | 793003         |
    | Deposit            | 2671                | 1359168        |

    <br>

2. What is the average total historical deposit counts and amounts for all customers?

    Query:

    ```sql
    SELECT
        ROUND(AVG(txn_amount), 2) AS deposit_average,
        SUM(txn_amount) AS deposit_total
    FROM
        data_bank.customer_transactions
    WHERE
        txn_type = 'deposit';
    ```

    Output:

    | "deposit_average" | "deposit_total" |
    |-------------------|-----------------|
    | 508.86            | 1359168         |

    <br>

3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

    Query:

    ```sql
    WITH transactions_per_type AS (
        SELECT
            customer_id,
            EXTRACT('MONTH' FROM txn_date) AS month_num,
            TO_CHAR(txn_date, 'Month') AS month_name,
            SUM(
                CASE WHEN txn_type = 'deposit' THEN
                    1
                ELSE
                    0
                END) AS deposit_num,
            SUM(
                CASE WHEN txn_type = 'purchase' THEN
                    1
                ELSE
                    0
                END) AS purchase_num,
            SUM(
                CASE WHEN txn_type = 'withdrawal' THEN
                    1
                ELSE
                    0
                END) AS withdrawal_num
        FROM
            data_bank.customer_transactions
        GROUP BY
            1,
            2,
            3
    )
    SELECT
        month_name,
        COUNT(*) AS customer_total
    FROM
        transactions_per_type
    WHERE
        deposit_num > 1
        AND (purchase_num = 1
            OR withdrawal_num = 1)
    GROUP BY
        month_num,
        month_name
    ORDER BY
        month_num;
    ```

    Output:

    | "month_name" | "customer_total" |
    |--------------|------------------|
    | January      | 115              |
    | February     | 108              |
    | March        | 113              |
    | April        | 50               |

    <br>

4. What is the closing balance for each customer at the end of the month?

    Query:

    ```sql
    WITH transaction_amount_sign AS (
        SELECT
            customer_id,
            txn_date,
            CASE WHEN txn_type = 'deposit' THEN
                txn_amount
            ELSE
                (- txn_amount)
            END AS txn_amount_sign
        FROM
            data_bank.customer_transactions
    )
    SELECT
        customer_id,
        SUM(txn_amount_sign) AS closing_balance
    FROM
        transaction_amount_sign
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    Showing the closing balance from customers with `customer_id` from 1-10.

    | "customer_id" | "closing_balance" |
    |---------------|-------------------|
    | 1             | -640              |
    | 2             | 610               |
    | 3             | -729              |
    | 4             | 655               |
    | 5             | -2413             |
    | 6             | 340               |
    | 7             | 2623              |
    | 8             | -1029             |
    | 9             | 862               |
    | 10            | -5090             |

    <br>

5. What is the percentage of customers who increase their closing balance by more than 5%?

    Query:

    ```sql
    WITH transaction_amount_sign AS (
        SELECT
            customer_id,
            txn_date,
            CASE WHEN txn_type = 'deposit' THEN
                txn_amount
            ELSE
                (- txn_amount)
            END AS txn_amount_sign,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY txn_date) AS txn_id
        FROM
            data_bank.customer_transactions
    ),
    initial_balance AS (
        SELECT
            customer_id,
            txn_amount_sign AS balance
        FROM
            transaction_amount_sign
        WHERE
            txn_id = 1
    ),
    closing_balance AS (
        SELECT
            customer_id,
            SUM(txn_amount_sign) AS balance
    FROM
        transaction_amount_sign
    GROUP BY
        1
    ),
    balance_percentage_change AS (
        SELECT
            i.customer_id,
            100 * (c.balance - i.balance) / ABS(i.balance)::NUMERIC AS change_percentage
        FROM
            initial_balance AS i
            JOIN closing_balance AS c ON i.customer_id = c.customer_id
    )
    SELECT
        ROUND(100 * COUNT(*)::NUMERIC / (
            SELECT
                COUNT(DISTINCT customer_id)
            FROM data_bank.customer_transactions), 1) AS customer_percentage
    FROM
        balance_percentage_change
    WHERE
        change_percentage > 5;
    ```

    Output:

    | "customer_percentage" |
    |-----------------------|
    | 33.6                  |

---
