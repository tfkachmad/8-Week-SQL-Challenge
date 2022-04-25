USE EightWeekSQLChallenge;
--
/*
	========	DATA CLEANING	========
*/
--
--	----------------------------------------------
--	Cleaning data in the customer_orders table
--	----------------------------------------------
DROP TABLE
IF EXISTS ##customer_orders_cleaned;
	SELECT order_id
		,customer_id
		,pizza_id
		-- Fixing inconsistent NULL in the exclusions column
		,CASE
			WHEN exclusions = ''
				THEN NULL
			WHEN exclusions = 'null'
				THEN NULL
			ELSE exclusions
			END AS exclusions
		-- Fixing inconsistent NULL in the extras column
		,CASE
			WHEN extras = ''
				THEN NULL
			WHEN extras = 'null'
				THEN NULL
			ELSE extras
			END AS extras
		,order_time
		,ROW_NUMBER() OVER (
			ORDER BY order_time
			) AS order_row
	INTO ##customer_orders_cleaned
	FROM pizza_runner.customer_orders;
--
--	----------------------------------------------
--	Cleaning data in the runner_orders table
--	----------------------------------------------
DROP TABLE
IF EXISTS ##runner_orders_cleaned;
	SELECT order_id
		,runner_id
		-- Fixing inconsistent NULL in the pickup_time column
		,CASE
			WHEN pickup_time = 'null'
				THEN NULL
			ELSE pickup_time
			END AS pickup_time
		-- Fixing inconsistent values and NULL in the distance column
		,CASE
			WHEN distance = 'null'
				THEN NULL
			ELSE Convert(FLOAT, Trim(Replace(distance, 'km', '')))
			END AS distance
		-- Fixing inconsistent values and NULL in the duration column
		,CASE
			WHEN duration = 'null'
				THEN NULL
			ELSE Convert(INT, Trim(Replace(Replace(Replace(duration, 'minutes', ''), 'minute', ''), 'mins', '')))
			END AS duration
		,CASE
			WHEN cancellation = 'null'
				THEN NULL
			WHEN cancellation = ''
				THEN NULL
			WHEN cancellation IS NULL
				THEN NULL
			ELSE cancellation
			END AS cancellation
	INTO ##runner_orders_cleaned
	FROM pizza_runner.runner_orders;
--
--	----------------------------------------------
--	Cleaning data in the pizza_recipes table
--	----------------------------------------------
DROP TABLE
IF EXISTS ##pizza_recipes_cleaned;
	SELECT pizza_id
		,TRIM(value) AS toppings
	INTO ##pizza_recipes_cleaned
	FROM pizza_runner.pizza_recipes
	CROSS APPLY STRING_SPLIT(CONVERT(VARCHAR, toppings), ',');
--
-- ----------------------------------------------
-- Cleaning data in the pizza_names table
-- ----------------------------------------------
DROP TABLE
IF EXISTS ##pizza_names_cleaned;
	SELECT pizza_id
		,CONVERT(VARCHAR(20), pizza_name) AS pizza_name
	INTO ##pizza_names_cleaned
	FROM pizza_runner.pizza_names;
--
--	----------------------------------------------
--	Cleaning data in the pizza_toppings table
--	----------------------------------------------
DROP TABLE
IF EXISTS ##pizza_toppings_cleaned;
	SELECT topping_id
		,CONVERT(VARCHAR(20), topping_name) AS topping_name
	INTO ##pizza_toppings_cleaned
	FROM pizza_runner.pizza_toppings;