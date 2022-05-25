USE EightWeekSQLChallenge;
--
/*
	========	D. INDEX ANALYSIS	========
*/
--
--	The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
--	Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
--
--	Creating average composition column
DROP TABLE IF EXISTS #new_interest_matrics;
SELECT *, ROUND((CAST(composition AS float) / index_value), 2) AS average_composition
INTO #new_interest_matrics
FROM fresh_segments.interest_metrics;
--
SELECT *
FROM #new_interest_matrics;
--
--	1.	What is the top 10 interests by the average composition for each month?
WITH interest_CTE
AS (
	SELECT interest_id
		,new_month_year
		,average_composition
		,interest_name
		,ROW_NUMBER() OVER (
			PARTITION BY new_month_year ORDER BY average_composition DESC
			) AS rn
	FROM #new_interest_matrics AS mat
	JOIN fresh_segments.interest_map AS map
		ON mat.interest_id = map.id
	WHERE new_month_year IS NOT NULL
	)
SELECT new_month_year
	,interest_name
	,average_composition
FROM interest_CTE
WHERE rn BETWEEN 1
		AND 10;
/*
	new_month_year interest_name										average_composition
	-------------- ----------------------------------------------------	----------------------
	2018-07-01     Las Vegas Trip Planners								7.36
	2018-07-01     Gym Equipment Owners									6.94
	2018-07-01     Cosmetics and Beauty Shoppers						6.78
	2018-07-01     Luxury Retail Shoppers								6.61
	2018-07-01     Furniture Shoppers									6.51
	2018-07-01     Asian Food Enthusiasts								6.1
	2018-07-01     Recently Retired Individuals							5.72
	2018-07-01     Family Adventures Travelers							4.85
	2018-07-01     Work Comes First Travelers							4.8
	2018-07-01     HDTV Researchers										4.71
	2018-08-01     Las Vegas Trip Planners								7.21
	2018-08-01     Gym Equipment Owners									6.62
	2018-08-01     Luxury Retail Shoppers								6.53
	2018-08-01     Furniture Shoppers									6.3
	2018-08-01     Cosmetics and Beauty Shoppers						6.28
	2018-08-01     Work Comes First Travelers							5.7
	2018-08-01     Asian Food Enthusiasts								5.68
	2018-08-01     Recently Retired Individuals							5.58
	2018-08-01     Alabama Trip Planners								4.83
	2018-08-01     Luxury Bedding Shoppers								4.72
	2018-09-01     Work Comes First Travelers							8.26
	2018-09-01     Readers of Honduran Content							7.6
	2018-09-01     Alabama Trip Planners								7.27
	2018-09-01     Luxury Bedding Shoppers								7.04
	2018-09-01     Nursing and Physicians Assistant Journal Researchers	6.7
	2018-09-01     New Years Eve Party Ticket Purchasers				6.59
	2018-09-01     Teen Girl Clothing Shoppers							6.53
	2018-09-01     Christmas Celebration Researchers					6.47
	2018-09-01     Restaurant Supply Shoppers							6.25
	2018-09-01     Solar Energy Researchers								6.24
	2018-10-01     Work Comes First Travelers							9.14
	2018-10-01     Alabama Trip Planners								7.1
	2018-10-01     Nursing and Physicians Assistant Journal Researchers	7.02
	2018-10-01     Readers of Honduran Content							7.02
	2018-10-01     Luxury Bedding Shoppers								6.94
	2018-10-01     New Years Eve Party Ticket Purchasers				6.91
	2018-10-01     Teen Girl Clothing Shoppers							6.78
	2018-10-01     Christmas Celebration Researchers					6.72
	2018-10-01     Luxury Boutique Hotel Researchers					6.53
	2018-10-01     Solar Energy Researchers								6.5
	2018-11-01     Work Comes First Travelers							8.28
	2018-11-01     Readers of Honduran Content							7.09
	2018-11-01     Solar Energy Researchers								7.05
	2018-11-01     Alabama Trip Planners								6.69
	2018-11-01     Nursing and Physicians Assistant Journal Researchers	6.65
	2018-11-01     Luxury Bedding Shoppers								6.54
	2018-11-01     New Years Eve Party Ticket Purchasers				6.31
	2018-11-01     Christmas Celebration Researchers					6.08
	2018-11-01     Teen Girl Clothing Shoppers							5.95
	2018-11-01     Restaurant Supply Shoppers							5.59
	2018-12-01     Work Comes First Travelers							8.31
	2018-12-01     Nursing and Physicians Assistant Journal Researchers	6.96
	2018-12-01     Alabama Trip Planners								6.68
	2018-12-01     Luxury Bedding Shoppers								6.63
	2018-12-01     Readers of Honduran Content							6.58
	2018-12-01     Solar Energy Researchers								6.55
	2018-12-01     New Years Eve Party Ticket Purchasers				6.48
	2018-12-01     Teen Girl Clothing Shoppers							6.38
	2018-12-01     Christmas Celebration Researchers					6.09
	2018-12-01     Chelsea Fans											5.86
	2019-01-01     Work Comes First Travelers							7.66
	2019-01-01     Solar Energy Researchers								7.05
	2019-01-01     Readers of Honduran Content							6.67
	2019-01-01     Luxury Bedding Shoppers								6.46
	2019-01-01     Nursing and Physicians Assistant Journal Researchers	6.46
	2019-01-01     Alabama Trip Planners								6.44
	2019-01-01     New Years Eve Party Ticket Purchasers				6.16
	2019-01-01     Teen Girl Clothing Shoppers							5.96
	2019-01-01     Christmas Celebration Researchers					5.65
	2019-01-01     Chelsea Fans											5.48
	2019-02-01     Work Comes First Travelers							7.66
	2019-02-01     Nursing and Physicians Assistant Journal Researchers	6.84
	2019-02-01     Luxury Bedding Shoppers								6.76
	2019-02-01     Alabama Trip Planners								6.65
	2019-02-01     Solar Energy Researchers								6.58
	2019-02-01     New Years Eve Party Ticket Purchasers				6.56
	2019-02-01     Teen Girl Clothing Shoppers							6.29
	2019-02-01     Readers of Honduran Content							6.24
	2019-02-01     PlayStation Enthusiasts								6.23
	2019-02-01     Christmas Celebration Researchers					5.98
	2019-03-01     Alabama Trip Planners								6.54
	2019-03-01     Nursing and Physicians Assistant Journal Researchers	6.52
	2019-03-01     Luxury Bedding Shoppers								6.47
	2019-03-01     Solar Energy Researchers								6.4
	2019-03-01     Readers of Honduran Content							6.21
	2019-03-01     New Years Eve Party Ticket Purchasers				6.21
	2019-03-01     PlayStation Enthusiasts								6.06
	2019-03-01     Teen Girl Clothing Shoppers							6.01
	2019-03-01     Readers of Catholic News								5.65
	2019-03-01     Restaurant Supply Shoppers							5.61
	2019-04-01     Solar Energy Researchers								6.28
	2019-04-01     Alabama Trip Planners								6.21
	2019-04-01     Luxury Bedding Shoppers								6.05
	2019-04-01     Readers of Honduran Content							6.02
	2019-04-01     Nursing and Physicians Assistant Journal Researchers	6.01
	2019-04-01     New Years Eve Party Ticket Purchasers				5.65
	2019-04-01     PlayStation Enthusiasts								5.52
	2019-04-01     Teen Girl Clothing Shoppers							5.39
	2019-04-01     Readers of Catholic News								5.3
	2019-04-01     Restaurant Supply Shoppers							5.07
	2019-05-01     Readers of Honduran Content							4.41
	2019-05-01     Readers of Catholic News								4.08
	2019-05-01     Solar Energy Researchers								3.92
	2019-05-01     PlayStation Enthusiasts								3.55
	2019-05-01     Alabama Trip Planners								3.34
	2019-05-01     Gamers												3.29
	2019-05-01     Luxury Bedding Shoppers								3.25
	2019-05-01     New Years Eve Party Ticket Purchasers				3.19
	2019-05-01     Video Gamers											3.19
	2019-05-01     Nursing and Physicians Assistant Journal Researchers	3.15
	2019-06-01     Las Vegas Trip Planners								2.77
	2019-06-01     Gym Equipment Owners									2.55
	2019-06-01     Cosmetics and Beauty Shoppers						2.55
	2019-06-01     Asian Food Enthusiasts								2.52
	2019-06-01     Luxury Retail Shoppers								2.46
	2019-06-01     Furniture Shoppers									2.39
	2019-06-01     Medicare Researchers									2.35
	2019-06-01     Recently Retired Individuals							2.27
	2019-06-01     Medicare Provider Researchers						2.21
	2019-06-01     Cruise Travel Intenders								2.2
	2019-07-01     Las Vegas Trip Planners								2.82
	2019-07-01     Luxury Retail Shoppers								2.81
	2019-07-01     Gym Equipment Owners									2.79
	2019-07-01     Furniture Shoppers									2.79
	2019-07-01     Cosmetics and Beauty Shoppers						2.78
	2019-07-01     Asian Food Enthusiasts								2.78
	2019-07-01     Medicare Researchers									2.77
	2019-07-01     Medicare Provider Researchers						2.73
	2019-07-01     Recently Retired Individuals							2.72
	2019-07-01     Medicare Price Shoppers								2.66
	2019-08-01     Cosmetics and Beauty Shoppers						2.73
	2019-08-01     Gym Equipment Owners									2.72
	2019-08-01     Las Vegas Trip Planners								2.7
	2019-08-01     Asian Food Enthusiasts								2.68
	2019-08-01     Solar Energy Researchers								2.66
	2019-08-01     Furniture Shoppers									2.59
	2019-08-01     Luxury Retail Shoppers								2.59
	2019-08-01     Marijuana Legalization Advocates						2.56
	2019-08-01     Medicare Researchers									2.55
	2019-08-01     Recently Retired Individuals							2.53

*/
--
--	2.	For all of these top 10 interests - which interest appears the most often?
WITH interest_CTE
AS (
	SELECT interest_id
		,new_month_year
		,average_composition
		,CAST(interest_name AS VARCHAR) AS interest_name
		,ROW_NUMBER() OVER (
			PARTITION BY new_month_year ORDER BY average_composition DESC
			) AS rn
	FROM #new_interest_matrics AS mat
	JOIN fresh_segments.interest_map AS map
		ON mat.interest_id = map.id
	WHERE new_month_year IS NOT NULL
	)
	,top_interest_CTE
