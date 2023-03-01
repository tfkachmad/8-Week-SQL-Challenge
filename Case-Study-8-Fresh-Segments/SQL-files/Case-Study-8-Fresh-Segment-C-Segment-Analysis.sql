--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 8 - Fresh Segments
-- Part C - Segment Analysis
--
--  1. Using our filtered dataset by removing the interests with less than 6 months
--  worth of data, which are the top 10 and bottom 10 interests which have the largest
--  composition values in any month_year? Only use the maximum composition value for each
--  interest but you must keep the corresponding month_year
SET search_path = 'fresh_segments';

CREATE TEMPORARY TABLE IF NOT EXISTS filtered_interest AS
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
    *
FROM
    fresh_segments.interest_metrics
WHERE
    month_year IS NOT NULL
    AND interest_id IN (
        SELECT
            interest_id
        FROM
            interest_id_list);

-- Highest composition
WITH interest_composition AS (
    SELECT
        month_year,
        interest_id,
        MAX(composition) AS max_composition
    FROM
        filtered_interest
    GROUP BY
        1,
        2
),
interest_ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY max_composition DESC) AS top_interest
    FROM
        interest_composition
)
SELECT
    i1.month_year,
    i2.interest_name,
    i1.max_composition
FROM
    interest_ranking AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
WHERE
    top_interest <= 10
ORDER BY
    1;

-- Lowest composition
WITH interest_composition AS (
    SELECT
        month_year,
        interest_id,
        MAX(composition) AS max_composition
    FROM
        filtered_interest
    GROUP BY
        1,
        2
),
interest_ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY max_composition) AS bottom_interest
    FROM
        interest_composition
)
SELECT
    i1.month_year,
    i2.interest_name,
    i1.max_composition
FROM
    interest_ranking AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
WHERE
    bottom_interest < 10
ORDER BY
    1;

--
--  2. Which 5 interests had the lowest average ranking value?
WITH interest_ranking AS (
    SELECT
        interest_id,
        ROUND(AVG(ranking)) AS rank_average
    FROM
        filtered_interest
    GROUP BY
        1
),
interest_ranking_rank AS (
    SELECT
        interest_id,
        rank_average,
        ROW_NUMBER() OVER (ORDER BY rank_average DESC) AS ranking_rank
    FROM
        interest_ranking
)
SELECT
    i2.interest_name,
    i1.rank_average
FROM
    interest_ranking_rank AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
WHERE
    ranking_rank <= 5;

--
--  3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
WITH interest_percentile_ranking AS (
    SELECT
        interest_id,
        ROUND(STDDEV(percentile_ranking)::NUMERIC, 2) AS percentile_ranking_std
    FROM
        filtered_interest
    GROUP BY
        1
),
percentile_ranking_rank AS (
    SELECT
        interest_id,
        percentile_ranking_std,
        ROW_NUMBER() OVER (ORDER BY percentile_ranking_std DESC) AS percentile_rank
    FROM
        interest_percentile_ranking
)
SELECT
    i.interest_name,
    p.percentile_ranking_std
FROM
    percentile_ranking_rank AS p
    JOIN fresh_segments.interest_map AS i ON p.interest_id::INTEGER = i.id
WHERE
    percentile_rank <= 5;

--
--  4. For the 5 interests found in the previous question - what was minimum and maximum
--  percentile_ranking values for each interest and its corresponding year_month value?
--  Can you describe what is happening for these 5 interests?
WITH interest_percentile_ranking AS (
    SELECT
        interest_id,
        ROUND(STDDEV(percentile_ranking)::NUMERIC, 2) AS percentile_ranking_std
    FROM
        filtered_interest
    GROUP BY
        1
),
percentile_ranking_rank AS (
    SELECT
        interest_id,
        percentile_ranking_std,
        ROW_NUMBER() OVER (ORDER BY percentile_ranking_std DESC) AS percentile_rank
    FROM
        interest_percentile_ranking
),
interest_list AS (
    SELECT
        interest_id
    FROM
        percentile_ranking_rank
    WHERE
        percentile_rank <= 5
),
interest_ranking AS (
    SELECT
        month_year,
        interest_id,
        percentile_ranking,
        ROW_NUMBER() OVER (PARTITION BY interest_id ORDER BY percentile_ranking DESC) AS top_rank,
    ROW_NUMBER() OVER (PARTITION BY interest_id ORDER BY percentile_ranking) AS bottom_rank
FROM
    filtered_interest
    WHERE
        interest_id IN (
            SELECT
                interest_id
            FROM
                interest_list))
SELECT
    i1.month_year,
    i2.interest_name,
    i1.percentile_ranking
FROM
    interest_ranking AS i1
    JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
WHERE
    top_rank = 1
    OR bottom_rank = 1
ORDER BY
    2,
    1;

--
--  5. How would you describe our customers in this segment based off their composition and
--  ranking values? What sort of products or services should we show to these customers and
--  what should we avoid?

/*
-   Based on the top interests with the highest composition value, the majority of customers 
    possibly are **adults** with an interest in traveling. The contents/interests that have 
    higher interaction are the indicator for that, for example, *Work Comes First Travelers*.

-   Contents that are related to traveling would be the best things to show to these customers. 
    It's better to avoid showing content that is related to sports and games because they 
    attract less interaction from our customers.
*/
