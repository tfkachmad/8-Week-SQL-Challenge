USE EightWeekSQLChallenge;
--
/*
	========	B. Data Analysis	========
*/
--
--	1.	How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS customers
FROM foodie_fi.subscriptions;
/*
	customers
	-----------
	1000
*/
--
--	2.	What is the monthly distribution of trial plan start_date values for our dataset 
--		- use the start of the month as the group by value
WITH cte
AS (
	SELECT DATEPART(MONTH, s.[start_date]) AS month_num
		,DATENAME(MONTH, s.[start_date]) AS month_name
		,COUNT(*) AS trial_count
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name = 'trial'
	GROUP BY DATEPART(MONTH, s.[start_date])
		,DATENAME(MONTH, s.[start_date])
	)
SELECT month_name
	,trial_count
FROM cte
ORDER BY month_num;
/*
	month_name                     trial_count
	------------------------------ -----------
	January                        88
	February                       68
	March                          94
	April                          81
	May                            88
	June                           79
	July                           89
	August                         88
	September                      87
	October                        79
	November                       75
	December                       84
*/
--
--	3.	What plan start_date values occur after the year 2020 for our dataset? 
--		Show the breakdown by count of events for each plan_name
WITH cte
AS (
	SELECT p.plan_id AS plan_id
		,p.plan_name AS plans
		,COUNT(*) AS occurences
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE DATEPART(YEAR, s.start_date) > 2020
	GROUP BY p.plan_id
		,p.plan_name
	)
SELECT plans
	,occurences
FROM cte
ORDER BY plan_id;
/*
	plans         occurences
	------------- -----------
	basic monthly 8
	pro monthly   60
	pro annual    63
	churn         71
*/
--
--	4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
WITH cte
AS (
	SELECT CONVERT(FLOAT, COUNT(*)) AS churn_count
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name LIKE 'churn'
	)
	,churn_cust
AS (
	SELECT churn_count
		,(
			churn_count / CONVERT(FLOAT, (
					SELECT COUNT(DISTINCT customer_id)
					FROM foodie_fi.subscriptions
					)) * 100
			) AS churn_percent
	FROM cte
	)
SELECT churn_count
	,CONCAT (
		ROUND(churn_percent, 1)
		,'%'
		) AS [percentage]
FROM churn_cust;
/*
	churn_count            percentage
	---------------------- ------------------------
	307                    30.7%
*/
--
--	5. How many customers have churned straight after their initial free trial 
--		- what percentage is this rounded to the nearest whole number?
WITH cte
AS (
	SELECT p.plan_name
		,LEAD(p.plan_name) OVER (
			PARTITION BY s.customer_id ORDER BY s.[start_date]
			) AS next_plan
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	)
	,churn
AS (
	SELECT CONVERT(FLOAT, COUNT(*)) AS churned
	FROM cte
	WHERE plan_name LIKE 'trial'
		AND next_plan LIKE 'churn'
	)
	,calc
AS (
	SELECT churned
		,(
			churned / CONVERT(FLOAT, (
					SELECT COUNT(DISTINCT customer_id)
					FROM foodie_fi.subscriptions
					)) * 100
			) AS tc_percentage
	FROM churn
	)
SELECT churned
	,CONCAT (
		ROUND(tc_percentage, 0)
		,'%'
		) AS [percentage]
FROM calc;
/*
	churned                percentage
	---------------------- ------------------------
	92                     9%
*/
--
--	6. What is the number and percentage of customer plans after their initial free trial?
WITH cte
AS (
	SELECT p.plan_name
		,LEAD(p.plan_id) OVER (
			PARTITION BY s.customer_id ORDER BY s.[start_date]
			) AS next_plan_id
		,LEAD(p.plan_name) OVER (
			PARTITION BY s.customer_id ORDER BY s.[start_date]
			) AS next_plan
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	)
	,plans
AS (
	SELECT next_plan_id
		,next_plan
		,CONVERT(FLOAT, COUNT(*)) AS customers
	FROM cte
	WHERE plan_name LIKE 'trial'
	GROUP BY next_plan_id
		,next_plan
	)
	,calc
AS (
	SELECT next_plan_id
		,next_plan
		,customers
		,ROUND((
				customers / CONVERT(FLOAT, (
						SELECT COUNT(DISTINCT customer_id)
						FROM foodie_fi.subscriptions
						)) * 100
				), 2) AS perc
	FROM plans
	)
SELECT next_plan
	,customers
	,CONCAT (
		perc
		,'%'
		) AS [percentage]
FROM calc
ORDER BY next_plan_id;
/*
	next_plan     customers              percentage
	------------- ---------------------- ------------------------
	basic monthly 546                    54.6%
	pro monthly   325                    32.5%
	pro annual    37                     3.7%
	churn         92                     9.2%
*/
--
--	7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte
AS (
	SELECT p.plan_id
		,p.plan_name
		,CONVERT(FLOAT, COUNT(*)) AS customers
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE s.start_date <= '2020-12-31'
	GROUP BY p.plan_id
		,p.plan_name
	)
	,subs
