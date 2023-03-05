--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 5 - Data Mart
-- Part A - Data Cleansing
--
-- In a single query, perform the following operations and generate a new table in
-- the data_mart schema named clean_weekly_sales:
--  > Convert the week_date to a DATE format
--  > Add a week_number as the second column for each week_date value,
--      for example any value from the 1st of January to 7th of January will be 1,
--      8th to 14th will be 2 etc
--  > Add a month_number with the calendar month for each week_date value as the 3rd column
--  > Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
--  > Add a new column called age_band after the original segment column using the following
--      mapping on the number inside the segment value
--      segment	    age_band
--      1	        Young Adults
--      2	        Middle Aged
--      3 or 4	    Retirees
--  > Add a new demographic column using the following mapping for the first letter in
--      the segment values:
--      segment	    demographic
--      C	        Couples
--      F	        Families
--  > Ensure all null string values with an "unknown" string value in the original segment
--      column as well as the new age_band and demographic columns
--  > Generate a new avg_transaction column as the sales value divided by transactions
--      rounded to 2 decimal places for each record
SET search_path = data_mart;

DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TABLE clean_weekly_sales AS
WITH segments AS (
    SELECT DISTINCT
        segment,
        CASE WHEN segment = 'null' THEN
            'unknown'
        ELSE
        LEFT (segment,
            1)
        END AS segment_demo,
        CASE WHEN segment = 'null' THEN
            'unknown'
        ELSE
        RIGHT (segment,
            1)
        END AS segment_age
    FROM
        data_mart.weekly_sales
)
SELECT
    TO_DATE(week_date, 'DD/MM/YY') AS week_date,
    EXTRACT('WEEK' FROM TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
    EXTRACT('MONTH' FROM TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
    EXTRACT('YEAR' FROM TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
    w.region,
    w.platform,
    CASE WHEN s.segment = 'null' THEN
        'unknown'
    ELSE
        s.segment
    END AS segment,
    CASE s.segment_demo
    WHEN 'C' THEN
        'Couples'
    WHEN 'F' THEN
        'Families'
    ELSE
        s.segment_demo
    END AS demographic,
    CASE s.segment_age
    WHEN '1' THEN
        'Young Adults'
    WHEN '2' THEN
        'Middle Aged'
    WHEN '3' THEN
        'Retirees'
    WHEN '4' THEN
        'Retirees'
    ELSE
        s.segment_age
    END AS age_band,
    w.customer_type,
    w.transactions,
    w.sales,
    ROUND((w.sales / w.transactions::NUMERIC), 2) AS avg_transaction
FROM
    data_mart.weekly_sales AS w
    JOIN segments AS s ON w.segment = s.segment;
