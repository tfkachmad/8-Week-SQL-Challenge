USE EightWeekSQLChallenge;
--
/*
	========	A. PIZZA METRICS	========
*/
--
--	1.	How many pizzas were ordered?
SELECT COUNT(*) AS total_order
FROM ##customer_orders_cleaned;
/*
	total_order
	-----------
	14
*/
--
--	2.	How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_orders
FROM ##customer_orders_cleaned;
/*
	unique_orders
	-------------
	5
*/
--
--	3.	How many successful orders were delivered by each runner?
SELECT runner_id
	,COUNT(pickup_time) AS succesful_order
FROM ##runner_orders_cleaned
GROUP BY runner_id;
/*
	runner_id   succesful_order
	----------- ---------------
	1           4
	2           3
	3           1
*/
--
--	4.	How many of each type of pizza was delivered?
SELECT pizza.pizza_name
	,Count(*) AS num_delivered
FROM ##customer_orders_cleaned AS customer
JOIN ##pizza_names_cleaned AS pizza
	ON customer.pizza_id = pizza.pizza_id
GROUP BY pizza.pizza_name;
/*
	pizza_name           num_delivered
	-------------------- -------------
	Meatlovers           10
	Vegetarian           4
*/
--
--	5.	How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id
	,COUNT(CASE
			WHEN pizza.pizza_name LIKE 'Meatlovers'
				THEN 1
			ELSE NULL
			END) AS Meatlovers
	,COUNT(CASE
			WHEN pizza.pizza_name LIKE 'Vegetarian'
				THEN 1
			ELSE NULL
			END) AS Vegetarian
FROM ##customer_orders_cleaned AS orders
JOIN ##pizza_names_cleaned AS pizza
	ON orders.pizza_id = pizza.pizza_id
GROUP BY orders.customer_id;
/*
	customer_id Meatlovers  Vegetarian
	----------- ----------- -----------
	101         2           1
	102         2           1
	103         3           1
	104         3           0
	105         0           1
*/
--
--	6.	What was the maximum number of pizzas delivered in a single order?
SELECT MAX(num_pizza) AS max_pizza_delivered
FROM (
	SELECT order_id
		,COUNT(*) AS num_pizza
	FROM ##customer_orders_cleaned
	GROUP BY order_id
	) AS pizza_count;
/*
	max_pizza_delivered
	-------------------
	3
*/
--
--	7.	For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer.customer_id
	,COUNT(CASE
			WHEN (
					customer.exclusions IS NULL
					AND customer.extras IS NOT NULL
					)
				OR (
					customer.exclusions IS NOT NULL
					AND customer.extras IS NULL
					)
				OR (
					customer.exclusions IS NOT NULL
					AND customer.extras IS NOT NULL
					)
				THEN 1
			ELSE NULL
			END) AS pizza_had_change
	,COUNT(CASE
			WHEN customer.exclusions IS NULL
				AND customer.extras IS NULL
				THEN 1
			ELSE NULL
			END) AS pizza_had_no_change
FROM ##customer_orders_cleaned AS customer
JOIN pizza_runner.runner_orders AS runner
	ON customer.order_id = runner.order_id
GROUP BY customer.customer_id;
/*
	customer_id pizza_had_change pizza_had_no_change
	----------- ---------------- -------------------
	101         0                3
	102         0                3
	103         4                0
	104         2                1
	105         1                0
*/
--
--	8.	How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS pizza_with_exclusions_extras
FROM ##customer_orders_cleaned AS customer
JOIN ##runner_orders_cleaned AS runner
	ON customer.order_id = runner.order_id
WHERE exclusions IS NOT NULL
	AND extras IS NOT NULL;
/*
	pizza_with_exclusions_extras
	----------------------------
	2
*/
--
--	9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(DAY, order_time) AS [day]
	,DATEPART(hour, order_time) AS [hour]
	,Count(*) AS pizza_orderred
FROM ##customer_orders_cleaned
GROUP BY DATEPART(DAY, order_time)
	,DATEPART(hour, order_time)
ORDER BY 1;
/*
	day         hour        pizza_orderred
	----------- ----------- --------------
	1           18          1
	1           19          1
	2           23          2
	4           13          3
	8           21          3
	9           23          1
	10          11          1
	11          18          2
*/
--
--	10.	What was the volume of orders for each day of the week?
SELECT DATEPART(WEEK, order_time) AS [week]
	,DATEPART(DAY, order_time) AS [day]
	,COUNT(*) AS pizza_orderred
FROM ##customer_orders_cleaned
GROUP BY DATEPART(Week, order_time)
	,DATEPART(Day, order_time)
ORDER BY 1;
	/*
	week        day         pizza_orderred
	----------- ----------- --------------
	1           1           2
	1           2           2
	1           4           3
	2           8           3
	2           9           1
	2           10          1
	2           11          2
*/
