# :pizza: Case Study 2 - Pizza Runner: Solution C. Ingredient Optimisation

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. What are the standard ingredients for each pizza?

    - Join the `##pizza_recipes_cleaned`,  `##pizza_toppings_cleaned` and `##pizza_names_cleaned` to get the pizza name and the recipes.
    - Use `STRING_AGG()` to tranform the table from,

        | pizza_name | topping_name |
        | ---------- | ------------ |
        | Meatlovers | Bacon        |
        | Meatlovers | BBQ Sauce    |
        | Meatlovers | Beef         |
        | Meatlovers | Cheese       |
        | Meatlovers | Chicken      |

        to get the expected result.

    Code:

    ```sql
    SELECT piz.pizza_name
        ,STRING_AGG(topp.topping_name, ', ') AS ingredients
    FROM ##pizza_recipes_cleaned AS rec
    JOIN ##pizza_toppings_cleaned AS topp
        ON rec.toppings = topp.topping_id
    JOIN ##pizza_names_cleaned AS piz
        ON rec.pizza_id = piz.pizza_id
    GROUP BY piz.pizza_name;
    ```

    Output:

    | pizza_name | ingredients                                                           |
    | ---------- | --------------------------------------------------------------------- |
    | Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
    | Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

    <br/>

2. What was the most commonly added extra?

    - `STRING_APPLY()` function will be used here to split the `extras` value to rows.
    - The `STRING_APPLY()` result then joined with the customer order table to get the following format,

        | extras | new_extras |
        | ------ | ---------- |
        | 1, 5   | 1          |
        | 1, 5   | 5          |

    - The new extras value then joined with the `topping_id` from the `##pizza_toppings_cleaned` using `CROSS APPLY`to get the topping name for each pizza. `CROSS APPLY` used because the new extras table is returning a table-valued function.
    - Count each `topping_id` from the resulted table and group it by the topping_name.
    - Order the result by the count in descending order and get the higher value using `TOP 1`.

    Code:

    ```sql
    SELECT TOP 1 topp.topping_name
        ,COUNT(topp.topping_id) AS times_added
    FROM ##customer_orders_cleaned AS ord
    CROSS APPLY STRING_SPLIT(ord.extras, ',')
    JOIN ##pizza_toppings_cleaned AS topp
        ON topp.topping_id = [value]
    GROUP BY topp.topping_name
    ORDER BY 2 DESC;
    ```

    Output:

    | topping_name | times_added |
    | ------------ | ----------- |
    | Bacon        | 4           |

    <br/>

3. What was the most common exclusion?

    - Use the same way as the previous question, but this time with exclusion column.

    Code:

    ```sql
    SELECT TOP 1 topp.topping_name
        ,COUNT(topp.topping_id) AS times_excluded
    FROM ##customer_orders_cleaned AS ord
    CROSS APPLY STRING_SPLIT(ord.exclusions, ',')
    JOIN ##pizza_toppings_cleaned AS topp
        ON topp.topping_id = [value]
    GROUP BY topp.topping_name
    ORDER BY 2 DESC;
    ```

    Output:

    | topping_name | times_excluded |
    | ------------ | -------------- |
    | Cheese       | 4              |

    <br/>

