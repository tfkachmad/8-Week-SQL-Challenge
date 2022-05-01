USE EightWeekSQLChallenge;
--
/*
	========	D. PRICING AND RATINGS	========
*/
--
--	1.	If a Meat Lovers pizza costs $12 and
--		Vegetarian costs $10 and there were no charges for changes
--		- how much money has Pizza Runner made so far if there are no delivery fees?
-- Create #pizza_price table
DROP TABLE
IF EXISTS #pizza_price;
	CREATE TABLE #pizza_price (
		"pizza_id" INTEGER
		,"pizza_price" INTEGER
		);
INSERT INTO #pizza_price (
	"pizza_id"
	,"pizza_price"
	)
VALUES (
	1
	,12
	)
	,(
	2
	,10
	);
SELECT CONCAT (
		'$'
		,SUM(pizza_price)
		) AS pizza_runner_profit
FROM ##customer_orders_cleaned AS ord
JOIN pizza_runner.pizza_price AS pri
	ON ord.pizza_id = pri.pizza_id;
/*
	pizza_runner_profit
	-------------------
	$160
*/
--
--	2.	What if there was an additional $1 charge for any pizza extras?
--		- Add cheese is $1 extra
-- Find how much total profit without any extras
WITH pizza_profit
AS (
	SELECT SUM(pizza_price) AS pizza_runner_profit
	FROM ##customer_orders_cleaned AS ord
	JOIN #pizza_price AS pri
		ON ord.pizza_id = pri.pizza_id
	)
	,
	-- Reshape the extras column from comma delimited to array
extras_profit
AS (
	SELECT COUNT(*) AS cheese
	FROM ##customer_orders_cleaned AS ord
	CROSS APPLY STRING_SPLIT(ord.extras, ',')
	JOIN ##pizza_toppings_cleaned AS topp
		ON topp.topping_id = [value]
	WHERE topp.topping_name LIKE 'Cheese'
	)
SELECT FORMAT(pizza_runner_profit + (
			SELECT cheese
			FROM extras_profit
			), 'c0') AS total_profit_extra
FROM pizza_profit;
/*
	total_profit_extra
	--------------------
	$161
*/
--
--	3. The Pizza Runner team now wants to add an additional ratings system
--		that allows customers to rate their runner, how would you design an
--		additional table for this new dataset - generate a schema for this
--		new table and insert your own data for ratings for each successful
--		customer order between 1 to 5.
-- Create table order_rating;
DROP TABLE
IF EXISTS pizza_runner.order_rating;
	CREATE TABLE pizza_runner.order_rating (
		"order_id" INTEGER
		,"rating" INTEGER
		);
--
-- CTE to find each order_id
WITH orders
AS (
	SELECT DISTINCT order_id
	FROM ##customer_orders_cleaned
	)
	--
	-- CTE to find order_id from order that is not cancelled
	-- and add random rating from 1-5
	,finished_order
AS (
	SELECT order_id
		,ABS(CHECKSUM(NEWID())) % 5 + 1 AS rating
	FROM ##runner_orders_cleaned
	WHERE cancellation IS NULL
	)
--
-- Insert the CTEs result to the order_rating table
INSERT INTO pizza_runner.order_rating
SELECT o.order_id
	,fo.rating
FROM orders AS o
LEFT JOIN finished_order AS fo
	ON o.order_id = fo.order_id
--
-- The resulted new order_rating table
SELECT *
FROM pizza_runner.order_rating;
/*
	order_id    rating
	----------- -----------
	1           5
	2           2
	3           2
	4           4
	5           2
	6           NULL
	7           3
	8           4
	9           NULL
	10          4
*/
--
--	4.	Using your newly generated table - can you join all of the
--		information together to form a table which has the following
--		information for successful deliveries?
--			-	customer_id
--			-	order_id
--			-	runner_id
--			-	rating
--			-	order_time
--			-	pickup_time
--			-	Time between order and pickup
--			-	Delivery duration
--			-	Average speed
--			-	Total number of pizzas
DROP TABLE
IF EXISTS pizza_runner.successful_orders;
	CREATE TABLE pizza_runner.successful_orders (
		"customer_id" INTEGER
		,"order_id" INTEGER
		,"runner_id" INTEGER
		,"rating" INTEGER
		,"order_time" DATETIME
		,"pickup_time" DATETIME
		,"time_between_order_and_pickup" INTEGER -- In minutes
		,"delivery_duration" INTEGER -- In minutes
		,"average_speed" DECIMAL(4, 2) -- In kmph
		,"total_pizzas" INTEGER
		);