AS (
	SELECT CONVERT(FLOAT, COUNT(DISTINCT s.customer_id)) AS total
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE s.start_date <= '2020-12-31'
	)
SELECT plan_name
	,customers
	,CONCAT (
		ROUND((
				customers / (
					SELECT total
					FROM subs
					)
				) * 100, 2)
		,'%'
		) AS [percentage]
FROM cte
ORDER BY plan_id;
/*
	plan_name     customers              percentage
	------------- ---------------------- ------------------------
	trial         1000                   100%
	basic monthly 538                    53.8%
	pro monthly   479                    47.9%
	pro annual    195                    19.5%
	churn         236                    23.6%
*/
--
--	8. How many customers have upgraded to an annual plan in 2020?
SELECT p.plan_name
	,COUNT(*) AS customers
FROM foodie_fi.subscriptions AS s
JOIN foodie_fi.plans AS p
	ON s.plan_id = p.plan_id
WHERE p.plan_name LIKE 'pro annual'
	AND DATEPART(YEAR, s.[start_date]) = '2020'
GROUP BY p.plan_name;
/*
	plan_name     customers
	------------- -----------
	pro annual    195
*/
--
--	9.	How many days on average does it take for a customer to an annual plan
--		from the day they join Foodie-Fi?
WITH trial
AS (
	SELECT s.customer_id
		,s.[start_date] AS trial_date
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name LIKE 'trial'
	)
	,pro
AS (
	SELECT s.customer_id
		,s.[start_date] AS pro_date
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name LIKE 'pro annual'
	)
SELECT AVG(DATEDIFF(DAY, t.trial_date, p.pro_date)) AS average_days
FROM trial AS t
JOIN pro AS p
	ON t.customer_id = p.customer_id;
/*
	average_days
	------------
	104
*/
--
--	10. Can you further breakdown this average value into 30 day periods 
--		(i.e. 0-30 days, 31-60 days etc)
WITH trial
AS (
	SELECT s.customer_id
		,s.[start_date] AS trial_date
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name LIKE 'trial'
	)
	,pro
AS (
	SELECT s.customer_id
		,s.[start_date] AS pro_date
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	WHERE p.plan_name LIKE 'pro annual'
	)
	,calc
AS (
	SELECT DATEDIFF(DAY, t.trial_date, p.pro_date) AS diff
	FROM trial AS t
	JOIN pro AS p
		ON t.customer_id = p.customer_id
	)
	,bins
AS (
	SELECT diff
		,CASE 
			WHEN diff BETWEEN 0
					AND 30
				THEN '0-30'
			WHEN diff BETWEEN 31
					AND 60
				THEN '30-60'
			WHEN diff BETWEEN 61
					AND 90
				THEN '60-90'
			WHEN diff BETWEEN 91
					AND 120
				THEN '90-120'
			WHEN diff BETWEEN 121
					AND 150
				THEN '120-150'
			WHEN diff BETWEEN 151
					AND 180
				THEN '150-180'
			WHEN diff BETWEEN 181
					AND 210
				THEN '180-210'
			WHEN diff BETWEEN 211
					AND 240
				THEN '210-240'
			WHEN diff BETWEEN 241
					AND 270
				THEN '240-270'
			WHEN diff BETWEEN 271
					AND 300
				THEN '270-300'
			WHEN diff BETWEEN 301
					AND 330
				THEN '300-330'
			ELSE '330-360'
			END AS dd
	FROM calc
	)
SELECT CONCAT (
		dd
		,' days'
		) AS days_range
	,COUNT(*) AS [count]
FROM bins
GROUP BY dd
ORDER BY CASE 
		WHEN dd = '0-30'
			THEN 0
		WHEN dd = '30-60'
			THEN 1
		WHEN dd = '60-90'
			THEN 2
		WHEN dd = '90-120'
			THEN 3
		WHEN dd = '120-150'
			THEN 4
		WHEN dd = '150-180'
			THEN 5
		WHEN dd = '180-210'
			THEN 6
		WHEN dd = '210-240'
			THEN 7
		WHEN dd = '240-270'
			THEN 8
		WHEN dd = '270-300'
			THEN 9
		WHEN dd = '300-330'
			THEN 10
		ELSE 11
		END;
/*
	days_range   count
	------------ -----------
	0-30 days    49
	30-60 days   24
	60-90 days   34
	90-120 days  35
	120-150 days 42
	150-180 days 36
	180-210 days 26
	210-240 days 4
	240-270 days 5
	270-300 days 1
	300-330 days 1
	330-360 days 1
*/
--
--	11. How many customers downgraded from a pro monthly 
--		to a basic monthly plan in 2020?
WITH cte
AS (
	SELECT s.customer_id
		,s.[start_date]
		,p.plan_name
		,LEAD(p.plan_name) OVER (
			PARTITION BY s.customer_id ORDER BY s.[start_date]
			) AS next_plan
	FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
		ON s.plan_id = p.plan_id
	)
SELECT COUNT(*) AS customers
FROM cte
WHERE plan_name LIKE 'pro monthly'
	AND next_plan LIKE 'basic monthly';
/*
	customers
	-----------
	0
*/
