# :pizza: Case Study 2 - Pizza Runner: Solution A. Pizza Metrics

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. How many pizzas were ordered?
    - Count total rows from the `##customer_orders_cleaned` table, because each rows representing each pizza ordered by customers.

    Query:

    ```sql
    SELECT COUNT(*) AS total_order
    FROM ##customer_orders_cleaned;
    ```

    Output:

    | total_order |
    | :---------- |
    | 14          |

    <br/>

2. How many unique customer orders were made?
   - Count the distinct `custumer_id` from the `##customer_orders_cleaned` table.

    Query:

    ```sql
    SELECT COUNT(DISTINCT customer_id) AS unique_orders
    FROM ##customer_orders_cleaned;
    ```

    Output:

    | unique_orders |
    | :------------ |
    | 5             |

    <br/>

3. How many successful orders were delivered by each runner?
   - Succesful order can be counted by how many pickup_time that is not `NULL`.
   - Count the column and group it by the runner_id from the `##runner_orders_cleaned` table.

    Query:

    ```sql
    SELECT runner_id
        ,COUNT(pickup_time) AS succesful_order
    FROM ##runner_orders_cleaned
    GROUP BY runner_id;
    ```

    Output:

    | runner_id | succesful_order |
    | :-------- | :-------------- |
    | 1         | 4               |
    | 2         | 3               |
    | 3         | 1               |

    <br/>

4. How many of each type of pizza was delivered?
   - Join the `##customer_orders_cleaned` table with the `##pizza_names_cleaned` to get the pizza name from each customer's order.
   - Count all the orders and group it by the pizza_name.

    Query:

    ```sql
    SELECT pizza.pizza_name
        ,Count(*) AS num_delivered
    FROM ##customer_orders_cleaned AS customer
    JOIN ##pizza_names_cleaned AS pizza
        ON customer.pizza_id = pizza.pizza_id
    GROUP BY pizza.pizza_name;
    ```

    Output:

    | pizza_name | num_delivered |
    | :--------- | :------------ |
    | Meatlovers | 10            |
    | Vegetarian | 4             |

    <br/>

5. How many Vegetarian and Meatlovers were ordered by each customer?
   - Join the `##customer_orders_cleaned` table with the `##pizza_names_cleaned` to get the pizza name from each customer's order.
   - Count each types of pizza by using expression to find if the ordered pizza is Meatlovers or not. Also, do the same for the Vegetarian pizza type and create columns for each pizza types.

    Query:

    ```sql
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
    ```

    Output:

    | customer_id | Meatlovers | Vegetarian |
    | :---------- | :--------- | :--------- |
    | 101         | 2          | 1          |
    | 102         | 2          | 1          |
    | 103         | 3          | 1          |
    | 104         | 3          | 0          |
    | 105         | 0          | 1          |

    <br/>

6. What was the maximum number of pizzas delivered in a single order?
   - Create a CTE to find the number of pizza ordered within each order_id from `##customer_orders_cleaned` table.
   - Use that CTE to find the maximum number of pizza ordered.

    Query:

    ```sql
    SELECT MAX(num_pizza) AS max_pizza_delivered
    FROM (
        SELECT order_id
            ,COUNT(*) AS num_pizza
        FROM ##customer_orders_cleaned
        GROUP BY order_id
        ) AS pizza_count;
    ```

    Output:

    | max_pizza_delivered |
    | :------------------ |
    | 3                   |

    <br/>

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
   - Count every pizza ordered from `##customer_orders_cleaned` with condition that had change, where either the pizza had NULL exclusions and non NULL extras, the pizza had non NULL exclusions and NULL extras, or both are non NULL.
   - Count the pizza ordered where that both exclusions and extras is NULL to find the pizza ordered had no change.

    Query:

    ```sql
    SELECT customer_id
        ,COUNT(CASE
                WHEN (
                        exclusions IS NULL
                        AND extras IS NOT NULL
                        )
                    OR (
                        exclusions IS NOT NULL
                        AND extras IS NULL
                        )
                    OR (
                        exclusions IS NOT NULL
                        AND extras IS NOT NULL
                        )
                    THEN 1
                ELSE NULL
                END) AS pizza_had_change
        ,COUNT(CASE
                WHEN exclusions IS NULL
                    AND extras IS NULL
                    THEN 1
                ELSE NULL
                END) AS pizza_had_no_change
    FROM ##customer_orders_cleaned
    GROUP BY customer_id;
    ```

    Output:

    | customer_id | pizza_had_change | pizza_had_no_change |
    | :---------- | :--------------- | :------------------ |
    | 101         | 0                | 3                   |
    | 102         | 0                | 3                   |
    | 103         | 4                | 0                   |
    | 104         | 2                | 1                   |
    | 105         | 1                | 0                   |

    <br/>

8. How many pizzas were delivered that had both exclusions and extras?
   - Same as the previous question, but only find the condition that both exclusions and extras column is NOT NULL.

    Query:

    ```sql
    SELECT COUNT(*) AS pizza_with_exclusions_extras
    FROM ##customer_orders_cleaned
    WHERE exclusions IS NOT NULL
        AND extras IS NOT NULL;
    ```

    Output:

    | pizza_with_exclusions_extras |
    | :--------------------------- |
    | 2                            |

    <br/>

9. What was the total volume of pizzas ordered for each hour of the day?
    - Count each customer order from `##customer_orders_cleaned` table.
    - Use `DATEPART()` function to find the day and hour to find the volume of each day and hour pizza ordered.
    - Group the result by the day and hour.

    Query:

    ```sql
    SELECT DATEPART(DAY, order_time) AS [day]
        ,DATEPART(HOUR, order_time) AS [hour]
        ,Count(*) AS pizza_orderred
    FROM ##customer_orders_cleaned
    GROUP BY DATEPART(DAY, order_time)
        ,DATEPART(HOUR, order_time)
    ORDER BY 1;
    ```

    Output:

    | day  | hour | pizza_orderred |
    | :--- | :--- | :------------- |
    | 1    | 18   | 1              |
    | 1    | 19   | 1              |
    | 2    | 23   | 2              |
    | 4    | 13   | 3              |
    | 8    | 21   | 3              |
    | 9    | 23   | 1              |
    | 10   | 11   | 1              |
    | 11   | 18   | 2              |

    <br/>

10. What was the volume of orders for each day of the week?
    - Count each customer order from `##customer_orders_cleaned` table.
    - Use `DATEPART()` function to find the week and day to find the volume of each day and hour pizza ordered.
    - Group the result by the week and day.

    Query:

    ```sql
    SELECT DATEPART(WEEK, order_time) AS [week]
        ,DATEPART(DAY, order_time) AS [day]
        ,COUNT(*) AS pizza_orderred
    FROM ##customer_orders_cleaned
    GROUP BY DATEPART(Week, order_time)
        ,DATEPART(Day, order_time)
    ORDER BY 1;
    ```

    Output:

    | week | day  | pizza_orderred |
    | :--- | :--- | :------------- |
    | 1    | 1    | 2              |
    | 1    | 2    | 2              |
    | 1    | 4    | 3              |
    | 2    | 8    | 3              |
    | 2    | 9    | 1              |
    | 2    | 10   | 1              |
    | 2    | 11   | 2              |

---
