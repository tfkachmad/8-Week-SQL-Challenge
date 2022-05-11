# :shopping_cart: Case Study 5 - Data Mart: Solution C. Before and After Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

    Code:

    ```sql
    DROP TABLE
    IF EXISTS #before_after_4_weeks;
        WITH before_4_weeks_cte
        AS (
            SELECT DISTINCT week_date
                ,DATEADD(WEEK, - 4, week_date) AS before_4_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date = '2020-06-15'
            )
            ,after_4_weeks_cte
        AS (
            SELECT DISTINCT week_date
                ,DATEADD(WEEK, 4, week_date) AS after_4_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date = '2020-06-15'
            )
            ,total_sales
        AS (
            SELECT SUM(CAST(sales AS BIGINT)) AS total_sales_4_week
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN (
                            SELECT before_4_weeks
                            FROM before_4_weeks_cte
                            )
                    AND (
                            SELECT after_4_weeks
                            FROM after_4_weeks_cte
                            )
            )
            ,before_4_weeks_sales
        AS (
            SELECT SUM(CAST(sales AS FLOAT)) AS total_sales_before_4_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN (
                            SELECT before_4_weeks
                            FROM before_4_weeks_cte
                            )
                    AND '2020-06-15'
            )
            ,after_4_weeks_sales
        AS (
            SELECT SUM(CAST(sales AS FLOAT)) AS total_sales_after_4_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN '2020-06-15'
                    AND (
                            SELECT after_4_weeks
                            FROM after_4_weeks_cte
                            )
            )
        SELECT (
                SELECT total_sales_4_week
                FROM total_sales
                ) AS total_sales
            ,(
                SELECT total_sales_before_4_weeks
                FROM before_4_weeks_sales
                ) AS total_sales_4_weeks_before_2020_06_15
            ,(
                SELECT total_sales_after_4_weeks
                FROM after_4_weeks_sales
                ) AS total_sales_4_weeks_after_2020_06_15
            ,(
                SELECT total_sales_after_4_weeks
                FROM after_4_weeks_sales
                ) - (
                SELECT total_sales_before_4_weeks
                FROM before_4_weeks_sales
                ) AS change_rate
            ,(
                (
                    SELECT total_sales_after_4_weeks
                    FROM after_4_weeks_sales
                    ) - (
                    SELECT total_sales_before_4_weeks
                    FROM before_4_weeks_sales
                    )
                ) / (
                SELECT total_sales_4_week
                FROM total_sales
                ) * 100 AS percent_change_rate
        INTO #before_after_4_weeks;
    --
    -- Find the result for the 4 weeks before and after 2020-06-15
    SELECT FORMAT(total_sales_4_weeks_before_2020_06_15, '##,##') AS total_sales_4_weeks_before_2020_06_15
        ,FORMAT(total_sales_4_weeks_after_2020_06_15, '##,##') AS total_sales_4_weeks_after_2020_06_15
        ,FORMAT(change_rate, '##,##') AS sales_change_rate
        ,CONCAT (
            ROUND(percent_change_rate, 2)
            ,'%'
            ) AS percent_change_rate
    FROM #before_after_4_weeks;
    ```

    Output:

    | total_sales_4_weeks_before_2020_06_15 | total_sales_4_weeks_after_2020_06_15 | sales_change_rate | percent_change_rate |
    |---------------------------------------|--------------------------------------|-------------------|---------------------|
    | 2,915,903,705                         | 2,904,930,571                        | -10,973,134       | -0.21%              |

    <br/>

