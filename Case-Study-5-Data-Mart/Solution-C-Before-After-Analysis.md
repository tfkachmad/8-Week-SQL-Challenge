# :shopping_cart: Case Study 5 - Data Mart: Solution C. Before and After Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

    Query:

    ```sql
    WITH sales_4_weeks_before AS (
    SELECT
        '2020-06-15' AS baseline_week,
        MIN(TO_CHAR((week_date - INTERVAL '4 week'), 'YYYY-MM-DD')::DATE),
        SUM(sales) AS sales_before
    FROM
        data_mart.clean_weekly_sales
    WHERE
        week_date BETWEEN TO_CHAR(('2020-06-15'::DATE - INTERVAL '4 week'), 'YYYY-MM-DD')::DATE AND '2020-06-15'::DATE
    GROUP BY
        1
    ),
    sales_4_weeks_after AS (
        SELECT
            '2020-06-15' AS baseline_week,
            MAX(TO_CHAR((week_date + INTERVAL '4 week'), 'YYYY-MM-DD')::DATE),
            SUM(sales) AS sales_after
        FROM
            data_mart.clean_weekly_sales
        WHERE
            week_date BETWEEN '2020-06-15'::DATE AND TO_CHAR(('2020-06-15'::DATE + INTERVAL '4 week'), 'YYYY-MM-DD')::DATE
        GROUP BY
            1
    )
    SELECT
        TO_CHAR(s1.sales_before, '9,999,999,999') AS sales_total_4_weeks_before,
        TO_CHAR(s2.sales_after, '9,999,999,999') AS sales_total_4_weeks_after,
        TO_CHAR((s2.sales_after - s1.sales_before), '9,999,999,999') AS sales_change,
        ROUND((100 * (s2.sales_after - s1.sales_before) / s1.sales_before::NUMERIC), 2) AS total_sales_change_percentage
    FROM
        sales_4_weeks_before AS s1
        JOIN sales_4_weeks_after AS s2 ON s1.baseline_week = s2.baseline_week;
    ```

    Output:

    | "sales_total_4_weeks_before" | "sales_total_4_weeks_after" | "sales_change" | "total_sales_change_percentage" |
    |------------------------------|-----------------------------|----------------|---------------------------------|
    |  2,915,903,705               |  2,904,930,571              |    -10,973,134 | -0.38                           |

    <br>

2. What about the entire 12 weeks before and after?

    Query:

    ```sql
    WITH sales_12_weeks_before AS (
        SELECT
            '2020-06-15' AS baseline_week,
            MIN(TO_CHAR((week_date - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
            SUM(sales) AS sales_before
        FROM
            data_mart.clean_weekly_sales
        WHERE
            week_date BETWEEN TO_CHAR(('2020-06-15'::DATE - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE AND '2020-06-15'::DATE
        GROUP BY
            1
    ),
    sales_12_weeks_after AS (
        SELECT
            '2020-06-15' AS baseline_week,
            MAX(TO_CHAR((week_date + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
            SUM(sales) AS sales_after
        FROM
            data_mart.clean_weekly_sales
        WHERE
            week_date BETWEEN '2020-06-15'::DATE AND TO_CHAR(('2020-06-15'::DATE + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE
        GROUP BY
            1
    )
    SELECT
        TO_CHAR(s1.sales_before, '9,999,999,999') AS sales_total_12_weeks_before,
        TO_CHAR(s2.sales_after, '9,999,999,999') AS sales_total_12_weeks_after,
        TO_CHAR((s2.sales_after - s1.sales_before), '9,999,999,999') AS total_sales_change,
        ROUND((100 * (s2.sales_after - s1.sales_before) / s1.sales_before::NUMERIC), 2) AS total_sales_change_percentage
    FROM
        sales_12_weeks_before AS s1
        JOIN sales_12_weeks_after AS s2 ON s1.baseline_week = s2.baseline_week;
    ```

    Output:

    | "sales_total_12_weeks_before" | "sales_total_12_weeks_after" | "total_sales_change" | "total_sales_change_percentage" |
    |-------------------------------|------------------------------|----------------------|---------------------------------|
    |  7,696,298,495                |  6,973,947,753               |   -722,350,742       | -9.39                           |

    <br>

3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

    Query:

    ```sql
    WITH sales_2018_2019 AS (
        SELECT
            SUM(
                CASE WHEN calendar_year = 2018 THEN
                    sales
                ELSE
                    NULL
                END) AS sales_2018,
            SUM(
                CASE WHEN calendar_year = 2019 THEN
                    sales
                ELSE
                    NULL
                END) AS sales_2019
        FROM
            data_mart.clean_weekly_sales
    )
    SELECT
        TO_CHAR(s.sales_2018, '9,999,999,999,999') AS sales_2018,
        TO_CHAR(s.sales_2019, '9,999,999,999,999') AS sales_2019,
        TO_CHAR(sales_2019 - sales_2018, '9,999,999,999,999') AS total_sales_change,
        ROUND((100 * (sales_2019 - sales_2018) / sales_2018::NUMERIC), 2) AS total_sales_change_percentage
    FROM
        sales_2018_2019 AS s;
    ```

    Output:

    | "sales_2018"       | "sales_2019"       | "total_sales_change" | "total_sales_change_percentage" |
    |--------------------|--------------------|----------------------|---------------------------------|
    |     12,897,380,827 |     13,746,032,500 |        848,651,673   | 6.58                            |

---