4. Generate an order item for each record in the customers_orders table in the format of one of the following:

    1. Meat Lovers
    2. Meat Lovers - Exclude Beef
    3. Meat Lovers - Extra Bacon
    4. Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

    <br/>

    - To solve this question, few CTEs are going to be used.
    - First CTE, called `breakdown_cte` are going to breakdown the exclusion and extras column from the `##customer_orders_cleaned`. For example,

        | exclusions | exclusions_1 | exclusions_2 | extras | extras_1 | extras_2 |
        | ---------- | ------------ | ------------ | ------ | -------- | -------- |
        | 4          | 4            | NULL         | 1, 5   | 1        | 5        |
        | 2, 6       | 2            | 6            | 1, 4   | 1        | 4        |

    - Also, join the `##pizza_names_cleaned` to get the pizza name.
    - The second CTE, `topping_name_cte`, used to join each topping_id from the result pf first CTE with `##pizza_toppings_cleaned` to get the topping name.
    - The last CTE, `concat_build`, used to create the required format. For example
        | exclusions_name_1 | exclusions_name_2 | formatted                      |
        | ----------------- | ----------------- | ------------------------------ |
        | BBQ Sauce         | Mushrooms         | - Exclude BBQ Sauce, Mushrooms |

    - Concat the formatted result with the pizza name to get the final result.

    Code:

    ```sql
    WITH breakdown_cte
    AS (
        SELECT ord.order_id
            ,ord.customer_id
            ,piz.pizza_name
            ,ord.order_row
            ,CASE -- Exclusion 1 breakdown
                WHEN ord.exclusions IS NULL
                    THEN NULL
                ELSE LEFT(ord.exclusions, 1)
                END AS exclusions_1
            ,CASE -- Exclusion 2 breakdown
                WHEN LEN(ord.exclusions) > 1
                    THEN RIGHT(ord.exclusions, 1)
                ELSE NULL
                END AS exclusions_2
            ,CASE -- Extras 1 breakdown
                WHEN ord.extras IS NULL
                    THEN NULL
                ELSE LEFT(ord.extras, 1)
                END AS extras_1
            ,CASE -- Extras 2 breakdown
                WHEN LEN(ord.extras) > 1
                    THEN RIGHT(ord.extras, 1)
                ELSE NULL
                END AS extras_2
        FROM ##customer_orders_cleaned AS ord
        JOIN ##pizza_names_cleaned AS piz
            ON ord.pizza_id = piz.pizza_id
        )
        ,
        -- Join the breakdown result to get the toppings name for the excluded and extras topping
    topping_name_cte
    AS (
        SELECT bd.order_id
            ,bd.customer_id
            ,bd.pizza_name
            ,topp1.topping_name AS exclusions_name_1
            ,topp2.topping_name AS exclusions_name_2
            ,topp3.topping_name AS extras_name_1
            ,topp4.topping_name AS extras_name_2
        FROM breakdown_cte AS bd
        LEFT JOIN ##pizza_toppings_cleaned AS topp1
            ON bd.exclusions_1 = topp1.topping_id
        LEFT JOIN ##pizza_toppings_cleaned AS topp2
            ON bd.exclusions_2 = topp2.topping_id
        LEFT JOIN ##pizza_toppings_cleaned AS topp3
            ON bd.extras_1 = topp3.topping_id
        LEFT JOIN ##pizza_toppings_cleaned AS topp4
            ON bd.extras_2 = topp4.topping_id
        )
        ,concat_build
    AS (
        SELECT order_id
            ,customer_id
            ,pizza_name
            ,CASE
                WHEN exclusions_name_1 IS NULL
                    AND exclusions_name_2 IS NULL
                    THEN NULL
                WHEN exclusions_name_1 IS NOT NULL
                    AND exclusions_name_2 IS NULL
                    THEN CONCAT (
                            ' - Exclude '
                            ,exclusions_name_1
                            )
                WHEN exclusions_name_1 IS NULL
                    AND exclusions_name_2 IS NOT NULL
                    THEN CONCAT (
                            ' - Exclude '
                            ,exclusions_name_2
                            )
                ELSE CONCAT (
                        ' - Exclude '
                        ,exclusions_name_1
                        ,', '
                        ,exclusions_name_2
                        )
                END AS exclusions
            ,CASE
                WHEN extras_name_1 IS NULL
                    AND extras_name_2 IS NULL
                    THEN NULL
                WHEN extras_name_1 IS NOT NULL
                    AND extras_name_2 IS NULL
                    THEN CONCAT (
                            ' - Extra '
                            ,extras_name_1
                            )
                WHEN extras_name_1 IS NULL
                    AND extras_name_2 IS NOT NULL
                    THEN CONCAT (
                            ' - Extra '
                            ,extras_name_2
                            )
                ELSE CONCAT (
                        ' - Extra '
                        ,extras_name_1
                        ,', '
                        ,extras_name_2
                        )
                END AS extras
        FROM topping_name_cte
        )
    -- Let's create the required format
    SELECT order_id
        ,customer_id
        ,CONCAT (
            pizza_name
            ,exclusions
            ,extras
            ) AS order_details
    FROM concat_build;
    ```

    Output:

    | order_id | customer_id | order_details                                                   |
    | -------- | ----------- | --------------------------------------------------------------- |
    | 1        | 101         | Meatlovers                                                      |
    | 2        | 101         | Meatlovers                                                      |
    | 3        | 102         | Meatlovers                                                      |
    | 3        | 102         | Vegetarian                                                      |
    | 4        | 103         | Meatlovers - Exclude Cheese                                     |
    | 4        | 103         | Meatlovers - Exclude Cheese                                     |
    | 4        | 103         | Vegetarian - Exclude Cheese                                     |
    | 5        | 104         | Meatlovers - Extra Bacon                                        |
    | 6        | 101         | Vegetarian                                                      |
    | 7        | 105         | Vegetarian - Extra Bacon                                        |
    | 8        | 102         | Meatlovers                                                      |
    | 9        | 103         | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
    | 10       | 104         | Meatlovers                                                      |
    | 10       | 104         | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

    <br/>

