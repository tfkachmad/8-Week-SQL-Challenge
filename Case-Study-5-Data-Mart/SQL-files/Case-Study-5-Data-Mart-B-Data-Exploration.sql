--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 5 - Data Mart
-- Part B - Data Exploration
--
-- 1. What day of the week is used for each week_date value?
SELECT DISTINCT
    TO_CHAR(week_date, 'Day') AS day_of_week
FROM
    data_mart.clean_weekly_sales;

--
-- 2. What range of week numbers are missing from the dataset?
SELECT
    calendar_year,
    MIN(week_number) AS first_week_data,
    MAX(week_number) AS last_week_data
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1
ORDER BY
    1;

--
-- 3. How many total transactions were there for each year in the dataset?
SELECT
    calendar_year,
    TO_CHAR(SUM(transactions), '9,999,999,999') AS transactions_total
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1
ORDER BY
    1;

--
-- 4. What is the total sales for each region for each month?
SELECT
    region,
    TO_CHAR(week_date, 'Month') AS month_name,
    TO_CHAR(SUM(sales), '9,999,999,999') AS sales_total
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1,
    2,
    month_number
ORDER BY
    1,
    month_number;

--
-- 5. What is the total count of transactions for each platform
SELECT
    platform,
    COUNT(*) AS transactions_num
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1;

--
-- 6. What is the percentage of sales for Retail vs Shopify for each month?
WITH platform_sales AS (
    SELECT
        calendar_year,
        month_number,
        TO_CHAR(week_date, 'Month') AS month_name,
        SUM(
            CASE platform
            WHEN 'Retail' THEN
                sales
            ELSE
                0
            END) AS retail_sales,
        SUM(
            CASE platform
            WHEN 'Shopify' THEN
                sales
            ELSE
                0
            END) AS shopify_sales
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1,
        2,
        3
)
SELECT
    calendar_year,
    month_name,
    ROUND((100 * retail_sales / (retail_sales + shopify_sales)::NUMERIC), 2) AS retail_sales_percentage,
    ROUND((100 * shopify_sales / (retail_sales + shopify_sales)::NUMERIC), 2) AS shopify_sales_percentage
FROM
    platform_sales
ORDER BY
    calendar_year,
    month_number;

--
-- 7. What is the percentage of sales by demographic for each year in the dataset?
WITH demoraphic_sales AS (
    SELECT
        calendar_year,
        SUM(
            CASE demographic
            WHEN 'Couples' THEN
                sales
            ELSE
                0
            END) AS couples_sales,
        SUM(
            CASE demographic
            WHEN 'Families' THEN
                sales
            ELSE
                0
            END) AS familes_sales,
        SUM(
            CASE demographic
            WHEN 'unknown' THEN
                sales
            ELSE
                0
            END) AS other_sales
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1
)
SELECT
    calendar_year,
    ROUND((100 * couples_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS couples_sales_percentage,
    ROUND((100 * familes_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS familes_sales_percentage,
    ROUND((100 * other_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS other_sales_percentage
FROM
    demoraphic_sales
ORDER BY
    calendar_year;

--
-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT
    age_band,
    demographic,
    SUM(sales) AS sales_total
FROM
    data_mart.clean_weekly_sales
WHERE
    platform = 'Retail'
GROUP BY
    1,
    2
ORDER BY
    3 DESC
LIMIT 1;

--
-- 9. Can we use the avg_transaction column to find the average transaction size for
--      each year for Retail vs Shopify? If not - how would you calculate it instead?

-- No. The avg_transaction column is showing the average sales generated made per transactions
-- for each week.

SELECT
    calendar_year,
    ROUND(AVG(
            CASE platform
            WHEN 'Retail' THEN
                avg_transaction
            ELSE
                NULL
            END), 2) AS retail_transaction_size_average,
    ROUND(AVG(
            CASE platform
            WHEN 'Shopify' THEN
                avg_transaction
            ELSE
                NULL
            END), 2) AS shopify_transaction_size_average
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1
ORDER BY
    1;

-- To calculate the average transaction per year for each platform, we can just aggregate the
-- transactions column to the year and platform level to get the average transaction size
-- for each year for Retail vs. Shopify
SELECT
    calendar_year,
    ROUND(AVG(
            CASE platform
            WHEN 'Retail' THEN
                transactions
            ELSE
                NULL
            END), 2) AS retail_transaction_size_average,
    ROUND(AVG(
            CASE platform
            WHEN 'Shopify' THEN
                transactions
            ELSE
                NULL
            END), 2) AS shopify_transaction_size_average
FROM
    data_mart.clean_weekly_sales
GROUP BY
    1
ORDER BY
    1;
