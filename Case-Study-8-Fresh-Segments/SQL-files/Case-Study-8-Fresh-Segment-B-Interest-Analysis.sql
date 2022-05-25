USE EightWeekSQLChallenge;
--
/*
	========	B. INTEREST ANALYSIS	========
*/
--
--	1.	Which interests have been present in all month_year dates in our dataset?
--
-- Finding the total months
SELECT COUNT(DISTINCT new_month_year) AS total_months
FROM fresh_segments.interest_metrics;
--
--	The interest_id and its count
WITH interest_CTE
AS (
	SELECT met.interest_id
		,CAST(map.interest_name AS VARCHAR) AS interest_name
		,COUNT(DISTINCT met.new_month_year) AS total_months
	FROM fresh_segments.interest_metrics AS met
	JOIN fresh_segments.interest_map AS map
		ON met.interest_id = map.id
	WHERE new_month_year IS NOT NULL
	GROUP BY interest_id
		,CAST(map.interest_name AS VARCHAR)
	)
SELECT TOP 10 interest_name
FROM interest_CTE
WHERE total_months = 14
ORDER BY total_months DESC;
/*	
First 10 rows
	interest_name
	------------------------------
	Accounting & CPA Continuing Ed
	Affordable Hotel Bookers
	Aftermarket Accessories Shoppe
	Alabama Trip Planners
	Alaskan Cruise Planners
	Alzheimer and Dementia Researc
	Anesthesiologists
	Apartment Furniture Shoppers
	Apartment Hunters
	Apple Fans
*/
--
--	2.	Using this same total_months measure - calculate the cumulative percentage 
--		of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH total_months_CTE
AS (
	SELECT interest_id
		,COUNT(DISTINCT new_month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE new_month_year IS NOT NULL
	GROUP BY interest_id
	)
	,interest_cnt_CTE
AS (
	SELECT total_months
		,CAST((COUNT(DISTINCT interest_id)) AS FLOAT) AS interest_cnt
	FROM total_months_CTE
	GROUP BY total_months
	)
SELECT total_months
	,interest_cnt
	,FORMAT((
			SUM(interest_cnt) OVER (
				ORDER BY total_months DESC
				) / SUM(interest_cnt) OVER ()
			), 'p') AS cumulative_pct
FROM interest_cnt_CTE;
/*
	total_months interest_cnt           cumulative_pct
	------------ ---------------------- ---------------
	14           480                    39.93%
	13           82                     46.76%
	12           65                     52.16%
	11           94                     59.98%
	10           86                     67.14%
	9            95                     75.04%
	8            67                     80.62%
	7            90                     88.10%
	6            33                     90.85%
	5            38                     94.01%
	4            32                     96.67%
	3            15                     97.92%
	2            12                     98.92%
	1            13                     100.00%
*/
--
--	3.	If we were to remove all interest_id values which are lower than the total_months 
--		value we found in the previous question - how many total data points would we be removing?
WITH interst_cnt_CTE
AS (
	SELECT interest_id
		,COUNT(DISTINCT new_month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE new_month_year IS NOT NULL
	GROUP BY interest_id
	HAVING COUNT(DISTINCT new_month_year) < 6
	)
	,interest_to_remove_CTE
AS (
	SELECT COUNT(interest_id) AS interest_cnt
	FROM fresh_segments.interest_metrics
	WHERE interest_id IN (
			SELECT interest_id
			FROM interst_cnt_CTE
			)
	)
SELECT COUNT(interest_id) AS initial_data_points
	,(
		SELECT interest_cnt
		FROM interest_to_remove_CTE
		) AS interest_cnt_to_remove
	,COUNT(interest_id) - (
		SELECT interest_cnt
		FROM interest_to_remove_CTE
		) AS remaining_data_points
FROM fresh_segments.interest_metrics;
/*
	initial_data_points interest_cnt_to_remove remaining_data_points
	------------------- ---------------------- ---------------------
	13080               400                    12680
*/
--
--	4.	Does this decision make sense to remove these data points from a business perspective? 
--		Use an example where there are all 14 months present to a removed interest example for your arguments 
--		- think about what it means to have less months present from a segment perspective.
WITH total_months_CTE
AS (
	SELECT interest_id
		,COUNT(DISTINCT new_month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE new_month_year IS NOT NULL
	GROUP BY interest_id
	HAVING COUNT(DISTINCT new_month_year) >= 6
	)
SELECT i.new_month_year
	,i.interest_included
	,e.interest_excluded
	,FORMAT((CAST(interest_excluded AS FLOAT) / i.interest_included), 'p') AS excluded_pct
FROM (
	SELECT new_month_year
		,COUNT(interest_id) AS interest_included
	FROM fresh_segments.interest_metrics
	WHERE interest_id IN (
			SELECT interest_id
			FROM total_months_CTE
			)
	GROUP BY new_month_year
	) AS i
JOIN (
	SELECT new_month_year
		,COUNT(interest_id) AS interest_excluded
	FROM fresh_segments.interest_metrics
	WHERE interest_id NOT IN (
			SELECT interest_id
			FROM total_months_CTE
			)
	GROUP BY new_month_year
	) AS e
	ON i.new_month_year = e.new_month_year
ORDER BY i.new_month_year;
/*
	new_month_year interest_included interest_excluded excluded_pct
	-------------- ----------------- ----------------- ------------
	2018-07-01     709               20                2.82%
	2018-08-01     752               15                1.99%
	2018-09-01     774               6                 0.78%
	2018-10-01     853               4                 0.47%
	2018-11-01     925               3                 0.32%
	2018-12-01     986               9                 0.91%
	2019-01-01     966               7                 0.72%
	2019-02-01     1072              49                4.57%
	2019-03-01     1078              58                5.38%
	2019-04-01     1035              64                6.18%
	2019-05-01     827               30                3.63%
	2019-06-01     804               20                2.49%
	2019-07-01     836               28                3.35%
	2019-08-01     1062              87                8.19%
*/
--
--	5.	After removing these interests - how many unique interests are there for each month?
WITH total_months_CTE
AS (
	SELECT interest_id
		,COUNT(DISTINCT new_month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE new_month_year IS NOT NULL
	GROUP BY interest_id
	HAVING COUNT(DISTINCT new_month_year) >= 6
	)
SELECT new_month_year
	,COUNT(DISTINCT interest_id) AS unique_interest_cnt
FROM fresh_segments.interest_metrics
WHERE interest_id IN (
		SELECT interest_id
		FROM total_months_CTE
		)
GROUP BY new_month_year
ORDER BY new_month_year;
	/*
	new_month_year unique_interest_cnt
	-------------- -------------------
	NULL           1
	2018-07-01     709
	2018-08-01     752
	2018-09-01     774
	2018-10-01     853
	2018-11-01     925
	2018-12-01     986
	2019-01-01     966
	2019-02-01     1072
	2019-03-01     1078
	2019-04-01     1035
	2019-05-01     827
	2019-06-01     804
	2019-07-01     836
	2019-08-01     1062
*/
