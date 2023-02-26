-- Case study questions for #8WeeksSQLChallenge by Danny Ma
-- Week 5 - Data Mart
-- Part d - Bonus Question
--  Which areas of the business have the highest negative impact in sales metrics performance
--  in 2020 for the 12 week before and after period?
--      > region
--      > platform
--      > age_band
--      > demographic
--      > customer_type
--  Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

WITH sales_12_weeks_before AS (
    SELECT
        '2020-06-15' AS baseline_week,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MIN(TO_CHAR(('2020-06-15'::DATE - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
        SUM(sales) AS sales_before
    FROM
        data_mart.clean_weekly_sales
    WHERE
        week_date BETWEEN TO_CHAR(('2020-06-15'::DATE - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE AND '2020-06-15'::DATE
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6
),
sales_12_weeks_after AS (
    SELECT
        '2020-06-15' AS baseline_week,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MAX(TO_CHAR(('2020-06-15'::DATE + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
        SUM(sales) AS sales_after
    FROM
        data_mart.clean_weekly_sales
    WHERE
        week_date BETWEEN '2020-06-15'::DATE AND TO_CHAR(('2020-06-15'::DATE + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6
)
SELECT
    s1.region,
    s1.platform,
    s1.age_band,
    s1.demographic,
    s1.customer_type,
    TO_CHAR(s1.sales_before, '9,999,999,999') AS sales_total_12_weeks_before,
    TO_CHAR(s2.sales_after, '9,999,999,999') AS sales_total_12_weeks_after,
    TO_CHAR((s2.sales_after - s1.sales_before), '9,999,999,999') AS total_sales_change,
    ROUND((100 * (s2.sales_after - s1.sales_before) / s1.sales_before::NUMERIC), 2) AS total_sales_change_percentage
FROM
    sales_12_weeks_before AS s1
    JOIN sales_12_weeks_after AS s2 ON s1.baseline_week = s2.baseline_week
        AND s1.region = s2.region
        AND s1.platform = s2.platform
        AND s1.age_band = s2.age_band
        AND s1.demographic = s2.demographic
        AND s1.customer_type = s2.customer_type
    ORDER BY
        (s2.sales_after - s1.sales_before);
