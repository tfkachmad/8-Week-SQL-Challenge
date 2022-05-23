# :shopping_cart: Case Study 5 - Data Mart: Solution B. Data Exploration

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. What day of the week is used for each `week_date` value?

    - Use `DATENAME()` function to find the day used for the `week_date` value.Then, find the distinct value from the result.

    Query:

    ```sql
    SELECT DISTINCT DATENAME(WEEKDAY, week_date) AS [day]
    FROM data_mart.clean_weekly_sales
    ```

    Output:

    | day    |
    |--------|
    | Monday |

    <br/>

2. What range of week numbers are missing from the dataset?

    - Find the smallest `week_number` value using `MIN()` function and the largest value with `MAX()`.
    - The range of week number that are missing are that outside these range, or **below 13 (1-12)** and above **36 (37-52)**.

    Query:

    ```sql
    SELECT MIN(week_number) AS earliest_week_number
        ,MAX(week_number) AS latest_week_number
    FROM data_mart.clean_weekly_sales
    ```

    Output:

    | earliest_week_number | latest_week_number |
    |----------------------|--------------------|
    | 13                   | 36                 |

    <br/>

3. How many total transactions were there for each year in the dataset?

    - Aggregate the `transactions` column with `SUM()` function to find the total transactions.
    - Group the result by the `calendar_year` or the year.

    Query:

    ```sql
    SELECT calendar_year AS [year]
        ,FORMAT(SUM(transactions), '#,#') AS total_transactions
    FROM data_mart.clean_weekly_sales
    GROUP BY calendar_year;
    ```

    Output:

    | year | total_transactions |
    |------|--------------------|
    | 2019 | 365,639,285        |
    | 2020 | 375,813,651        |
    | 2018 | 346,406,460        |

    <br/>

4. What is the total sales for each region for each month?

    - Aggregate the `sales` column using `SUM()` to find the total sales. Group the result by regions name and the month name that acquired using `DATENAME()` function on `week_date` column.

    Query:

    ```sql
    WITH cte
    AS (
        SELECT region
            ,month_number
            ,DATENAME(MONTH, week_date) AS [month]
            ,SUM(CAST(sales AS BIGINT)) AS total_sales
        FROM data_mart.clean_weekly_sales
        GROUP BY region
            ,month_number
            ,DATENAME(MONTH, week_date)
        )
    SELECT region
        ,[month]
        ,FORMAT(total_sales, '##,##') AS total_sales
    FROM cte
    ORDER BY region
        ,month_number;
    ```

    Output:

    | region        | month     | total_sales   |
    |---------------|-----------|---------------|
    | AFRICA        | March     | 567,767,480   |
    | AFRICA        | April     | 1,911,783,504 |
    | AFRICA        | May       | 1,647,244,738 |
    | AFRICA        | June      | 1,767,559,760 |
    | AFRICA        | July      | 1,960,219,710 |
    | AFRICA        | August    | 1,809,596,890 |
    | AFRICA        | September | 276,320,987   |
    | ASIA          | March     | 529,770,793   |
    | ASIA          | April     | 1,804,628,707 |
    | ASIA          | May       | 1,526,285,399 |
    | ASIA          | June      | 1,619,482,889 |
    | ASIA          | July      | 1,768,844,756 |
    | ASIA          | August    | 1,663,320,609 |
    | ASIA          | September | 252,836,807   |
    | CANADA        | March     | 144,634,329   |
    | CANADA        | April     | 484,552,594   |
    | CANADA        | May       | 412,378,365   |
    | CANADA        | June      | 443,846,698   |
    | CANADA        | July      | 477,134,947   |
    | CANADA        | August    | 447,073,019   |
    | CANADA        | September | 69,067,959    |
    | EUROPE        | March     | 35,337,093    |
    | EUROPE        | April     | 127,334,255   |
    | EUROPE        | May       | 109,338,389   |
    | EUROPE        | June      | 122,813,826   |
    | EUROPE        | July      | 136,757,466   |
    | EUROPE        | August    | 122,102,995   |
    | EUROPE        | September | 18,877,433    |
    | OCEANIA       | March     | 783,282,888   |
    | OCEANIA       | April     | 2,599,767,620 |
    | OCEANIA       | May       | 2,215,657,304 |
    | OCEANIA       | June      | 2,371,884,744 |
    | OCEANIA       | July      | 2,563,459,400 |
    | OCEANIA       | August    | 2,432,313,652 |
    | OCEANIA       | September | 372,465,518   |
    | SOUTH AMERICA | March     | 71,023,109    |
    | SOUTH AMERICA | April     | 238,451,531   |
    | SOUTH AMERICA | May       | 201,391,809   |
    | SOUTH AMERICA | June      | 218,247,455   |
    | SOUTH AMERICA | July      | 235,582,776   |
    | SOUTH AMERICA | August    | 221,166,052   |
    | SOUTH AMERICA | September | 34,175,583    |
    | USA           | March     | 225,353,043   |
    | USA           | April     | 759,786,323   |
    | USA           | May       | 655,967,121   |
    | USA           | June      | 703,878,990   |
    | USA           | July      | 760,331,754   |
    | USA           | August    | 712,002,790   |
    | USA           | September | 110,532,368   |

    <br/>

