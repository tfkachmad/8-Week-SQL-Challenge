USE EightWeekSQLChallenge;
--
/*
	========	A. DATA EXPLORATION AND CLEANSING	========
*/
--
--	1.	Update the fresh_segments.interest_metrics table by modifying the month_year
--		column to be a date data type with the start of the month
--
ALTER TABLE fresh_segments.interest_metrics
ADD new_month_year date;
--
UPDATE fresh_segments.interest_metrics
SET new_month_year = CAST((LEFT(month_year, 2) + '-01-' + RIGHT(month_year, 4)) AS DATE)
--
SELECT TOP 5 *
FROM fresh_segments.interest_metrics;

/*
	_month _year month_year interest_id composition            index_value            ranking     percentile_ranking     new_date
	------ ----- ---------- ----------- ---------------------- ---------------------- ----------- ---------------------- ----------
	7      2018  07-2018    32486       11.89                  6.19                   1           99.86                  2018-01-07
	7      2018  07-2018    6106        9.93                   5.31                   2           99.73                  2018-01-07
	7      2018  07-2018    18923       10.85                  5.29                   3           99.59                  2018-01-07
	7      2018  07-2018    6344        10.32                  5.1                    4           99.45                  2018-01-07
	7      2018  07-2018    100         10.77                  5.04                   5           99.31                  2018-01-07
*/
--
--	2.	What is count of records in the fresh_segments.interest_metrics for each month_year 
--		value sorted in chronological order (earliest to latest) with the null values 
--		appearing first?
WITH month_year_CTE
AS (
	SELECT new_month_year
		,MONTH(new_month_year) AS m
		,YEAR(new_month_year) AS y
	FROM fresh_segments.interest_metrics
	)
SELECT new_month_year
	,COUNT(*) AS records_cnt
FROM month_year_CTE
GROUP BY new_month_year
	,m
	,y
ORDER BY y
	,m;

/*
	new_month_year records_cnt
	-------------- -----------
	NULL           1194
	2018-07-01     729
	2018-08-01     767
	2018-09-01     780
	2018-10-01     857
	2018-11-01     928
	2018-12-01     995
	2019-01-01     973
	2019-02-01     1121
	2019-03-01     1136
	2019-04-01     1099
	2019-05-01     857
	2019-06-01     824
	2019-07-01     864
	2019-08-01     1149
*/
--
--	3.	What do you think we should do with these null values in the 
--		fresh_segments.interest_metrics
SELECT *
FROM fresh_segments.interest_metrics
WHERE new_month_year IS NULL;
/*
	_month _year month_year interest_id composition            index_value            ranking     percentile_ranking     new_month_year
	------ ----- ---------- ----------- ---------------------- ---------------------- ----------- ---------------------- --------------
	NULL   NULL  NULL       NULL        6.12                   2.85                   43          96.4                   NULL
	NULL   NULL  NULL       NULL        7.13                   2.84                   45          96.23                  NULL
	NULL   NULL  NULL       NULL        6.82                   2.84                   45          96.23                  NULL
	NULL   NULL  NULL       NULL        5.96                   2.83                   47          96.06                  NULL
	NULL   NULL  NULL       NULL        7.73                   2.82                   48          95.98                  NULL
	NULL   NULL  NULL       NULL        5.37                   2.82                   48          95.98                  NULL
	NULL   NULL  NULL       NULL        6.15                   2.82                   48          95.98                  NULL
	NULL   NULL  NULL       NULL        5.46                   2.81                   51          95.73                  NULL
	NULL   NULL  NULL       NULL        6.57                   2.81                   51          95.73                  NULL
	NULL   NULL  NULL       NULL        6.05                   2.81                   51          95.73                  NULL

	Dropping the rows where the month_year value is NULL could be the right things to do.
	This is because the rows with NULL month_year value also have NULL value for its interest_id.
	That means, the aggregated values for those rows doesn't pointing/map to any interest in the
	fresh_segment.interest_map table.

	But, there is one exception row for this,
	
	_month _year month_year interest_id composition            index_value            ranking     percentile_ranking     new_month_year
	------ ----- ---------- ----------- ---------------------- ---------------------- ----------- ---------------------- --------------
	NULL   NULL  NULL       21246       1.61                   0.68                   1191        0.25                   NULL

	For this row, because the interest_id is not NULL, the aggregated value it has can be used.
*/
--
--	4.	How many interest_id values exist in the fresh_segments.interest_metrics 
--		table but not in the fresh_segments.interest_map table? What about the other way around?
WITH interest_map_id_CTE
AS (
	SELECT DISTINCT id
	FROM fresh_segments.interest_map
	)
