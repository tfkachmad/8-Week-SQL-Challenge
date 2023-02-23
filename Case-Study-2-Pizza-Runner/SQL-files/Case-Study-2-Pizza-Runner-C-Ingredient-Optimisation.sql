--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 2 - Pizza Runner
-- Part C - Ingredient Optimisation
--
-- 1. What are the standard ingredients for each pizza?
SELECT
    n.pizza_name,
    STRING_AGG(t.topping_name, ', ' ORDER BY t.topping_id) AS pizza_ingredients
FROM
    pizza_runner.pizza_recipes_long AS r
    JOIN pizza_runner.pizza_toppings AS t ON r.topping_id = t.topping_id
    JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
GROUP BY
    1
ORDER BY
    1;

--
-- 2. What was the most commonly added extra?
WITH extras_id AS (
    SELECT
        UNNEST(STRING_TO_ARRAY(extras, ', '))::INTEGER AS extras
    FROM
        pizza_runner.customer_orders_clean
    WHERE
        extras IS NOT NULL
)
SELECT
    p.topping_name,
    COUNT(*) AS total
FROM
    extras_id AS e
    JOIN pizza_runner.pizza_toppings AS p ON e.extras = p.topping_id
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 1;

--
-- 3. What was the most common exclusion?
WITH exclusions_id AS (
    SELECT
        UNNEST(STRING_TO_ARRAY(exclusions, ', '))::INTEGER AS exclusions
    FROM
        pizza_runner.customer_orders_clean
    WHERE
        exclusions IS NOT NULL
)
SELECT
    p.topping_name,
    COUNT(*) AS total
FROM
    exclusions_id AS e
    JOIN pizza_runner.pizza_toppings AS p ON e.exclusions = p.topping_id
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 1;

--
-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- 		Meat Lovers
-- 		Meat Lovers - Exclude Beef
-- 		Meat Lovers - Extra Bacon
-- 		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH orders_long AS (
    SELECT
        c.unique_id,
        c.order_id,
        c.customer_id,
        c.pizza_id,
        t1.exclusions::INTEGER,
        t2.extras::INTEGER
    FROM
        pizza_runner.customer_orders_clean AS c
        LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS t1 (exclusions) ON TRUE
        LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(extras, ', ')) AS t2 (extras) ON TRUE
),
toppings_pizza_name AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        o.exclusions AS exclusions_id,
        o.extras AS extras_id,
        p1.topping_id,
        p1.topping_name AS exclusions,
        p2.topping_name AS extras,
        p3.pizza_name,
        ROW_NUMBER() OVER (PARTITION BY unique_id,
            o.exclusions) AS exclusions_index,
        ROW_NUMBER() OVER (PARTITION BY unique_id,
            o.extras) AS extras_index
    FROM
        orders_long AS o
        LEFT JOIN pizza_runner.pizza_toppings AS p1 ON o.exclusions = p1.topping_id
        LEFT JOIN pizza_runner.pizza_toppings AS p2 ON o.extras = p2.topping_id
        JOIN pizza_runner.pizza_names AS p3 ON o.pizza_id = p3.pizza_id
),
remove_duplicate_toppings AS (
    SELECT
        unique_id,
        order_id,
        pizza_name,
        topping_id,
        CASE WHEN exclusions_index = 2 THEN
            NULL
        ELSE
            exclusions
        END,
        CASE WHEN extras_index = 2 THEN
            NULL
        ELSE
            extras
        END
    FROM
        toppings_pizza_name
),
topping_list AS (
    SELECT
        unique_id,
        order_id,
        pizza_name,
        STRING_AGG(exclusions, ', ' ORDER BY topping_id) AS exclusions_list,
    STRING_AGG(extras, ', ' ORDER BY topping_id) AS extras_list
FROM
    remove_duplicate_toppings
GROUP BY
    1,
    2,
    3
)
SELECT
    order_id,
    pizza_name || ' ' || COALESCE(' - Exclude ' || exclusions_list, '') || ' ' || COALESCE(' - Extras ' || extras_list, '') AS pizza_order_detail
