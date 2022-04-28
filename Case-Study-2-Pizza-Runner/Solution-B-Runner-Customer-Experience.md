# :pizza: Case Study 2 - Pizza Runner: Solution B. Runner and Customer Experience

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
    - Use `DATEPART()` function to extract the week from registration_date column in the runner table.
    - Count all rows and group it by that week result.

    <br/>

    ```sql
    SELECT DATEPART(WEEK, registration_date) AS [week]
        ,Count(*) AS runner_signup
    FROM pizza_runner.runners
    GROUP BY DATEPART(week, registration_date);
    ```

    | week | runner_signup |
    | :--- | :------------ |
    | 1    | 1             |
    | 2    | 2             |
    | 3    | 1             |

2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
   - Use `DATEPART()` function to extract the minutes of pickup time each runner made from the `##runner_orders_cleaned` table.
   - Average each minutes and group the result by the runner_id.

    <br/>

    ```sql
    SELECT runner_id
        ,AVG(DATEPART(MINUTE, pickup_time)) AS avg_duration_minute
    FROM ##runner_orders_cleaned
    GROUP BY runner_id;
    ```

    | runner_id | avg_duration_minute |
    | :-------- | :------------------ |
    | 1         | 21                  |
    | 2         | 32                  |
    | 3         | 10                  |

3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
   - Succesful order can be counted by how many `pickup_time` that is `NOT NULL`.
   - Count the column and group it by the runner_id from the `##runner_orders_cleaned` table.

    <br/>

    ```sql
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
    ```

    | pizza_ordered | prep_time_minute |
    | :------------ | :--------------- |
    | 3             | 30               |
    | 2             | 21               |
    | 2             | 16               |
    | 1             | 21               |
    | 1             | 10               |
    | 1             | 10               |
    | 1             | 10               |
    | 1             | 10               |

    > The more the pizza ordered the more time it takes to prepare.

4. What was the average distance travelled for each customer?

   - Join the `##customer_orders_cleaned` table with the `##runner_orders_cleaned` to get the distance traveled to deliver pizza by each customer.
   - Aggregate the distance column to find the average distance travelled to deliver the pizza.
   - Group the result by the `customer_id`.

    <br/>

    ```sql
    SELECT customer.customer_id
        ,CONVERT(DECIMAL(4, 2), AVG(distance)) AS avg_distance_km
    FROM ##customer_orders_cleaned AS customer
    JOIN ##runner_orders_cleaned AS runner
        ON customer.order_id = runner.order_id
            AND cancellation IS NULL
    GROUP BY customer.customer_id;
    ```

    | customer_id | avg_distance_km |
    | :---------- | :-------------- |
    | 101         | 20.00           |
    | 102         | 16.73           |
    | 103         | 23.40           |
    | 104         | 10.00           |
    | 105         | 25.00           |

5. What was the difference between the longest and shortest delivery times for all orders?

   - Use `MAX()` function to get the longest delivery time and `MIN()` to get the shortest delivery times.
   - Substract the maximum value and the minimum value to get the difference.

    <br/>

    ```sql
    SELECT MAX(distance) - MIN(distance) AS distance_difference_km
    FROM ##runner_orders_cleaned
    WHERE cancellation IS NULL;
    ```

    | duration_difference_minutes |
    | :-------------------------- |
    | 30                          |

6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

   - Devide the distance and duration from ##runner_orders_cleaned table and multiply each result by 60 to get the speed in kmph.
   - Get the average of all speed result and group the result by runner_id.

    <br/>

    ```sql
    SELECT runner_id
        ,CONVERT(DECIMAL(4, 2), AVG((distance / duration) * 60)) AS avg_speed_kmph
    FROM ##runner_orders_cleaned
    WHERE cancellation IS NULL
    GROUP BY runner_id;
    ```

    | runner_id | avg_speed_kmph |
    | :-------- | :------------- |
    | 1         | 45.54          |
    | 2         | 62.90          |
    | 3         | 40.00          |

    > runner_id 1 and 3 has relatively the same delivery speed. runner_id 2 is the fastest runner with average speed of 62.90kmph.

7. What is the successful delivery percentage for each runner?
   - Find the number of succesfull delivery using the condition if the cancellation column in `##runner_orders_cleaned` table is `NULL`.
   - Find the number of unsuccesfull delivery using the condition if the cancellation column in `##runner_orders_cleaned` table is `NOT NULL`.
   - Join these two result.
   - Use `COALESCE()` function to check if there are NULL value from the calculation result, which mean either the runner has no succesfull delivery or the other way around.
   - Devide the number of succesfull delivery and the total delivery each runner made to get the percentage.

    <br/>

    ```sql
    WITH delivery
    AS (
        SELECT s_delivery.runner_id
            ,COALESCE(success, 0) AS delivered
            ,COALESCE(failed, 0) AS undelivered
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
        ,FORMAT((delivered / (delivered + undelivered)), 'p0') AS successful_delivery
    FROM delivery
    ORDER BY runner_id;
    ```

    | runner_id | successful_delivery |
    | :-------- | :------------------ |
    | 1         | 100%                |
    | 2         | 75%                 |
    | 3         | 50%                 |
