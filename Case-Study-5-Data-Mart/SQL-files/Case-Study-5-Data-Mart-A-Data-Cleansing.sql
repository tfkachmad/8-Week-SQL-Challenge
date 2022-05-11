USE EightWeekSQLChallenge;
--
/*
	========	A. DATA CLEANSING STEPS		========
*/
--
--	In a single query, perform the following operations and generate 
--	a new table in the data_mart schema named clean_weekly_sales:
--		+	Convert the week_date to a DATE format
--		+	Add a week_number as the second column for each week_date value, 
--			for example any value from the 1st of January to 7th of January will be 1, 
--			8th to 14th will be 2 etc
--		+	Add a month_number with the calendar month for each week_date value as the 3rd column
--		+	Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
--		+	Add a new column called age_band after the original segment column 
--			using the following mapping on the number inside the segment value
--
--				segment		|	age_band
--				----------	|	------------
--				1			|	Young Adults
--				2			|	Middle Aged
--				3 or 4		|	Retirees
--
--		+	Add a new demographic column using the following mapping for the first letter 
--			in the segment values:
--
--				segment		|	demographic
--				----------	|	------------
--				C			|	Couples
--				F			|	Families
--
--		+	Ensure all null string values with an "unknown" string value in the original 
--			segment column as well as the new age_band and demographic columns
--		+	Generate a new avg_transaction column as the sales value divided by 
--			transactions rounded to 2 decimal places for each record
--
-- Create new table, clean_weekly_sales
DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
CREATE TABLE data_mart.clean_weekly_sales (
	"week_date" DATE,
	"week_number" INTEGER,
	"month_number" INTEGER,
	"calendar_year" INTEGER,
	"region" VARCHAR(13),
	"platform" VARCHAR(7),
	"segment" VARCHAR(7),
	"age_band" VARCHAR(12),
	"demographic" VARCHAR(8),
	"customer_type" VARCHAR(8),
	"transactions" INTEGER,
	"sales" INTEGER,
	"avg_transaction" DECIMAL(6,2)
);
--
-- Convert the week_date to a DATE format
WITH first_calc
AS (
	SELECT week_date
		,
		--	Finding the day, month, year from the week_date
		SUBSTRING(week_date, 1, CHARINDEX('/', week_date) - 1) AS d
		,SUBSTRING(week_date, CHARINDEX('/', week_date) + 1, ((CHARINDEX('/', week_date) + 1) - CHARINDEX('/', week_date))) AS m
		,RIGHT(week_date, 2) AS y
		,region
		,[platform]
		--	Change the null values in segment column to unknown
		,CASE 
			WHEN segment LIKE 'null'
				THEN 'unknown'
			ELSE segment
			END AS new_segment
		--	Get the number substring from the segment column
		,CASE 
			WHEN segment LIKE 'null'
				THEN 'unknown'
			ELSE RIGHT(segment, 1)
			END AS segment_number
		--	Get the letter substring from the segment column
		,CASE 
			WHEN segment LIKE 'null'
				THEN 'unknown'
			ELSE LEFT(segment, 1)
			END AS segment_letter
		,customer_type
		,transactions
		,sales
		--	Calculate the avg_transaction from each transactions
		,ROUND((CONVERT(FLOAT, sales) / transactions), 2) AS avg_transaction
	FROM data_mart.weekly_sales
	)
	,second_calc
AS (
	SELECT week_date
		--	Format the day number to two digit if originally written one digit, i.e 8 -> 08
		,CASE 
			WHEN LEN(d) = 1
				THEN CONCAT ('0', d)
			ELSE d
			END AS dd
		--	Format the month number to two digit if originally written one digit, i.e 8 -> 08
		,CASE 
			WHEN LEN(m) = 1
			THEN CONCAT ('0', m)
			ELSE d
			END AS mm
		--	Format the year from two digit to four digit, i.e 20 -> 2020
		,CONCAT ('20', y) AS yyyy
		,region
		,[platform]
		,new_segment
		-- Use the acquired segment number from first_calc CTE to get the age_band
		,CASE 
			WHEN segment_number LIKE 'unknown'
				THEN segment_number
			WHEN segment_number = 1
				THEN 'Young Adults'
			WHEN segment_number = 2
				THEN 'Middle Aged'
			ELSE 'Retirees'
			END AS age_band_result
		-- Use the acquired segment letter from previous first_calc CTE to get the age_band
		,CASE 
			WHEN segment_letter LIKE 'C'
				THEN 'Couples'
			WHEN segment_letter LIKE 'F'
				THEN 'Families'
			ELSE segment_letter
			END AS demographic_result
		,customer_type
		,transactions
		,sales
		,avg_transaction
	FROM first_calc
	)
	,result
AS (
	--	Concatenate the date values from previous second_calc CTE to get date data types format
	--	example: 2020-08-31
	SELECT CONVERT(DATE, CONCAT (
				yyyy
				,mm
				,dd
				)) AS new_week_date
		,region
		,[platform]
		,new_segment
		,age_band_result
		,demographic_result
		,customer_type
		,transactions
		,sales
		,avg_transaction
	FROM second_calc
	)
--	Insert every value into the clean_weekly_sales table
INSERT INTO data_mart.clean_weekly_sales (
	week_date
	,week_number
	,month_number
	,calendar_year
	,region
	,[platform]
	,segment
	,age_band
	,demographic
	,customer_type
	,transactions
	,sales
	,avg_transaction
	)
SELECT new_week_date
	,DATEPART(WEEK, new_week_date) AS week_number
	,DATEPART(MONTH, new_week_date) AS month_number
	,DATEPART(YEAR, new_week_date) AS calendar_year
	,region
	,[platform]
	,new_segment
	,age_band_result
	,demographic_result
	,customer_type
	,transactions
	,sales
	,avg_transaction
FROM result;
