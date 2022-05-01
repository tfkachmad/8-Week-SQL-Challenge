# :pizza: Case Study 2 - Pizza Runner: Solution D. Pricing and Ratings

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

    - First, create a temp table called `#pizza_price` to list the `pizza_id` and `pizza_price` for each pizza type.
    - Join that table with ##customer_orders_cleaned to get every pizza ordered by customer.
    - Sum the price for each pizza ordered to get the profit.

    Code:

    ```sql
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
    VALUES (1, 12), (2, 10);

    SELECT CONCAT (
            '$'
            ,SUM(pizza_price)
            ) AS pizza_runner_profit
    FROM ##customer_orders_cleaned AS ord
    JOIN pizza_runner.pizza_price AS pri
        ON ord.pizza_id = pri.pizza_id;
    ```

    Output:

    | pizza_runner_profit |
    | ------------------- |
    | $160                |

    <br/>

2. What if there was an additional $1 charge for any pizza extras?
    1. Add cheese is $1 extra

    <br/>

    - Use the first question solution to get the profit without additional charge.
    - Create a CTE to find every pizza ever ordered with extras cheese as topping and count how many they are.
    - Add the result from the two calculation to get the final profit.

    Code:

    ```sql
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
    ```

    Output:

    | total_profit_extra |
    | ------------------ |
    | $161               |

    <br/>

3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

    - Create a table called `order_rating` that going to have the `order_id` and the rating for each order, called `rating`.
    - Create two CTEs, first is to list each `order_id`, and the second is to list `order_id` that is not cancelled from `##runner_orders_cleaned` table.
    - `NEWID()` function will be used to generate a random value for rating. This function will return unique identifier  for each row. To convert this unique identifier, `CHECKSUM()` is used to convert it to has values. `ABS()` function then used to get the absolute value for each row. Because the result are in number alread, using module to find the value between 1-5 would be easy. For example,

        | NEWID()                              | CHECKSUM(NEWID()) | ABS(CHECKSUM(NEWID())) | result |
        |--------------------------------------|-------------------|------------------------|--------|
        | 94DB3937-B6FC-4325-BB0B-C547341945FC | -241619032        | 1919080594             | 5      |
        | F5A78CFF-DBF5-4FAE-81BD-761D4C943DAE | 846595227         | 1758390899             | 2      |
        | C5BF36CB-37D3-41D2-AEDE-784EDBDA09D4 | -1645500195       | 1770336580             | 2      |
        | EF41EE3F-E8A1-4B7E-B31D-F6E694F1057C | 1315382460        | 580687439              | 4      |

    - `LEFT JOIN` the first CTE and the second one to get the final table.

    Code:

    ```sql
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

    ```

    Output:

    | order_id | rating |
    |----------|--------|
    | 1        | 5      |
    | 2        | 2      |
    | 3        | 2      |
    | 4        | 4      |
    | 5        | 2      |
    | 6        | NULL   |
    | 7        | 3      |
    | 8        | 4      |
    | 9        | NULL   |
    | 10       | 4      |

    <br/>

4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    1. `customer_id`
    2. `order_id`
    3. `runner_id`
    4. `rating`
    5. `order_time`
    6. `pickup_time`
    7. Time between order and pickup
    8. Delivery duration
    9. Average speed
    10. Total number of pizzas

    <br/>

    - `customer_id`, `order_id`, `runner_id`, `rating`, `order_time`, `delivery_duration` and `pickup_time` can be obtained by joining the `##customer_orders_cleaned`, `##runner_orders_cleaned` and `order_rating` table based on the `order_id`.
    - `time_between_order_and_pickup` can be obtained using this formula, `DATEDIFF(MINUTE, ord.order_time, run.pickup_time)`.
    - average_speed can be obtained with this formula, `ROUND(run.distance / (CONVERT(FLOAT, (run.duration)) / 60), 2)` that devide the distance traveled by each runner and the duration they take to deliver the pizza. The resulting formula would be in *kmph* and rounded to two decimal format.
    - The last step is to count the pizza for each `order_id` by basically group all columns that already obtained before.

    Code:

    ```sql
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
    ```

    Output:

    | customer_id | order_id | runner_id | rating | order_time              | pickup_time             | time_between_order_and_pickup | delivery_duration | average_speed | total_pizzas |
    | ----------- | -------- | --------- | ------ | ----------------------- | ----------------------- | ----------------------------- | ----------------- | ------------- | ------------ |
    | 101         | 1        | 1         | 5      | 2020-01-01 18:05:02.000 | 2020-01-01 18:15:34.000 | 10                            | 32                | 37.50         | 1            |
    | 101         | 2        | 1         | 2      | 2020-01-01 19:00:52.000 | 2020-01-01 19:10:54.000 | 10                            | 27                | 44.44         | 1            |
    | 102         | 3        | 1         | 2      | 2020-01-02 23:51:23.000 | 2020-01-03 00:12:37.000 | 21                            | 20                | 40.20         | 2            |
    | 102         | 8        | 2         | 4      | 2020-01-09 23:54:33.000 | 2020-01-10 00:15:02.000 | 21                            | 15                | 93.60         | 1            |
    | 103         | 4        | 2         | 2      | 2020-01-04 13:23:46.000 | 2020-01-04 13:53:03.000 | 30                            | 40                | 35.10         | 3            |
    | 104         | 5        | 3         | 3      | 2020-01-08 21:00:29.000 | 2020-01-08 21:10:57.000 | 10                            | 15                | 40.00         | 1            |
    | 104         | 10       | 1         | 4      | 2020-01-11 18:34:49.000 | 2020-01-11 18:50:20.000 | 16                            | 10                | 60.00         | 2            |
    | 105         | 7        | 2         | 4      | 2020-01-08 21:20:29.000 | 2020-01-08 21:30:45.000 | 10                            | 25                | 60.00         | 1            |

    <br/>

5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

    - First, find the profit like the first question on this part.
    - Next, use this formula to get the paid for each runner `(SUM(distance) * 0.3)` for every kilometre they traveled.
    - Substract the result from the first calculation to get the net profit Pizza Runner made.

    Code:

    ```sql
    WITH pizza_profit
    AS (
        SELECT SUM(pizza_price) AS pizza_runner_profit
        FROM ##customer_orders_cleaned AS ord
        JOIN #pizza_price AS pri
            ON ord.pizza_id = pri.pizza_id
        )
        ,runner_paid
    AS (
        SELECT (SUM(distance) * 0.3) AS runner_pay
        FROM ##runner_orders_cleaned
        WHERE cancellation IS NULL
        )
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
    ```

    Output:

    | pizza_runner_net_profit |
    | ----------------------- |
    | $116.44                 |
