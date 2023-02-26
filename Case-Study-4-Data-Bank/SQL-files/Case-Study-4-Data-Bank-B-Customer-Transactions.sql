--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 4 - Data Mart
-- Part B - Customer Transactions
--
-- 1. What is the unique count and total amount for each transaction type?
SELECT
    INITCAP(txn_type) AS transaction_type,
    COUNT(*) AS transaction_total,
    SUM(txn_amount) AS amount_total
FROM
    data_bank.customer_transactions
GROUP BY
    1;

--
-- 2. What is the average total historical deposit counts and amounts for all customers?
SELECT
    ROUND(AVG(txn_amount), 2) AS deposit_average,
    SUM(txn_amount) AS deposit_total
FROM
    data_bank.customer_transactions
WHERE
    txn_type = 'deposit';

--
-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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

--
-- 4. What is the closing balance for each customer at the end of the month?
--  Closing balance per customer for each month
WITH transaction_amount_sign AS (
    SELECT
        customer_id,
        txn_date,
        EXTRACT('MONTH' FROM txn_date) AS month_num,
        CASE WHEN txn_type = 'deposit' THEN
            txn_amount
        ELSE
            (- txn_amount)
        END AS txn_amount_sign,
        ROW_NUMBER() OVER (PARTITION BY customer_id,
            EXTRACT('MONTH' FROM txn_date) ORDER BY txn_date DESC) AS transaction_id
    FROM
        data_bank.customer_transactions
),
balance_calculation AS (
    SELECT
        customer_id,
        txn_date,
        transaction_id,
        SUM(txn_amount_sign) OVER (PARTITION BY customer_id,
            month_num ORDER BY txn_date) AS balance
    FROM
        transaction_amount_sign
)
SELECT
    customer_id,
    txn_date,
    balance
FROM
    balance_calculation
WHERE
    transaction_id = 1
ORDER BY
    1,
    2;

--  Closing balance per customer
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

--
-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
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