AS (
	SELECT interest_id
		,new_month_year
		,interest_name
		,average_composition
	FROM interest_CTE
	WHERE rn BETWEEN 1
			AND 10
	)
	,ranking_CTE
AS (
	SELECT interest_name
		,COUNT(interest_name) AS appearance_cnt
		,RANK() OVER (
			ORDER BY COUNT(interest_name) DESC
			) AS rnk
	FROM top_interest_CTE
	GROUP BY interest_name
	)
SELECT interest_name
	,appearance_cnt
FROM ranking_CTE
WHERE rnk = 1;
/*
	interest_name                  appearance_cnt
	------------------------------ --------------
	Solar Energy Researchers       10
	Luxury Bedding Shoppers        10
	Alabama Trip Planners          10
*/
--
--	3.	What is the average of the average composition for the top 10 interests for each month?
WITH interest_CTE
AS (
	SELECT interest_id
		,new_month_year
		,average_composition
		,interest_name
		,ROW_NUMBER() OVER (
			PARTITION BY new_month_year ORDER BY average_composition DESC
			) AS rn
	FROM #new_interest_matrics AS mat
	JOIN fresh_segments.interest_map AS map
		ON mat.interest_id = map.id
	WHERE new_month_year IS NOT NULL
	)
SELECT new_month_year
	,ROUND((AVG(average_composition)), 2) AS average_composition_avg