2. What about the entire 12 weeks before and after?

    Code:

    ```sql
    DROP TABLE
    IF EXISTS #before_after_12_weeks;
        WITH before_12_weeks_cte
        AS (
            SELECT DISTINCT week_date
                ,DATEADD(WEEK, - 12, week_date) AS before_12_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date = '2020-06-15'
            )
            ,after_12_weeks_cte
        AS (
            SELECT DISTINCT week_date
                ,DATEADD(WEEK, 12, week_date) AS after_12_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date = '2020-06-15'
            )
            ,total_sales
        AS (
            SELECT SUM(CAST(sales AS BIGINT)) AS total_sales_12_week
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN (
                            SELECT before_12_weeks
                            FROM before_12_weeks_cte
                            )
                    AND (
                            SELECT after_12_weeks
                            FROM after_12_weeks_cte
                            )
            )
            ,before_12_weeks_sales
        AS (
            SELECT SUM(CAST(sales AS FLOAT)) AS total_sales_before_12_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN (
                            SELECT before_12_weeks
                            FROM before_12_weeks_cte
                            )
                    AND '2020-06-15'
            )
            ,after_12_weeks_sales
        AS (
            SELECT SUM(CAST(sales AS FLOAT)) AS total_sales_after_12_weeks
            FROM data_mart.clean_weekly_sales
            WHERE week_date BETWEEN '2020-06-15'
                    AND (
                            SELECT after_12_weeks
                            FROM after_12_weeks_cte
                            )
            )
        SELECT (
                SELECT total_sales_12_week
                FROM total_sales
                ) AS total_sales
            ,(
                SELECT total_sales_before_12_weeks
                FROM before_12_weeks_sales
                ) AS total_sales_12_weeks_before_2020_06_15
            ,(
                SELECT total_sales_after_12_weeks
                FROM after_12_weeks_sales
                ) AS total_sales_12_weeks_after_2020_06_15
            ,(
                SELECT total_sales_after_12_weeks
                FROM after_12_weeks_sales
                ) - (
                SELECT total_sales_before_12_weeks
                FROM before_12_weeks_sales
                ) AS change_rate
            ,(
                (
                    SELECT total_sales_after_12_weeks
                    FROM after_12_weeks_sales
                    ) - (
                    SELECT total_sales_before_12_weeks
                    FROM before_12_weeks_sales
                    )
                ) / (
                SELECT total_sales_12_week
                FROM total_sales
                ) * 100 AS percent_change_rate
        INTO #before_after_12_weeks;
    --
    -- Find the result for the 12 weeks before and after 2020-06-15
    SELECT FORMAT(total_sales_12_weeks_before_2020_06_15, '##,##') AS total_sales_12_weeks_before_2020_06_15
        ,FORMAT(total_sales_12_weeks_after_2020_06_15, '##,##') AS total_sales_12_weeks_after_2020_06_15
        ,FORMAT(change_rate, '##,##') AS sales_change_rate
        ,CONCAT (
            ROUND(percent_change_rate, 2)
            ,'%'
            ) AS percent_change_rate
    FROM #before_after_12_weeks;
    ```

    Output:

    | total_sales_12_weeks_before_2020_06_15 | total_sales_12_weeks_after_2020_06_15 | sales_change_rate | percent_change_rate |
    |----------------------------------------|---------------------------------------|-------------------|---------------------|
    | 7,696,298,495                          | 6,973,947,753                         | -722,350,742      | -5.12%              |

    <br/>

3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

    Code:

    ```sql
    WITH sales_2018_cte
    AS (
        SELECT FORMAT(SUM(CAST(sales AS BIGINT)), '##,##') AS total_sales_2018
        FROM data_mart.clean_weekly_sales
        WHERE calendar_year = '2018'
        )
        ,sales_2019_cte
    AS (
        SELECT FORMAT(SUM(CAST(sales AS BIGINT)), '##,##') AS total_sales_2019
        FROM data_mart.clean_weekly_sales
        WHERE calendar_year = '2019'
        )
    SELECT (
            SELECT FORMAT(total_sales, '##,##')
            FROM #before_after_4_weeks
            ) AS total_sales_4_weeks_before_after_2020_06_15
        ,(
            SELECT FORMAT(total_sales, '##,##')
            FROM #before_after_12_weeks
            ) AS total_sales_12_weeks_before_after_2020_06_15
        ,(
            SELECT total_sales_2018
            FROM sales_2018_cte
            ) AS total_sales_2018
        ,(
            SELECT total_sales_2019
            FROM sales_2019_cte
            ) AS total_sales_2019;
    ```

    Output:

    | total_sales_4_weeks_before_after_2020_06_15 | total_sales_12_weeks_before_after_2020_06_15 | total_sales_2018 | total_sales_2019 |
    |---------------------------------------------|----------------------------------------------|------------------|------------------|
    | 5,250,808,928                               | 14,100,220,900                               | 12,897,380,827   | 13,746,032,500   |