5. What is the total count of transactions for each platform

    - `COUNT(*)` every rows in the table to find the number of transactions and group the result by each `platform` Data Mart use.

    Query:

    ```sql
    SELECT [platform]
        ,COUNT(*) AS transactions_count
    FROM data_mart.clean_weekly_sales
    GROUP BY [platform];
    ```

    Output:

    | platform | transactions_count |
    |----------|--------------------|
    | Retail   | 8568               |
    | Shopify  | 8549               |

    <br/>

6. What is the percentage of sales for Retail vs Shopify for each month?

    - There are couple CTEs that used to solve this question. First, is to subset the data to only show the `platform`, month_number, month_name using `DATENAME()`, and cast the sales column as `BIGINT`, because the aggregate would result big number.

        ```sql
        WITH sub_cte
        AS (
            SELECT [platform]
                ,month_number
                ,DATENAME(MONTH, week_date) AS [month]
                ,CAST(sales AS BIGINT) AS sales
            FROM data_mart.clean_weekly_sales
        )
        ```

    - The second CTE will be used to find the total sales each month Data Mart made. This is done by aggregate hte sales column using SUM() function and group the result by the month.

        ```sql
        total_cte
        AS (
            SELECT month_number
                ,[month]
                ,SUM(sales) AS total_sales
            FROM sub_cte
            GROUP BY month_number
                ,[month]
            )
        ```

    - The third CTE used to find the sales on the retail platform. This is done the same way as the previous CTE, but this time filter the `plaform` by only the `retail`.

        ```sql
        retail_cte
        AS (
            SELECT month_number
                ,[month]
                ,CAST(SUM(sales) AS FLOAT) AS retail_sales
            FROM sub_cte
            WHERE [platform] LIKE 'retail'
            GROUP BY month_number
                ,[month]
            )
        ```

    - The fourth CTE is same as the previous one. But, this one filter the `platform` by only the `Shopify`.

        ```sql
        ,shopify_cte
        AS (
            SELECT month_number
                ,[month]
                ,CAST(SUM(sales) AS FLOAT) AS shopify_sales
            FROM sub_cte
            WHERE [platform] LIKE 'shopify'
            GROUP BY month_number
                ,[month]
            )
        ```

    - The fifth one, is to calculate the result from previous CTEs.

        ```sql
        calculation_cte
        AS (
            SELECT r.month_number
                ,r.[month]
                ,ROUND(((retail_sales / total_sales) * 100), 2) AS retail_percentage
                ,ROUND(((shopify_sales / total_sales) * 100), 2) AS shopify_percentage
            FROM retail_cte AS r
            JOIN shopify_cte AS s
                ON r.month_number = s.month_number
            JOIN total_cte AS t
                ON r.month_number = t.month_number
            )
        ```

    - The result from the final CTE is displayed to get the result to answer the question.

    Query:

    ```sql
    WITH sub_cte
    AS (
        SELECT [platform]
            ,month_number
            ,DATENAME(MONTH, week_date) AS [month]
            ,CAST(sales AS BIGINT) AS sales
        FROM data_mart.clean_weekly_sales
        )
        ,total_cte
    AS (
        SELECT month_number
            ,[month]
            ,SUM(sales) AS total_sales
        FROM sub_cte
        GROUP BY month_number
            ,[month]
        )
        ,retail_cte
    AS (
        SELECT month_number
            ,[month]
            ,CAST(SUM(sales) AS FLOAT) AS retail_sales
        FROM sub_cte
        WHERE [platform] LIKE 'retail'
        GROUP BY month_number
            ,[month]
        )
        ,shopify_cte
    AS (
        SELECT month_number
            ,[month]
            ,CAST(SUM(sales) AS FLOAT) AS shopify_sales
        FROM sub_cte
        WHERE [platform] LIKE 'shopify'
        GROUP BY month_number
            ,[month]
        )
        ,calculation_cte
    AS (
        SELECT r.month_number
            ,r.[month]
            ,ROUND(((retail_sales / total_sales) * 100), 2) AS retail_percentage
            ,ROUND(((shopify_sales / total_sales) * 100), 2) AS shopify_percentage
        FROM retail_cte AS r
        JOIN shopify_cte AS s
            ON r.month_number = s.month_number
        JOIN total_cte AS t
            ON r.month_number = t.month_number
        )
    SELECT [month]
        ,CONCAT (
            retail_percentage
            ,'%'
            ) AS retail_sales_percentage
        ,CONCAT (
            shopify_percentage
            ,'%'
            ) AS shopify_sales_percentage
    FROM calculation_cte
    ORDER BY month_number;
    ```

    Output:

    | month     | retail_sales_percentage | shopify_sales_percentage |
    |-----------|-------------------------|--------------------------|
    | March     | 97.54%                  | 2.46%                    |
    | April     | 97.59%                  | 2.41%                    |
    | May       | 97.3%                   | 2.7%                     |
    | June      | 97.27%                  | 2.73%                    |
    | July      | 97.29%                  | 2.71%                    |
    | August    | 97.08%                  | 2.92%                    |
    | September | 97.38%                  | 2.62%                    |

    <br/>