FROM interest_CTE
WHERE rn BETWEEN 1
		AND 10
GROUP BY new_month_year;
/*
	new_month_year average_composition_avg
	-------------- -----------------------
	2018-07-01     6.04
	2018-08-01     5.94
	2018-09-01     6.89
	2018-10-01     7.07
	2018-11-01     6.62
	2018-12-01     6.65
	2019-01-01     6.4
	2019-02-01     6.58
	2019-03-01     6.17
	2019-04-01     5.75
	2019-05-01     3.54
	2019-06-01     2.43
	2019-07-01     2.76
	2019-08-01     2.63
*/
--
--	4.	What is the 3 month rolling average of the max average composition value 
--		from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
WITH numbering_CTE
AS (
	SELECT new_month_year
		,interest_id
		,average_composition
		,ROW_NUMBER() OVER (
			PARTITION BY new_month_year ORDER BY average_composition DESC
			) AS rn
	FROM #new_interest_matrics
	WHERE new_month_year IS NOT NULL
	)
	,max_average_comp_CTE
AS (
	SELECT n.new_month_year
		,CAST(m.interest_name AS VARCHAR) AS interest_name
		,n.average_composition AS max_index_composition
		,ROUND((
				AVG(n.average_composition) OVER (
					ORDER BY n.new_month_year ROWS BETWEEN 2 PRECEDING
							AND CURRENT ROW
					)
				), 2) AS [3_month_moving_avg]
	FROM numbering_CTE AS n
	JOIN fresh_segments.interest_map AS m
		ON n.interest_id = m.id
	WHERE rn = 1
	)
	,lag_CTE
