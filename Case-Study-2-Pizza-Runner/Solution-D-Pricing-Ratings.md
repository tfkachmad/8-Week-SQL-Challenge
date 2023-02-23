# :pizza: Case Study 2 - Pizza Runner: Solution D. Pricing and Ratings

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

    Query:

    ```sql
    SELECT
        SUM(
            CASE WHEN p.pizza_name = 'Meatlovers' THEN
                12
            ELSE
                10
            END) AS profit_total
    FROM
        pizza_runner.customer_orders_clean AS c
        JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id;
    ```

    Output:

    | "profit_total" |
    |----------------|
    | 160            |

    <br>

2. What if there was an additional $1 charge for any pizza extras?
    1. Add cheese is $1 extra

    Query:

    ```sql
    WITH cheese_topping_id AS (
        SELECT
            topping_id
        FROM
            pizza_runner.pizza_toppings
        WHERE
            topping_name = 'Cheese'
    ),
    pizza_prices AS (
        SELECT
            CASE WHEN p.pizza_name = 'Meatlovers' THEN
                12
            ELSE
                10
            END AS pizza_price,
            CASE WHEN POSITION((
                SELECT
                    topping_id
                FROM cheese_topping_id)::TEXT IN c.extras::TEXT) > 0 THEN
                TRUE
            ELSE
                FALSE
            END AS is_cheese
        FROM
            pizza_runner.customer_orders_clean AS c
            JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
    )
    SELECT
        SUM(
            CASE WHEN is_cheese THEN
                pizza_price + 1
            ELSE
                pizza_price
            END) AS profit_total
    FROM
        pizza_prices;
    ```

    Output:

    | "profit_total" |
    |----------------|
    | 161            |

    <br>

3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

    Query:

    ```sql
    SET search_path = pizza_runner;

    DROP TABLE IF EXISTS ratings;

    CREATE TABLE ratings (
        order_id INTEGER,
        rating INTEGER
    );

    INSERT INTO pizza_runner.ratings
    SELECT
        order_id,
        FLOOR(RANDOM() * (5) + 1) AS order_rating
    FROM ( SELECT DISTINCT
            order_id
        FROM
            pizza_runner.customer_orders_clean
        WHERE
            order_id IN (
                SELECT
                    order_id
                FROM
                    pizza_runner.runner_orders_clean
                WHERE
                    cancellation IS NULL)) AS orders;

    SELECT
        *
    FROM
        pizza_runner.ratings;
    ```

    Output:

    | "order_id" | "rating" |
    |------------|----------|
    | 1          | 5        |
    | 2          | 3        |
    | 3          | 5        |
    | 4          | 4        |
    | 5          | 2        |
    | 7          | 3        |
    | 8          | 3        |
    | 10         | 5        |

    <br>

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

    Query:

    ```sql
    SET search_path = pizza_runner;

    DROP TABLE IF EXISTS orders_detail;

    CREATE TABLE orders_detail (
        customer_id INTEGER,
        order_id INTEGER,
        runner_id INTEGER,
        rating INTEGER,
        order_time TIMESTAMP,
        pickup_time TIMESTAMP,
        order_pickup_diff INTEGER,
        duration INTEGER,
        speed_kmh FLOAT,
        pizza_total INTEGER
    );

    INSERT INTO orders_detail WITH orders AS (
        SELECT
            order_id,
            customer_id,
            order_time,
            COUNT(order_id) AS pizza_total
        FROM
            pizza_runner.customer_orders_clean
        GROUP BY
            order_id,
            customer_id,
            order_time
    ),
    runners AS (
        SELECT
            order_id,
            runner_id,
            pickup_time,
            duration,
            ROUND((distance / (duration::NUMERIC / 60))::NUMERIC, 2) AS speed_kmh
        FROM
            pizza_runner.runner_orders_clean
        WHERE
            cancellation IS NULL
    )
    SELECT
        o.order_id,
        o.customer_id,
        r1.runner_id,
        r2.rating,
        o.order_time,
        r1.pickup_time,
        DATE_PART('hour', r1.pickup_time - o.order_time) * 60 + DATE_PART('minute', r1.pickup_time - o.order_time) AS order_pickup_diff_time,
        r1.duration,
        r1.speed_kmh,
        o.pizza_total
    FROM
        orders AS o
        JOIN runners AS r1 ON o.order_id = r1.order_id
        JOIN pizza_runner.ratings AS r2 ON o.order_id = r2.order_id;

    SELECT
        *
    FROM
        orders_detail;
    ```

    Output:

    | "customer_id" | "order_id" | "runner_id" | "rating" | "order_time"        | "pickup_time"       | "order_pickup_diff" | "duration" | "speed_kmh" | "pizza_total" |
    |---------------|------------|-------------|----------|---------------------|---------------------|---------------------|------------|-------------|---------------|
    | 1             | 101        | 1           | 5        | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 10                  | 32         | 37.5        | 1             |
    | 2             | 101        | 1           | 3        | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 | 10                  | 27         | 44.44       | 1             |
    | 3             | 102        | 1           | 5        | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 | 21                  | 20         | 40.2        | 2             |
    | 4             | 103        | 2           | 4        | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 | 29                  | 40         | 35.1        | 3             |
    | 5             | 104        | 3           | 2        | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 | 10                  | 15         | 40          | 1             |
    | 7             | 105        | 2           | 3        | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 | 10                  | 25         | 60          | 1             |
    | 8             | 102        | 2           | 3        | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 | 20                  | 15         | 93.6        | 1             |
    | 10            | 104        | 1           | 5        | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 | 15                  | 10         | 60          | 2             |

    <br>

5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

    Query:

    ```sql
    WITH pizza_price AS (
        SELECT
            c.order_id,
            p.pizza_name,
            SUM(
                CASE WHEN p.pizza_name = 'Meatlovers' THEN
                    12
                ELSE
                    10
                END) AS price_total
        FROM
            pizza_runner.customer_orders_clean AS c
            JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
        GROUP BY
            c.order_id,
            p.pizza_name
    ),
    revenue AS (
        SELECT
            order_id,
            SUM(price_total) AS total_revenue
        FROM
            pizza_price
        GROUP BY
            1
    )
    SELECT
        SUM(r2.total_revenue - (r1.distance * 0.3)::NUMERIC) AS profit_total
    FROM
        runner_orders_clean AS r1
        JOIN revenue AS r2 ON r1.order_id = r2.order_id
    WHERE
        r1.cancellation IS NULL;
    ```

    Output:

    | "profit_total" |
    |----------------|
    | 94.44          |