7. What is the percentage of sales by demographic for each year in the dataset?

    - This question can be answered using Query from the previous question with some change. First, rather than grouping by the `platform` this time group each results by the `demographic`. Also, change the month that used to produce each CTEs result by the `calendar_year`.

    Query:

    ```sql
    WITH sub_cte
    AS (
        SELECT demographic
            ,calendar_year
            ,CAST(sales AS BIGINT) AS sales
        FROM data_mart.clean_weekly_sales
        )
        ,total_cte
    AS (
        SELECT calendar_year
            ,SUM(sales) AS total_sales
        FROM sub_cte
        GROUP BY calendar_year
        )
        ,couples_cte
    AS (
        SELECT calendar_year
            ,CAST(SUM(sales) AS FLOAT) AS couples_sales
        FROM sub_cte
        WHERE demographic LIKE 'couples'
        GROUP BY calendar_year
        )
        ,families_cte
    AS (
        SELECT calendar_year
            ,CAST(SUM(sales) AS FLOAT) AS families_sales
        FROM sub_cte
        WHERE demographic LIKE 'families'
        GROUP BY calendar_year
        )
        ,unknown_cte
    AS (
        SELECT calendar_year
            ,CAST(SUM(sales) AS FLOAT) AS unknown_sales
        FROM sub_cte
        WHERE demographic LIKE 'unknown'
        GROUP BY calendar_year
        )
        ,calculation_cte
    AS (
        SELECT c.calendar_year
            ,couples_sales
            ,families_sales
            ,unknown_sales
            ,ROUND(((couples_sales / total_sales) * 100), 2) AS couples_percentage
            ,ROUND(((families_sales / total_sales) * 100), 2) AS families_percentage
            ,ROUND(((unknown_sales / total_sales) * 100), 2) AS unknown_percentage
        FROM couples_cte AS c
        JOIN families_cte AS f
            ON c.calendar_year = f.calendar_year
        JOIN unknown_cte AS u
            ON c.calendar_year = u.calendar_year
        JOIN total_cte AS t
            ON c.calendar_year = t.calendar_year
        )
    SELECT calendar_year
        ,CONCAT (
            couples_percentage
            ,'%'
            ) AS couples_sales_percentage
        ,CONCAT (
            families_percentage
            ,'%'
            ) AS families_sales_percentage
        ,CONCAT (
            unknown_percentage
            ,'%'
            ) AS unknown_sales_percentage
    FROM calculation_cte
    ORDER BY calendar_year;
    ```

    Output:

    | calendar_year | couples_sales_percentage | families_sales_percentage | unknown_sales_percentage |
    |---------------|--------------------------|---------------------------|--------------------------|
    | 2018          | 26.38%                   | 31.99%                    | 41.63%                   |
    | 2019          | 27.28%                   | 32.47%                    | 40.25%                   |
    | 2020          | 28.72%                   | 32.73%                    | 38.55%                   |

    <br/>