5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
    1. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

    <br/>

    - Create a temp table, called `#customer_orders_long`, to get detailed order by the customer, including the customer id, pizza name, and pizza toppings. This is done by joining the `##customer_orders_cleaned` and `##pizza_recipes_cleaned` for each pizza_id, and `##pizza_names_cleaned` also for each pizza_id.
    - Crete another temp table, `#customer_exclusions_long` and `#customer_extras_long` to list every exclusions and extras for each pizza ordered by the customer.
    - Next, union the new `#customer_exclusions_long` table with the `#customer_orders_long` to find which topping are excluded from the pizza ordered. This is done by finding the rows that exist in both table. Or, simply duplicated after the union and put the result in aonther temp table called `#customer_reduced`
    - Union the resul from `#customer_reduced` with `#customer_extras_long` to get every topping on pizza that ordered by customers and put the result in `#detailed_order` temp table.
    - The final step require some more things to do. The steps below are in each CTE:
        - First, count each occurance of each toppings and group them by the topping name.
        - Next, for each toppings that has 2 or more counts, concatenate the topping name using
        `CONCAT (num,'x',topping_name)`. For example,

            | num | topping_name | topping_num |
            | --- | ------------ | ----------- |
            | 2   | Bacon        | 2xBacon     |
        - Use `STRING_AGG()` function just like the first question to combine every row from the resulted.
        - Concatenate the pizza name and the `STRING_AGG()` function result.

    Code:

    ```sql
    DROP TABLE
    IF EXISTS #customer_orders_long;
        SELECT ord.order_row
            ,ord.order_id
            ,ord.customer_id
            ,piz.pizza_name
            ,rec.toppings AS toppings
        INTO #customer_orders_long
        FROM ##customer_orders_cleaned AS ord
        JOIN ##pizza_recipes_cleaned AS rec
            ON ord.pizza_id = rec.pizza_id
        JOIN ##pizza_names_cleaned AS piz
            ON rec.pizza_id = piz.pizza_id;
    --
    -- Reshape the exclusions column from ##customer_orders_cleaned table to list the ingredients
    DROP TABLE
    IF EXISTS #customer_exclusions_long;
        SELECT ord.order_row
            ,ord.order_id
            ,ord.customer_id
            ,pizz.pizza_name
            ,TRIM(value) AS toppings
        INTO #customer_exclusions_long
        FROM ##customer_orders_cleaned AS ord
        CROSS APPLY STRING_SPLIT(exclusions, ',')
        JOIN ##pizza_names_cleaned AS pizz
            ON ord.pizza_id = pizz.pizza_id
        WHERE exclusions IS NOT NULL;
    --
    -- Reshape the extras column from ##customer_orders_cleaned table to list the ingredients
    DROP TABLE
    IF EXISTS #customer_extras_long;
        SELECT ord.order_row
            ,ord.order_id
            ,ord.customer_id
            ,piz.pizza_name
            ,TRIM(value) AS toppings
        INTO #customer_extras_long
        FROM ##customer_orders_cleaned AS ord
        CROSS APPLY STRING_SPLIT(extras, ',')
        JOIN ##pizza_names_cleaned AS piz
            ON ord.pizza_id = piz.pizza_id
        WHERE EXTRAS IS NOT NULL;
    --
    -- Union the new exclusion table and the new customer order table
    -- And, remove the topping in the second table that also exist in the exclusion table
    DROP TABLE
    IF EXISTS #customer_reduced;
        WITH excluded
        AS (
            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            FROM #customer_exclusions_long

            UNION ALL

            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            FROM #customer_orders_long
            )
            ,find_dup
        AS (
            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
                ,COUNT(*) AS occurence
            FROM excluded
            GROUP BY order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            )
            ,drop_dup
        AS (
            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            FROM find_dup
            WHERE occurence = 1
            )
        SELECT *
        INTO #customer_reduced
        FROM drop_dup;
    --
    -- Union the reduced customer table with the new extras table
    -- Create a temp table to store the entirity of the result called #detailed_order
    DROP TABLE
    IF EXISTS #detailed_order;
        WITH customer_extras
        AS (
            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            FROM #customer_reduced

            UNION ALL

            SELECT order_row
                ,order_id
                ,customer_id
                ,pizza_name
                ,toppings
            FROM #customer_extras_long
            )
        SELECT order_row
            ,order_id
            ,customer_id
            ,pizza_name
            ,topping_id
            ,topping_name
        INTO #detailed_order
        FROM customer_extras AS orders
        JOIN ##pizza_toppings_cleaned AS toppings
            ON orders.toppings = toppings.topping_id;
    --
    -- Answer the questions!
    WITH get_count
    AS (
        SELECT order_row
            ,order_id
            ,customer_id
            ,pizza_name
            ,topping_name
            ,COUNT(topping_id) AS num
        FROM #detailed_order AS orders
        GROUP BY order_row
            ,order_id
            ,customer_id
            ,pizza_name
            ,topping_name
        )
        ,topping_count
    AS (
        SELECT order_row
            ,order_id
            ,customer_id
            ,pizza_name
            ,CASE
                WHEN num > 1
                    THEN CONCAT (
                            num
                            ,'x'
                            ,topping_name
                            )
                ELSE topping_name
                END AS topping_num
        FROM get_count
        )
        ,topping_text
    AS (
        SELECT order_row
            ,order_id
            ,customer_id
            ,pizza_name
            ,STRING_AGG(topping_num, ', ') AS toppings_detail
        FROM topping_count
        GROUP BY order_row
            ,order_id
            ,customer_id
            ,pizza_name
        )
    SELECT order_row
        ,order_id
        ,customer_id
        ,CONCAT (
            pizza_name
            ,': '
            ,toppings_detail
            ) AS order_detail
    FROM topping_text;
    ```

    Output:

    | order_row | customer_id | order_detail                                                                        |
    | --------- | ----------- | ----------------------------------------------------------------------------------- |
    | 1         | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
    | 2         | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
    | 3         | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
    | 4         | 102         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
    | 5         | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
    | 6         | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
    | 7         | 103         | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
    | 8         | 104         | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
    | 9         | 101         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
    | 10        | 105         | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes       |
    | 11        | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
    | 12        | 103         | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
    | 13        | 104         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
    | 14        | 104         | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |

    <br/>

6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

    - Use the `#detailed_order` from the previous question to answer this question.
    - Count `topping_id` from this table and group the result by the `topping_name`.
    - Order the result by the `topping_name` in descending order.

    Code:

    ```sql
    SELECT topping_name
        ,COUNT(topping_id) AS time_used
    FROM #detailed_order
    GROUP BY topping_name
    ORDER BY 2 DESC
        ,topping_name;
    ```

    Output:

    | topping_name | time_used |
    | ------------ | --------- |
    | Bacon        | 14        |
    | Mushrooms    | 13        |
    | Cheese       | 11        |
    | Chicken      | 11        |
    | Beef         | 10        |
    | Pepperoni    | 10        |
    | Salami       | 10        |
    | BBQ Sauce    | 9         |
    | Onions       | 4         |
    | Peppers      | 4         |
    | Tomato Sauce | 4         |
    | Tomatoes     | 4         |
