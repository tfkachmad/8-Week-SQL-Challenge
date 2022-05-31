USE EightWeekSQLChallenge;
--
/*
	========	D. BONUS QUESTION		========
*/
--
--	Which areas of the business have the highest negative impact in sales metrics 
--	performance in 2020 for the 12 week before and after period?
--		+	region
--		+	platform
--		+	age_band
--		+	demographic
--		+	customer_type
--	Do you have any further recommendations for Danny’s team at Data Mart 
--	or any interesting insights based off this analysis?
--
DROP TABLE
IF EXISTS #before_12_weeks;
	WITH before_12_weeks_cte
	AS (
		SELECT DISTINCT week_date
			,DATEADD(WEEK, - 12, week_date) AS before_12_weeks
		FROM data_mart.clean_weekly_sales
		WHERE week_date = '2020-06-15'
		)
	SELECT before_12_weeks
	INTO #before_12_weeks
	FROM before_12_weeks_cte;
--
DROP TABLE
IF EXISTS #after_12_weeks;
	WITH after_12_weeks_cte
	AS (
		SELECT DISTINCT week_date
			,DATEADD(WEEK, 12, week_date) AS after_12_weeks
		FROM data_mart.clean_weekly_sales
		WHERE week_date = '2020-06-15'
		)
	SELECT after_12_weeks
	INTO #after_12_weeks
	FROM after_12_weeks_cte;
--
WITH region_12_weeks_before
AS (
	SELECT region
		,[platform]
		,age_band
		,demographic
		,customer_type
		,SUM(CAST(sales AS BIGINT)) AS sales_per_region_12_weeks_before
	FROM data_mart.clean_weekly_sales AS t1
	JOIN #before_12_weeks AS t2
		ON t1.week_date BETWEEN t2.before_12_weeks
				AND '2020-06-15'
	GROUP BY region
		,[platform]
		,age_band
		,demographic
		,customer_type
	)
	,region_12_weeks_after
AS (
	SELECT region
		,[platform]
		,age_band
		,demographic
		,customer_type
		,SUM(CAST(sales AS BIGINT)) AS sales_per_region_12_weeks_after
	FROM data_mart.clean_weekly_sales AS t1
	JOIN #after_12_weeks AS t2
		ON t1.week_date BETWEEN '2020-06-15'
				AND t2.after_12_weeks
	GROUP BY region
		,[platform]
		,age_band
		,demographic
		,customer_type
	)
	,calculation
AS (
	SELECT bef.region
		,bef.[platform]
		,bef.age_band
		,bef.demographic
		,bef.customer_type
		,sales_per_region_12_weeks_before
		,sales_per_region_12_weeks_after
		,ROUND(CAST((sales_per_region_12_weeks_after - sales_per_region_12_weeks_before) AS FLOAT) / (sales_per_region_12_weeks_before + sales_per_region_12_weeks_after) * 100, 2) AS percent_change
	FROM region_12_weeks_before AS bef
	JOIN region_12_weeks_after AS aft
		ON bef.region = aft.region
			AND bef.[platform] = aft.[platform]
			AND bef.age_band = aft.age_band
			AND bef.demographic = aft.demographic
			AND bef.customer_type = aft.customer_type
	)
	,row_CTE
AS (
	SELECT *
		,ROW_NUMBER() OVER (
			ORDER BY percent_change
			) AS rn
	FROM calculation
	)
SELECT region
	,[platform]
	,age_band
	,demographic
	,customer_type
	,FORMAT(sales_per_region_12_weeks_before, '##,##') AS sales_per_region_12_weeks_before
	,FORMAT(sales_per_region_12_weeks_after, '##,##') AS sales_per_region_12_weeks_after
	,CONCAT (
		percent_change
		,'%'
		) AS percent_change
FROM row_CTE
WHERE rn = 1;

/*
	region        platform age_band     demographic customer_type sales_per_region_12_weeks_before sales_per_region_12_weeks_after percent_change
	------------- -------- ------------ ----------- ------------- -------------------------------- ------------------------------- ------------------------
	SOUTH AMERICA Shopify  unknown      unknown     Existing      12,157                           6,808                           -28.2%
*/