8. Which age_band and demographic values contribute the most to Retail sales?

    - Create `sub_cte` CTE to find the sales for each `age_band` and `demographic` combination. Aggregate the `sales` column using `SUM()` function and group by the `age_band` and `demographic`. The result from this CTE is going to used to find the highest total sales based on the `age_band` and `demographic` combination later.
    - List the `age_band`, `demographic`, and the `total_sales` from the CTE, but filter the result also based on the the CTE, where only the `total_sales` that is equal to the highest `total_sales` from that CTE using `MAX()`.

    Query:

    ```sql
    WITH sub_cte
    AS (
        SELECT age_band
            ,demographic
            ,SUM(CAST(sales AS BIGINT)) AS total_sales
        FROM data_mart.clean_weekly_sales
        WHERE [platform] LIKE 'retail'
        GROUP BY age_band
            ,demographic
        )
    SELECT age_band
        ,demographic
        ,FORMAT(total_sales, '##,##') AS total_sales
    FROM sub_cte
    WHERE total_sales = (
            SELECT MAX(total_sales)
            FROM sub_cte
            );
    ```

    Output:

    | age_band | demographic | total_sales    |
    |----------|-------------|----------------|
    | unknown  | unknown     | 16,067,285,533 |

    <br/>

9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

    - Because the `avg_transaction` is a calculated column based on other column on the table, it can't be used to find the average transaction size for each year for Retail vs Shopify.
    - To answer this question, first the amount of transaction from both platform are needed. Also, the amount of sales from both plaform also neede. To do that, two temp table would be needed to store transaction data and sales data from the platforms.
    - The first temp table, `#retail_shopify_txn`, is going to store the transaction data from the platforms. This is done by using several CTEs.
        - First CTE is going to be the subset data that contains the `platform` name, `calendar_year`, `month_name`, and the `transaction` columns.
        - The second one is to find the aggregate of `transaction` using SUM() function for `retail` platform each year.
        - The third one is to find the aggregate of `transaction` using SUM() function for `shopify` platform each year.
        - The result from each CTE then inserted into the `#retail_shopify_txn` table.

        ```sql
        DROP TABLE
            IF EXISTS #retail_shopify_txn;
                WITH sub_txn_cte
                AS (
                    SELECT [platform]
                        ,calendar_year
                        ,DATENAME(MONTH, week_date) AS [month]
                        ,CAST(transactions AS BIGINT) AS txn
                    FROM data_mart.clean_weekly_sales
                    )
                    ,retail_txn_cte
                AS (
                    SELECT calendar_year
                        ,CAST(SUM(txn) AS FLOAT) AS retail_txn
                    FROM sub_txn_cte
                    WHERE [platform] LIKE 'retail'
                    GROUP BY calendar_year
                    )
                    ,shopify_txn_cte
                AS (
                    SELECT calendar_year
                        ,CAST(SUM(txn) AS FLOAT) AS shopify_txn
                    FROM sub_txn_cte
                    WHERE [platform] LIKE 'shopify'
                    GROUP BY calendar_year
                    )
                SELECT r.calendar_year
                    ,retail_txn
                    ,shopify_txn
                INTO #retail_shopify_txn
                FROM retail_txn_cte AS r
                JOIN shopify_txn_cte AS s
                    ON r.calendar_year = s.calendar_year
                ORDER BY calendar_year;
        ```

    - The second temp table, `#retail_shopify_sales` is going to store the sales data from the platforms. This is done by using CTEs like the previous temp table. But this time, change the filter the platform for the `shopify`.

        ```sql
        DROP TABLE
            IF EXISTS #retail_shopify_sales;
                WITH sub_sales_cte
                AS (
                    SELECT [platform]
                        ,calendar_year
                        ,DATENAME(MONTH, week_date) AS [month]
                        ,CAST(sales AS BIGINT) AS sales
                    FROM data_mart.clean_weekly_sales
                    )
                    ,retail_sales_cte
                AS (
                    SELECT calendar_year
                        ,CAST(SUM(sales) AS FLOAT) AS retail_sales
                    FROM sub_sales_cte
                    WHERE [platform] LIKE 'retail'
                    GROUP BY calendar_year
                    )
                    ,shopify_sales_cte
                AS (
                    SELECT calendar_year
                        ,CAST(SUM(sales) AS FLOAT) AS shopify_sales
                    FROM sub_sales_cte
                    WHERE [platform] LIKE 'shopify'
                    GROUP BY calendar_year
                    )
                SELECT r.calendar_year
                    ,retail_sales
                    ,shopify_sales
                INTO #retail_shopify_sales
                FROM retail_sales_cte AS r
                JOIN shopify_sales_cte AS s
                    ON r.calendar_year = s.calendar_year
                ORDER BY calendar_year;
        ```

    - Do the calculation based on the temp table to find the average transaction size for each year for Retail vs Shopify.

    Query:

    ```sql
    DROP TABLE
    IF EXISTS #retail_shopify_txn;
        WITH sub_txn_cte
        AS (
            SELECT [platform]
                ,calendar_year
                ,DATENAME(MONTH, week_date) AS [month]
                ,CAST(transactions AS BIGINT) AS txn
            FROM data_mart.clean_weekly_sales
            )
            ,retail_txn_cte
        AS (
            SELECT calendar_year
                ,CAST(SUM(txn) AS FLOAT) AS retail_txn
            FROM sub_txn_cte
            WHERE [platform] LIKE 'retail'
            GROUP BY calendar_year
            )
            ,shopify_txn_cte
        AS (
            SELECT calendar_year
                ,CAST(SUM(txn) AS FLOAT) AS shopify_txn
            FROM sub_txn_cte
            WHERE [platform] LIKE 'shopify'
            GROUP BY calendar_year
            )
        SELECT r.calendar_year
            ,retail_txn
            ,shopify_txn
        INTO #retail_shopify_txn
        FROM retail_txn_cte AS r
        JOIN shopify_txn_cte AS s
            ON r.calendar_year = s.calendar_year
        ORDER BY calendar_year;
    --
    -- CTEs to find the sales for Retail vs Shopify
    DROP TABLE
    IF EXISTS #retail_shopify_sales;
        WITH sub_sales_cte
        AS (
            SELECT [platform]
                ,calendar_year
                ,DATENAME(MONTH, week_date) AS [month]
                ,CAST(sales AS BIGINT) AS sales
            FROM data_mart.clean_weekly_sales
            )
            ,retail_sales_cte
        AS (
            SELECT calendar_year
                ,CAST(SUM(sales) AS FLOAT) AS retail_sales
            FROM sub_sales_cte
            WHERE [platform] LIKE 'retail'
            GROUP BY calendar_year
            )
            ,shopify_sales_cte
        AS (
            SELECT calendar_year
                ,CAST(SUM(sales) AS FLOAT) AS shopify_sales
            FROM sub_sales_cte
            WHERE [platform] LIKE 'shopify'
            GROUP BY calendar_year
            )
        SELECT r.calendar_year
            ,retail_sales
            ,shopify_sales
        INTO #retail_shopify_sales
        FROM retail_sales_cte AS r
        JOIN shopify_sales_cte AS s
            ON r.calendar_year = s.calendar_year
        ORDER BY calendar_year;
    --
    -- Find the result
    SELECT s.calendar_year
        ,ROUND((retail_sales / retail_txn), 2) AS retail_avg_transaction
        ,ROUND((shopify_sales / shopify_txn), 2) AS shopify_avg_transaction
    FROM #retail_shopify_sales AS s
    JOIN #retail_shopify_txn AS t
        ON s.calendar_year = t.calendar_year
    ORDER BY s.calendar_year;
    ```

    Output:

    | calendar_year | retail_avg_transaction | shopify_avg_transaction |
    |---------------|------------------------|-------------------------|
    | 2018          | 36.56                  | 192.48                  |
    | 2019          | 36.83                  | 183.36                  |
    | 2020          | 36.56                  | 179.03                  |