FROM
    topping_list
ORDER BY
    1;

--
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- 		For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH exclusions AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        UNNEST(STRING_TO_ARRAY(exclusions, ', '))::INTEGER AS topping_id
    FROM
        pizza_runner.customer_orders_clean
),
extras AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        UNNEST(STRING_TO_ARRAY(extras, ', '))::INTEGER AS topping_id
    FROM
        pizza_runner.customer_orders_clean
),
all_toppings AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        c.pizza_id,
        topping_id
    FROM
        pizza_runner.customer_orders_clean AS c
        LEFT JOIN pizza_runner.pizza_recipes_long AS r ON c.pizza_id = r.pizza_id
),
remove_exclusions AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        topping_id,
        COUNT(topping_id) AS topping_num
    FROM (
        SELECT
            unique_id,
            order_id,
            customer_id,
            pizza_id,
            topping_id
        FROM
            all_toppings
        UNION ALL
        SELECT
            unique_id,
            order_id,
            customer_id,
            pizza_id,
            topping_id
        FROM
            exclusions) AS exclusions_union
    GROUP BY
        1,
        2,
        3,
        4,
        5
    HAVING
        COUNT(topping_id) = 1
),
toppings_count AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_name,
        topping_name,
        COUNT(extras_union.topping_id) AS topping_num
    FROM (
        SELECT
            unique_id,
            order_id,
            customer_id,
            pizza_id,
            topping_id
        FROM
            remove_exclusions
        UNION ALL
        SELECT
            unique_id,
            order_id,
            customer_id,
            pizza_id,
            topping_id
        FROM
            extras) AS extras_union
    JOIN pizza_runner.pizza_names AS n ON extras_union.pizza_id = n.pizza_id
    JOIN pizza_runner.pizza_toppings AS t ON extras_union.topping_id = t.topping_id
    GROUP BY
        1,
        2,
        3,
        4,
        5
),
toppings_name AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_name,
        topping_name,
        CASE WHEN topping_num > 1 THEN
            CONCAT(topping_num, 'x', topping_name)
        ELSE
            topping_name
        END AS topping
    FROM
        toppings_count
),
pizza_topping_concat AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_name,
        CONCAT(pizza_name, ': ', STRING_AGG(topping, ', ' ORDER BY topping_name)) AS pizza
    FROM
        toppings_name
    GROUP BY
        1,
        2,
        3,
        4
)
SELECT
    order_id,
    customer_id,
    pizza
FROM
    pizza_topping_concat;

--
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH exclusions AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        UNNEST(STRING_TO_ARRAY(exclusions, ', '))::INTEGER AS topping_id
    FROM
        pizza_runner.customer_orders_clean
),
extras AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        UNNEST(STRING_TO_ARRAY(extras, ', '))::INTEGER AS topping_id
    FROM
        pizza_runner.customer_orders_clean
),
all_toppings AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        c.pizza_id,
        topping_id
    FROM
        pizza_runner.customer_orders_clean AS c
        LEFT JOIN pizza_runner.pizza_recipes_long AS r ON c.pizza_id = r.pizza_id
),
remove_exclusions AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        topping_id,
        COUNT(topping_id) AS topping_num
    FROM (
        SELECT
            unique_id,
            order_id,
            customer_id,
            pizza_id,
            topping_id
        FROM
            all_toppings
    UNION ALL
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        topping_id
    FROM
        exclusions) AS exclusions_union
    GROUP BY
        1,
        2,
        3,
        4,
        5
    HAVING
        COUNT(topping_id) = 1
),
toppings_used AS (
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        topping_id
    FROM
        remove_exclusions
    UNION ALL
    SELECT
        unique_id,
        order_id,
        customer_id,
        pizza_id,
        topping_id
    FROM
        extras
)
SELECT
    topping_name,
    COUNT(topping_name) AS topping_total
FROM
    toppings_used AS t1
    JOIN pizza_runner.pizza_toppings AS t2 ON t1.topping_id = t2.topping_id
GROUP BY
    1
ORDER BY
    2 DESC;
