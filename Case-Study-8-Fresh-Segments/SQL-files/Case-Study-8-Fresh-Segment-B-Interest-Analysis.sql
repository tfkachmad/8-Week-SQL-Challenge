--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 8 - Fresh Segments
-- Part B - Interest Analysis
--
--  1. Which interests have been present in all month_year dates in our dataset?
WITH interests_count AS (
    SELECT
        interest_id,
        COUNT(month_year) AS count_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    HAVING
        COUNT(month_year) = (
            SELECT
                COUNT(DISTINCT month_year)
            FROM
                fresh_segments.interest_metrics))
SELECT
    COUNT(*) AS interests_total
FROM
    interests_count;

-- Looking at some of the interests
WITH interests_count AS (
    SELECT
        interest_id,
        COUNT(month_year) AS count_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    HAVING
        COUNT(month_year) = (
            SELECT
                COUNT(DISTINCT month_year)
            FROM
                fresh_segments.interest_metrics))
SELECT
    i2.interest_name
FROM
    interests_count AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
LIMIT 5;

--
--  2. Using this same total_months measure - calculate the cumulative percentage of
--  all records starting at 14 months - which total_months value passes the 90% cumulative
--  percentage value?
WITH interests_count AS (
    SELECT
        interest_id,
        COUNT(*) AS month_year_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    ORDER BY
        2 DESC
),
month_year_count AS (
    SELECT
        month_year_num,
        COUNT(*) AS month_year_count
    FROM
        interests_count
    GROUP BY
        1
)
SELECT
    *,
    ROUND((SUM(month_year_count) OVER (ORDER BY month_year_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(month_year_count) OVER () * 100), 1) AS cumulative_percentage
FROM
    month_year_count
ORDER BY
    1 DESC;

--
--  3. If we were to remove all interest_id values which are lower than the total_months
--  value we found in the previous question - how many total data points would we be removing?
WITH interest_id_list AS (
    SELECT
        interest_id,
        COUNT(*) AS month_year_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    HAVING
        COUNT(*) >= 6
)
SELECT
    COUNT(*) AS data_points_total
FROM
    fresh_segments.interest_metrics
WHERE
    interest_id NOT IN (
        SELECT
            interest_id
        FROM
            interest_id_list);

--
--  4. Does this decision make sense to remove these data points from a business perspective?
--  Use an example where there are all 14 months present to a removed interest example for
--  your arguments - think about what it means to have less months present from a segment
--  perspective.
WITH interest_id_list AS (
    SELECT
        interest_id,
        COUNT(*) AS month_year_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    HAVING
        COUNT(*) >= 6
),
interest_id_included AS (
    SELECT
        month_year,
        COUNT(*) AS interest_ids
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
        AND interest_id IN (
            SELECT
                interest_id
            FROM
                interest_id_list)
        GROUP BY
            1
),
interest_id_excluded AS (
    SELECT
        month_year,
        COUNT(*) AS interest_ids
FROM
    fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
        AND interest_id NOT IN (
            SELECT
                interest_id
            FROM
                interest_id_list)
        GROUP BY
            1
)
SELECT
    i1.month_year,
    i1.interest_ids AS included_total,
    i2.interest_ids AS excluded_total,
    ROUND((100 * i2.interest_ids::NUMERIC / i1.interest_ids), 2) AS excluded_percentage
FROM
    interest_id_included AS i1
    JOIN interest_id_excluded AS i2 ON i1.month_year = i2.month_year
ORDER BY
    1;

--
--  5. After removing these interests - how many unique interests are there for each month?
WITH interest_id_list AS (
    SELECT
        interest_id,
        COUNT(*) AS month_year_num
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
    GROUP BY
        1
    HAVING
        COUNT(*) >= 6
),
interest_id_included AS (
    SELECT
        month_year,
        COUNT(*) AS interest_ids
    FROM
        fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
        AND interest_id IN (
            SELECT
                interest_id
            FROM
                interest_id_list)
        GROUP BY
            1
),
interest_id_excluded AS (
    SELECT
        month_year,
        COUNT(*) AS interest_ids
FROM
    fresh_segments.interest_metrics
    WHERE
        month_year IS NOT NULL
        AND interest_id NOT IN (
            SELECT
                interest_id
            FROM
                interest_id_list)
        GROUP BY
            1
)
SELECT
    i1.month_year,
    (i1.interest_ids - i2.interest_ids) AS interest_id_total,
    SUM(i1.interest_ids - i2.interest_ids) OVER () AS interests_total
    FROM
        interest_id_included AS i1
        JOIN interest_id_excluded AS i2 ON i1.month_year = i2.month_year
    ORDER BY
        1;