AS (
	SELECT *
		,LAG(interest_name, 1) OVER (
			ORDER BY new_month_year
			) AS interest_1_month
		,LAG(interest_name, 2) OVER (
			ORDER BY new_month_year
			) AS interest_2_month
		,CAST((
				LAG(max_index_composition, 1) OVER (
					ORDER BY new_month_year
					)
				) AS VARCHAR) AS [1_month_ago]
		,CAST((
				LAG(max_index_composition, 2) OVER (
					ORDER BY new_month_year
					)
				) AS VARCHAR) AS [2_month_ago]
	FROM max_average_comp_CTE
	)
SELECT new_month_year
	,interest_name
	,max_index_composition
	,[3_month_moving_avg]
	,(interest_1_month + ': ' + [1_month_ago]) AS [1_month_ago]
	,(interest_2_month + + ': ' + [2_month_ago]) AS [2_month_ago]
FROM lag_CTE
WHERE new_month_year BETWEEN '2018-09-01'
		AND '2019-08-01';
/*
	new_month_year interest_name                  max_index_composition  3_month_moving_avg     1_month_ago                       2_month_ago
	-------------- ------------------------------ ---------------------- ---------------------- --------------------------------- ---------------------------------
	2018-09-01     Work Comes First Travelers     8.26                   7.61                   Las Vegas Trip Planners: 7.21     Las Vegas Trip Planners: 7.36
	2018-10-01     Work Comes First Travelers     9.14                   8.2                    Work Comes First Travelers: 8.26  Las Vegas Trip Planners: 7.21
	2018-11-01     Work Comes First Travelers     8.28                   8.56                   Work Comes First Travelers: 9.14  Work Comes First Travelers: 8.26
	2018-12-01     Work Comes First Travelers     8.31                   8.58                   Work Comes First Travelers: 8.28  Work Comes First Travelers: 9.14
	2019-01-01     Work Comes First Travelers     7.66                   8.08                   Work Comes First Travelers: 8.31  Work Comes First Travelers: 8.28
	2019-02-01     Work Comes First Travelers     7.66                   7.88                   Work Comes First Travelers: 7.66  Work Comes First Travelers: 8.31
	2019-03-01     Alabama Trip Planners          6.54                   7.29                   Work Comes First Travelers: 7.66  Work Comes First Travelers: 7.66
	2019-04-01     Solar Energy Researchers       6.28                   6.83                   Alabama Trip Planners: 6.54       Work Comes First Travelers: 7.66
	2019-05-01     Readers of Honduran Content    4.41                   5.74                   Solar Energy Researchers: 6.28    Alabama Trip Planners: 6.54
	2019-06-01     Las Vegas Trip Planners        2.77                   4.49                   Readers of Honduran Content: 4.41 Solar Energy Researchers: 6.28
	2019-07-01     Las Vegas Trip Planners        2.82                   3.33                   Las Vegas Trip Planners: 2.77     Readers of Honduran Content: 4.41
	2019-08-01     Cosmetics and Beauty Shoppers  2.73                   2.77                   Las Vegas Trip Planners: 2.82     Las Vegas Trip Planners: 2.77
*/
--
--	Required output for question 4:
/*
	|month_year|interest_name			     |max_index_composition|3_month_moving_avg|1_month_ago					    |2_months_ago					  |
	|----------|-----------------------------|---------------------|------------------|---------------------------------|---------------------------------|
	|2018-09-01|Work Comes First Travelers   |8.26				   |7.61              |Las Vegas Trip Planners: 7.21	|Las Vegas Trip Planners: 7.36	  |
	|2018-10-01|Work Comes First Travelers   |9.14				   |8.20              |Work Comes First Travelers: 8.26	|Las Vegas Trip Planners: 7.21	  |
	|2018-11-01|Work Comes First Travelers   |8.28				   |8.56              |Work Comes First Travelers: 9.14	|Work Comes First Travelers: 8.26 |
	|2018-12-01|Work Comes First Travelers   |8.31				   |8.58              |Work Comes First Travelers: 8.28	|Work Comes First Travelers: 9.14 |
	|2019-01-01|Work Comes First Travelers   |7.66				   |8.08              |Work Comes First Travelers: 8.31	|Work Comes First Travelers: 8.28 |
	|2019-02-01|Work Comes First Travelers   |7.66				   |7.88              |Work Comes First Travelers: 7.66	|Work Comes First Travelers: 8.31 |
	|2019-03-01|Alabama Trip Planners	     |6.54				   |7.29              |Work Comes First Travelers: 7.66	|Work Comes First Travelers: 7.66 |
	|2019-04-01|Solar Energy Researchers     |6.28				   |6.83              |Alabama Trip Planners: 6.54		|Work Comes First Travelers: 7.66 |
	|2019-05-01|Readers of Honduran Content  |4.41				   |5.74              |Solar Energy Researchers: 6.28	|Alabama Trip Planners: 6.54	  |
	|2019-06-01|Las Vegas Trip Planners      |2.77				   |4.49              |Readers of Honduran Content: 4.41|Solar Energy Researchers: 6.28	  |
	|2019-07-01|Las Vegas Trip Planners      |2.82				   |3.33              |Las Vegas Trip Planners: 2.77	|Readers of Honduran Content: 4.41|
	|2019-08-01|Cosmetics and Beauty Shoppers|2.73				   |2.77              |Las Vegas Trip Planners: 2.82	|Las Vegas Trip Planners: 2.77	  |
*/
--
--	5.	Provide a possible reason why the max average composition might change from month to month? 
--		Could it signal something is not quite right with the overall business model for Fresh Segments?
		/*
			One possible reason based on the previous question is seasonal change. 
			Based on the result, the customer interaction on contents that related to travel/holiday 
			are relatively higher than the other, especially on the holiday season or end of the year. 
			Because of this, the interaction on contents that are other than travel/holiday would be lower outside the holiday season.
		*/