SELECT COUNT(DISTINCT interest_id) AS interest_id_cnt
FROM fresh_segments.interest_metrics
WHERE interest_id NOT IN (
		SELECT id
		FROM interest_map_id_CTE
		);
/*
	interest_id_cnt
	---------------
	0
*/
--
WITH interest_map_interest_id_CTE
AS (
	SELECT DISTINCT interest_id
	FROM fresh_segments.interest_metrics
	)
SELECT COUNT(DISTINCT id) AS id_cnt
FROM fresh_segments.interest_map
WHERE id NOT IN (
		SELECT interest_id
		FROM interest_map_interest_id_CTE
		WHERE interest_id IS NOT NULL
		);
/*
	id_cnt
	-----------
	7
*/
--
--	5.	Summarise the id values in the fresh_segments.interest_map by its total 
--		record count in this table
SELECT id, COUNT(*) AS cnt
FROM fresh_segments.interest_map
GROUP BY id;
/*	First 10 rows
	id          cnt
	----------- -----------
	1           1
	2           1
	3           1
	4           1
	5           1
	6           1
	7           1
	8           1
	12          1
	13          1
	
	Because each id in this table represent each intrest name from the client and its summary,
	Each id would only occur once in this table, for example the first 10 rows in the result are
	showing the count of each interest equal to 1.
*/
--
--	6.	What sort of table join should we perform for our analysis and why? 
--		Check your logic by checking the rows where interest_id = 21246 in your joined output 
--		and include all columns from fresh_segments.interest_metrics and all columns from 
--		fresh_segments.interest_map except from the id column.
SELECT mat.*
	,map.interest_name
	,map.interest_summary
	,map.created_at
	,map.last_modified
FROM fresh_segments.interest_metrics AS mat
LEFT JOIN fresh_segments.interest_map AS map
	ON mat.interest_id = map.id
WHERE mat.interest_id = 21246;
/*
	_month _year month_year interest_id composition            index_value            ranking     percentile_ranking     new_month_year interest_name                                                                                                                                                                                                                                                    interest_summary                                                                                                                                                                                                                                                 created_at                  last_modified
	------ ----- ---------- ----------- ---------------------- ---------------------- ----------- ---------------------- -------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------------- ---------------------------
	7      2018  07-2018    21246       2.26                   0.65                   722         0.96                   2018-07-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	8      2018  08-2018    21246       2.13                   0.59                   765         0.26                   2018-08-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	9      2018  09-2018    21246       2.06                   0.61                   774         0.77                   2018-09-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	10     2018  10-2018    21246       1.74                   0.58                   855         0.23                   2018-10-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	11     2018  11-2018    21246       2.25                   0.78                   908         2.16                   2018-11-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	12     2018  12-2018    21246       1.97                   0.7                    983         1.21                   2018-12-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	1      2019  01-2019    21246       2.05                   0.76                   954         1.95                   2019-01-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	2      2019  02-2019    21246       1.84                   0.68                   1109        1.07                   2019-02-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	3      2019  03-2019    21246       1.75                   0.67                   1123        1.14                   2019-03-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	4      2019  04-2019    21246       1.58                   0.63                   1092        0.64                   2019-04-01     Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000
	NULL   NULL  NULL       21246       1.61                   0.68                   1191        0.25                   NULL           Readers of El Salvadoran Content                                                                                                                                                                                                                                 People reading news from El Salvadoran media sources.                                                                                                                                                                                                            2018-06-11 17:50:04.0000000 2018-06-11 17:50:04.0000000

	Joining using INNER JOIN will resulting on NULL interest_id rows from fresh_segments.interest_metrics
	dropped. To anticipate that, LEFT JOIN will needed. But, if the NULL values from fresh_segments.interest_metrics
	table are ignored, INNER JOIN will be used.
*/
--
--	7.	Are there any records in your joined table where the month_year value is before the 
--		created_at value from the fresh_segments.interest_map table? 
--		Do you think these values are valid and why?
--
-- Find how many records with month_year value is before the
WITH month_year_leading_CTE
AS (
	SELECT mat.new_month_year
		,map.created_at
		,map.interest_name
		,map.interest_summary
	FROM fresh_segments.interest_metrics AS mat
	LEFT JOIN fresh_segments.interest_map AS map
		ON mat.interest_id = map.id
	WHERE new_month_year < created_at
	)
