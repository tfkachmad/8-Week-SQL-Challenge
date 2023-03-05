--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 8 - Fresh Segments
-- Part D - Index Analysis
--
--  The index_value is a measure which can be used to reverse calculate the average
--  composition for Fresh Segments’ clients.
--
--  Average composition can be calculated by dividing the composition column by the
--  index_value column rounded to 2 decimal places.
SET search_path = 'fresh_segments';

DROP TABLE IF EXISTS interest_metrics_comp;

CREATE TEMPORARY TABLE interest_metrics_comp AS
SELECT
    month_year,
    interest_id,
    composition,
    index_value,
    ROUND((composition / index_value)::NUMERIC, 2) AS composition_average,
    ranking,
    percentile_ranking
FROM
    fresh_segments.interest_metrics
WHERE
    month_year IS NOT NULL;

SELECT
    *
FROM
    interest_metrics_comp;

--
--  1. What is the top 10 interests by the average composition for each month?
WITH interest_ranking AS (
    SELECT
        month_year,
        interest_id,
        composition_average,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_rank
    FROM
        interest_metrics_comp
)
SELECT
    i1.month_year,
    i2.interest_name,
    composition_average
FROM
    interest_ranking AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
WHERE
    interest_rank <= 10
ORDER BY
    i1.month_year,
    i1.interest_rank;

--
--  2. For all of these top 10 interests - which interest appears the most often?
WITH interest_ranking AS (
    SELECT
        month_year,
        interest_id,
        composition_average,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_comp_rank
    FROM
        interest_metrics_comp
),
top_interest AS (
    SELECT
        i2.interest_name,
        COUNT(*) AS count_total,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS interest_rank
    FROM
        interest_ranking AS i1
        JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
    WHERE
        interest_comp_rank <= 10
    GROUP BY
        1
)
SELECT
    interest_name,
    count_total
FROM
    top_interest
WHERE
    interest_rank = 1;

--
--  3. What is the average of the average composition for the top 10 interests for each month?
WITH interest_ranking AS (
    SELECT
        month_year,
        composition_average,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_comp_rank
    FROM
        interest_metrics_comp
)
SELECT
    month_year,
    ROUND(AVG(composition_average), 2) AS average_composition_average
FROM
    interest_ranking
WHERE
    interest_comp_rank <= 10
GROUP BY
    1
ORDER BY
    1;

--
--  4. What is the 3 month rolling average of the max average composition value from
--  September 2018 to August 2019 and include the previous top ranking interests in the
--  same output shown below.
WITH interest_ranking AS (
    SELECT
        month_year,
        interest_id,
        composition_average,
        ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_rank
    FROM
        interest_metrics_comp
),
max_previous_interest AS (
    SELECT
        i1.month_year,
        i2.interest_name,
        i1.composition_average,
        ROUND((AVG(i1.composition_average) OVER (ORDER BY i1.month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)), 2) AS comp_3_month_moving_avg,
        LAG(i2.interest_name) OVER (ORDER BY i1.month_year) AS interest_1_month_ago,
        LAG(i1.composition_average) OVER (ORDER BY i1.month_year) AS comp_1_month_ago,
        LAG(i2.interest_name, 2) OVER (ORDER BY i1.month_year) AS interest_2_month_ago,
        LAG(i1.composition_average) OVER (ORDER BY i1.month_year) AS comp_2_month_ago
    FROM
        interest_ranking AS i1
        JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
    WHERE
        interest_rank = 1
)
SELECT
    month_year,
    interest_name,
    composition_average AS max_index_composition,
    comp_3_month_moving_avg AS "3_month_moving_avg",
    interest_1_month_ago || ': ' || comp_1_month_ago AS "1_month_ago",
    interest_2_month_ago || ': ' || comp_2_month_ago AS "2_months_ago"
FROM
    max_previous_interest
WHERE
    month_year >= '2018-09-01';

--
--  5. Provide a possible reason why the max average composition might change from month
--  to month? Could it signal something is not quite right with the overall business model
--  for Fresh Segments?

/*
    One possible reason based on the previous question is seasonal change.
    Based on the result, customer interaction on content related to travel/holiday
    is relatively higher than the other, especially during the holiday season or the
    end of the year. Because of this, the interaction on contents that are other than
    travel/holiday would be lower outside the holiday season.
*/
