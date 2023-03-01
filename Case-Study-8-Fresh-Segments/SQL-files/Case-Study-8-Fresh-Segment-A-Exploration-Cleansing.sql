--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 8 - Fresh Segments
-- Part A - Data Exploration and Cleansing
--
--  1. Update the fresh_segments.interest_metrics table by modifying the month_year column
--  to be a date data type with the start of the month.
ALTER TABLE fresh_segments.interest_metrics
    ALTER COLUMN month_year TYPE DATE
    USING TO_DATE(month_year, 'MM-YYYY');

SELECT
    *
FROM
    fresh_segments.interest_metrics
LIMIT 5;

--
--  2. What is count of records in the fresh_segments.interest_metrics for each month_year
--  value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT
    month_year,
    COUNT(*) AS records_num
FROM
    fresh_segments.interest_metrics
GROUP BY
    1
ORDER BY
    1 NULLS FIRST;

--
--  3. What do you think we should do with these null values in the
--  fresh_segments.interest_metrics?
SELECT
    *
FROM
    fresh_segments.interest_metrics
WHERE
    month_year IS NULL
    OR interest_id IS NULL
    OR composition IS NULL
    OR index_value IS NULL
    OR ranking IS NULL
    OR percentile_ranking IS NULL;

--
--  4. How many interest_id values exist in the fresh_segments.interest_metrics table
--  but not in the fresh_segments.interest_map table? What about the other way around?
SELECT
    COUNT(*) AS interest_metrics_id_num
FROM
    fresh_segments.interest_metrics
WHERE
    interest_id::INTEGER NOT IN ( SELECT DISTINCT
            id
        FROM
            fresh_segments.interest_map);

SELECT
    COUNT(id) AS interest_map_id_num
FROM
    fresh_segments.interest_map
WHERE
    id NOT IN ( SELECT DISTINCT
            interest_id::INTEGER
        FROM
            fresh_segments.interest_metrics
        WHERE
            interest_id IS NOT NULL);

--
--  5. Summarise the id values in the fresh_segments.interest_map by its total record
--  count in this table
SELECT
    id,
    COUNT(*) AS id_num
FROM
    fresh_segments.interest_map
GROUP BY
    1;

--
--  6. What sort of table join should we perform for our analysis and why?
--  Check your logic by checking the rows where interest_id = 21246 in your
--  joined output and include all columns from fresh_segments.interest_metrics
--  and all columns from fresh_segments.interest_map except from the id column.
SELECT
    i1.*,
    i2.interest_summary,
    i2.created_at,
    i2.last_modified
FROM
    fresh_segments.interest_metrics AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        AND i1.month_year >= i2.created_at
WHERE
    i1.interest_id = '21246'
ORDER BY
    3;

--
--  7. Are there any records in your joined table where the month_year value is before
--  the created_at value from the fresh_segments.interest_map table?
--  Do you think these values are valid and why?
SELECT
    COUNT(*) AS rows_total
FROM
    fresh_segments.interest_metrics AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        AND i1.month_year < i2.created_at;

SELECT
    i1.month_year,
    i2.created_at
FROM
    fresh_segments.interest_metrics AS i1 TABLESAMPLE BERNOULLI (2) -- Sampling the data
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        AND i1.month_year < i2.created_at;