SELECT COUNT(*) AS [count]
FROM month_year_leading_CTE;

--		created_at value
SELECT TOP 10 mat.new_month_year
	,map.created_at
	,map.interest_name
	,map.interest_summary
FROM fresh_segments.interest_metrics AS mat
LEFT JOIN fresh_segments.interest_map AS map
	ON mat.interest_id = map.id
WHERE new_month_year < created_at;
/*	First 10 rows
	new_month_year created_at                  interest_name                                                                                                                                                                                                                                                    interest_summary
	-------------- --------------------------- ------------------------------
	2018-07-01     2018-07-06 14:35:04.0000000 Major Airline Customers                                                                                                                                                                                                                                          People visiting sites for major airline brands to plan and view travel itinerary.
	2018-07-01     2018-07-17 10:40:03.0000000 Online Shoppers                                                                                                                                                                                                                                                  People who spend money online
	2018-07-01     2018-07-06 14:35:04.0000000 School Supply Shoppers                                                                                                                                                                                                                                           Consumers shopping for classroom supplies for K-12 students.
	2018-07-01     2018-07-06 14:35:03.0000000 Womens Equality Advocates                                                                                                                                                                                                                                        People visiting sites advocating for womens equal rights.
	2018-07-01     2018-07-06 14:35:04.0000000 Certified Events Professionals                                                                                                                                                                                                                                   Professionals reading industry news and researching products and services for event management.
	2018-07-01     2018-07-06 14:35:04.0000000 Romantics                                                                                                                                                                                                                                                        People reading about romance and researching ideas for planning romantic moments.
	2018-08-01     2018-08-15 18:00:04.0000000 Toronto Blue Jays Fans                                                                                                                                                                                                                                           People reading news about the Toronto Blue Jays and watching games. These consumers are more likely to spend money on team gear.
	2018-08-01     2018-08-15 18:00:04.0000000 Boston Red Sox Fans                                                                                                                                                                                                                                              People reading news about the Boston Red Sox and watching games. These consumers are more likely to spend money on team gear.
	2018-08-01     2018-08-15 18:00:04.0000000 New York Yankees Fans                                                                                                                                                                                                                                            People reading news about the New York Yankees and watching games. These consumers are more likely to spend money on team gear.
	2018-08-01     2018-08-02 16:05:03.0000000 Boston Bruins Fans                                                                                                                                                                                                                                               People reading news about the Boston Bruins and watching games. These consumers are more likely to spend money on team gear.

	There are total of 188 entries in the fresh_segments.interest_map table
	where the month_year value is before created_at value. This is valid because the
	month_year value is basically aggregated values that grouped per for that month.
	Because the new column now written as, for example 2018-08-01 from just 08-2018,
	The day value for this column now will be compared to when each interest are made.
	After all, this new day value from the new month_year column only exists to change the column
	data type to date only, no particular meaning behind that.
*/
