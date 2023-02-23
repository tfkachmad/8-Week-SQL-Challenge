# :pizza: Case Study 2 - Pizza Runner: Solution A. Pizza Metrics

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. How many pizzas were ordered?

    Query:

    ```sql
    SELECT
        COUNT(order_id) AS orders_num
    FROM
        pizza_runner.customer_orders_clean;
    ```

    Output:

    | "orders_num" |
    |--------------|
    | 14           |

    <br>

2. How many unique customer orders were made?

    Query:

    ```sql
    SELECT
        COUNT(DISTINCT customer_id) AS customer_num
    FROM
        pizza_runner.customer_orders_clean;
    ```

    Output:

    | "customer_num" |
    |----------------|
    | 5              |

    <br>

3. How many successful orders were delivered by each runner?

    Query:

    ```sql
    SELECT
        runner_id,
        COUNT(order_id) AS orders_num
    FROM
        pizza_runner.runner_orders_clean
    WHERE
        cancellation IS NULL
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "runner_id" | "orders_num" |
    |-------------|--------------|
    | 1           | 4            |
    | 2           | 3            |
    | 3           | 1            |

    <br>

4. How many of each type of pizza was delivered?

    Query:

    ```sql
    SELECT
        pizza_name,
        COUNT(order_id) AS pizza_num
    FROM
        pizza_runner.customer_orders_clean AS c
        JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
    GROUP BY
        1;
    ```

    Output:

    | "pizza_name" | "pizza_num" |
    |--------------|-------------|
    | Meatlovers   | 10          |
    | Vegetarian   | 4           |

    <br>

5. How many Vegetarian and Meatlovers were ordered by each customer?

    Query:

    ```sql
    SELECT
        customer_id,
        COUNT(
            CASE WHEN p.pizza_name = 'Meatlovers' THEN
                1
            ELSE
                NULL
            END) AS meatlovers_total,
        COUNT(
            CASE WHEN p.pizza_name = 'Vegetarian' THEN
                1
            ELSE
                NULL
            END) AS vegetarian_total
    FROM
        pizza_runner.customer_orders_clean AS c
        JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "customer_id" | "meatlovers_total" | "vegetarian_total" |
    |---------------|--------------------|--------------------|
    | 101           | 2                  | 1                  |
    | 102           | 2                  | 1                  |
    | 103           | 3                  | 1                  |
    | 104           | 3                  | 0                  |
    | 105           | 0                  | 1                  |

    <br>

6. What was the maximum number of pizzas delivered in a single order?

    Query:

    ```sql
    SELECT
        order_id,
        COUNT(order_id) AS pizza_num
    FROM
        pizza_runner.customer_orders_clean
    GROUP BY
        order_id
    ORDER BY
        COUNT(order_id) DESC
    LIMIT 1;

    ```

    Output:

    | "order_id" | "pizza_num" |
    |------------|-------------|
    | 4          | 3           |

    <br>

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

    Query:

    ```sql
    SELECT
        customer_id,
        SUM(
            CASE WHEN exclusions IS NOT NULL
                OR extras IS NOT NULL THEN
                1
            ELSE
                0
            END) AS pizza_had_change_num,
        SUM(
            CASE WHEN exclusions IS NULL
                AND extras IS NULL THEN
                1
            ELSE
                0
            END) AS pizza_no_change_num
    FROM
        pizza_runner.customer_orders_clean
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "customer_id" | "pizza_had_change_num" | "pizza_no_change_num" |
    |---------------|------------------------|-----------------------|
    | 101           | 0                      | 3                     |
    | 102           | 0                      | 3                     |
    | 103           | 4                      | 0                     |
    | 104           | 2                      | 1                     |
    | 105           | 1                      | 0                     |

    <br>

8. How many pizzas were delivered that had both exclusions and extras?

    Query:

    ```sql
    SELECT
        SUM(
            CASE WHEN exclusions IS NOT NULL
                AND extras IS NOT NULL THEN
                1
            ELSE
                0
            END) AS pizza_num
    FROM
        pizza_runner.customer_orders_clean;
    ```

    Output:

    | "pizza_num" |
    |-------------|
    | 2           |

    <br>

9. What was the total volume of pizzas ordered for each hour of the day?

    Query:

    ```sql
    SELECT
        EXTRACT(HOUR FROM order_time) AS hour,
        COUNT(order_id) AS orders_total
    FROM
        pizza_runner.customer_orders_clean
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "hour" | "orders_total" |
    |--------|----------------|
    | 11     | 1              |
    | 13     | 3              |
    | 18     | 3              |
    | 19     | 1              |
    | 21     | 3              |
    | 23     | 3              |

    <br>

10. What was the volume of orders for each day of the week?

    Query:

    ```sql
    SELECT
        TO_CHAR(order_time, 'Day') AS day_of_week,
        COUNT(order_id) AS orders_total
    FROM
        pizza_runner.customer_orders_clean
    GROUP BY
        1,
        EXTRACT('dow' FROM order_time)
    ORDER BY
        EXTRACT('dow' FROM order_time);
    ```

    Output:

    | "day_of_week" | "orders_total" |
    |---------------|----------------|
    | Wednesday     | 5              |
    | Thursday      | 3              |
    | Friday        | 1              |
    | Saturday      | 5              |

---
