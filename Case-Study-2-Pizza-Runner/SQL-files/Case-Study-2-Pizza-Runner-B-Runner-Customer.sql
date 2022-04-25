USE EightWeekSQLChallenge;
--
/*
	========	B. RUNNER AND CUSTOMER EXPERIENCE	========
*/
--
--	1.	How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEPART(week, registration_date) AS [week]
	,Count(*) AS runner_signup
FROM pizza_runner.runners
GROUP BY DATEPART(week, registration_date);
/*
	week        runner_signup
	----------- -------------
	1           1
	2           2
	3           1
*/
--
--	2.	What was the average time in minutes it took for each runner
--		to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id
	,AVG(DatePart(MINUTE, pickup_time)) AS avg_duration_minute
FROM ##runner_orders_cleaned
GROUP BY runner_id;
/*
		runner_id   avg_duration_minute
	----------- -------------------
	1           21
	2           32
	3           10
*/
--
--	3.	Is there any relationship between the number of pizzas
--		and how long the order takes to prepare?
SELECT COUNT(*) AS pizza_ordered
	,DATEDIFF(MINUTE, order_time, pickup_time) AS prep_time_minute
FROM ##customer_orders_cleaned AS customer
JOIN ##runner_orders_cleaned AS runner
	ON customer.order_id = runner.order_id
		AND cancellation IS NULL
GROUP BY customer.order_id
	,DATEDIFF(MINUTE, order_time, pickup_time)
ORDER BY 1 DESC
	,2 DESC;
/*
	pizza_ordered prep_time_minute
	------------- ----------------
	3             30
	2             21
	2             16
	1             21
	1             10
	1             10
	1             10
	1             10
*/
--
--	4.	What was the average distance travelled for each customer?
SELECT customer.customer_id
	,CONVERT(DECIMAL(4, 2), AVG(distance)) AS avg_distance_km
FROM ##customer_orders_cleaned AS customer
JOIN ##runner_orders_cleaned AS runner
	ON customer.order_id = runner.order_id
		AND cancellation IS NULL
GROUP BY customer.customer_id;
/*
	customer_id avg_distance_km
	----------- ----------------
	101         20.00
	102         16.73
	103         23.40
	104         10.00
	105         25.00
*/
--
--	5.	What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(distance) - MIN(distance) AS distance_difference_km
FROM ##runner_orders_cleaned
WHERE cancellation IS NULL;
/*
	distance_difference_km
	----------------------
	15
*/
--
--	6.	What was the average speed for each runner for each delivery
--		and do you notice any trend for these values?
SELECT runner_id
	,CONVERT(DECIMAL(4, 2), AVG((distance / duration) * 60)) AS avg_speed_kmph
FROM ##runner_orders_cleaned
WHERE cancellation IS NULL
GROUP BY runner_id;
/*
	runner_id   avg_speed_kmph
	----------- ----------------
	1           45.54
	2           62.90
	3           40.00
*/
--
--	7.	What is the successful delivery percentage for each runner?
WITH delivery
AS (
	SELECT s_delivery.runner_id
		,COALESCE(success, 0) AS success
		,COALESCE(failed, 0) AS failed
	FROM (
		SELECT runner_id
			,CONVERT(FLOAT, COUNT(*)) AS success
		FROM ##runner_orders_cleaned
		WHERE cancellation IS NULL
		GROUP BY runner_id
		) AS s_delivery
	LEFT JOIN (
		SELECT runner_id
			,CONVERT(FLOAT, COUNT(*)) AS failed
		FROM ##runner_orders_cleaned
		WHERE cancellation IS NOT NULL
		GROUP BY runner_id
		) AS u_delivery
		ON s_delivery.runner_id = u_delivery.runner_id
	)
SELECT runner_id
	,FORMAT((success / (success + failed)), 'p0') AS successful_delivery
FROM delivery
ORDER BY runner_id;
/*
	runner_id   successful_delivery
	----------- --------------------
	1           100%
	2           75%
	3           50%
*/
