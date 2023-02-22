# :pizza: Case Study 2 - Pizza Runner: Solution B. Runner and Customer Experience

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

    Query:

    ```sql
    SELECT
        TO_CHAR(registration_date, 'ww')::INT AS week_number,
        COUNT(runner_id) AS runners_total
    FROM
        pizza_runner.runners
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "week_number" | "runners_total" |
    |---------------|-----------------|
    | 1             | 2               |
    | 2             | 1               |
    | 3             | 1               |

    <br>

2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

    Query:

    ```sql
    SELECT
        r.runner_id,
        ROUND(AVG(EXTRACT('epoch' FROM r.pickup_time - c.order_time) / 60)::NUMERIC, 1) AS time_to_pickup_order_average
    FROM
        pizza_runner.customer_orders_clean AS c
        JOIN pizza_runner.runner_orders_clean AS r ON c.order_id = r.order_id
    WHERE
        r.cancellation IS NULL
    GROUP BY
        1;
    ```

    Output:

    | "runner_id" | "time_to_pickup_order_average" |
    |-------------|--------------------------------|
    | 1           | 15.7                           |
    | 2           | 23.7                           |
    | 3           | 10.5                           |

    <br>

3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

    Query:

    ```sql
    WITH orders_prep_time AS (
        SELECT
            c.order_id,
            COUNT(c.order_id) AS pizza_num,
            AVG(EXTRACT('epoch' FROM r.pickup_time - c.order_time) / 60) AS preparation_duration
        FROM
            pizza_runner.customer_orders_clean AS c
            JOIN pizza_runner.runner_orders_clean AS r ON c.order_id = r.order_id
        WHERE
            cancellation IS NULL
        GROUP BY
            1
    )
    SELECT
        pizza_num,
        ROUND(AVG(preparation_duration), 1) AS prep_duration_average
    FROM
        orders_prep_time
    GROUP BY
        1;
    ```

    Output:

    | "pizza_num" | "prep_duration_average" |
    |-------------|-------------------------|
    | 1           | 12.4                    |
    | 2           | 18.4                    |
    | 3           | 29.3                    |

    <br>

4. What was the average distance travelled for each customer?

    Query:

    ```sql
    SELECT
        customer_id,
        ROUND(AVG(distance)::NUMERIC, 2) AS distance_km_average
    FROM
        pizza_runner.customer_orders_clean AS c
        JOIN pizza_runner.runner_orders_clean AS r ON c.order_id = r.order_id
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "customer_id" | "distance_km_average" |
    |---------------|-----------------------|
    | 101           | 20.00                 |
    | 102           | 16.73                 |
    | 103           | 23.40                 |
    | 104           | 10.00                 |
    | 105           | 25.00                 |

    <br>

5. What was the difference between the longest and shortest delivery times for all orders?

    Query:

    ```sql
    SELECT
        MAX(duration) - MIN(duration) AS duration_diff_mins
    FROM
        pizza_runner.runner_orders_clean;
    ```

    Output:

    | "duration_diff_mins" |
    |----------------------|
    | 30                   |

    <br>

6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

    Query:

    ```sql
    SELECT
        runner_id,
        ROUND(AVG(distance / (duration::NUMERIC / 60))::NUMERIC, 2) speed_average
    FROM
        pizza_runner.runner_orders_clean
    WHERE
        cancellation IS NULL
    GROUP BY
        1;
    ```

    Output:

    | "runner_id" | "speed_average" |
    |-------------|-----------------|
    | 1           | 45.54           |
    | 2           | 62.90           |
    | 3           | 40.00           |

    > runner_id 2 is the fastest runner with average speed of 62.90kmph for each delivery.

    <br>

7. What is the successful delivery percentage for each runner?

    Query:

    ```sql
    SELECT
        runner_id,
        ROUND((100 * succesful_delivery / (succesful_delivery + unsuccesful_delivery))) AS succesful_percentage
    FROM (
        SELECT
            runner_id,
            SUM(
                CASE WHEN cancellation IS NULL THEN
                    1
                ELSE
                    0
                END) AS succesful_delivery,
            SUM(
                CASE WHEN cancellation IS NOT NULL THEN
                    1
                ELSE
                    0
                END) AS unsuccesful_delivery
        FROM
            pizza_runner.runner_orders_clean
        GROUP BY
            runner_id) AS delivery
    ORDER BY
        1;
    ```

    Output:

    | "runner_id" | "succesful_percentage" |
    |-------------|------------------------|
    | 1           | 100                    |
    | 2           | 75                     |
    | 3           | 50                     |

---