WITH deliveries
AS (
	SELECT ord.customer_id
		,ord.order_id
		,run.runner_id
		,rat.rating
		,ord.order_time
		,run.pickup_time
		,DATEDIFF(MINUTE, ord.order_time, run.pickup_time) AS time_between_order_and_pickup
		,run.duration
		,ROUND(run.distance / (CONVERT(FLOAT, (run.duration)) / 60), 2) AS average_speed
	FROM ##customer_orders_cleaned AS ord
	JOIN ##runner_orders_cleaned AS run
		ON ord.order_id = run.order_id
			AND run.cancellation IS NULL
	JOIN pizza_runner.order_rating AS rat
		ON ord.order_id = rat.order_id
	)
INSERT INTO pizza_runner.successful_orders
SELECT customer_id
	,order_id
	,runner_id
	,rating
	,order_time
	,pickup_time
	,time_between_order_and_pickup
	,duration
	,average_speed
	,COUNT(*) AS total_pizzas
FROM deliveries
GROUP BY customer_id
	,order_id
	,runner_id
	,rating
	,order_time
	,pickup_time
	,time_between_order_and_pickup
	,duration
	,average_speed;
--
SELECT *
FROM pizza_runner.successful_orders;
/*
	customer_id order_id    runner_id   rating      order_time              pickup_time             Time_between_order_and_pickup Delivery_duration      Average_speed          Total_pizzas
	----------- ----------- ----------- ----------- ----------------------- ----------------------- ----------------------------- ---------------------- ---------------------- ------------
	101         1           1           5           2020-01-01 18:05:02.000 2020-01-01 18:15:34.000 1900-01-01 00:00:00.000       32                     37.5                   1
	101         2           1           5           2020-01-01 19:00:52.000 2020-01-01 19:10:54.000 1900-01-01 00:00:00.000       27                     44.44                  1
	102         3           1           4           2020-01-02 23:51:23.000 2020-01-03 00:12:37.000 1900-01-01 00:00:00.000       20                     40.2                   2
	102         8           2           5           2020-01-09 23:54:33.000 2020-01-10 00:15:02.000 1900-01-01 00:00:00.000       15                     93.6                   1
	103         4           2           5           2020-01-04 13:23:46.000 2020-01-04 13:53:03.000 1900-01-01 00:00:00.000       40                     35.1                   3
	104         5           3           3           2020-01-08 21:00:29.000 2020-01-08 21:10:57.000 1900-01-01 00:00:00.000       15                     40                     1
	104         10          1           4           2020-01-11 18:34:49.000 2020-01-11 18:50:20.000 1900-01-01 00:00:00.000       10                     60                     2
	105         7           2           4           2020-01-08 21:20:29.000 2020-01-08 21:30:45.000 1900-01-01 00:00:00.000       25                     60                     1
*/
--
--	5.	If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices
--		with no cost for extras and each runner is paid $0.30 per kilometre
--		traveled - how much money does Pizza Runner have left over after these deliveries?
--
-- CTE to find the Pizza Runner total profit
WITH pizza_profit
AS (
	SELECT SUM(pizza_price) AS pizza_runner_profit
	FROM ##customer_orders_cleaned AS ord
	JOIN #pizza_price AS pri
		ON ord.pizza_id = pri.pizza_id
	)
--
-- CTE to find the payment for each kilometre a runner traveled
	,runner_paid
AS (
	SELECT (SUM(distance) * 0.3) AS runner_pay
	FROM ##runner_orders_cleaned
	WHERE cancellation IS NULL
	)
--
-- Present the result
SELECT CONCAT (
		'$'
		,(
			pizza_runner_profit - (
				SELECT runner_pay
				FROM runner_paid
				)
			)
		) AS pizza_runner_net_profit
FROM pizza_profit;
/*
	pizza_runner_net_profit
	-------------------------
	$116.44
*/
