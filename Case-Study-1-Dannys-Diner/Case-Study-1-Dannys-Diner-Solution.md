# :ramen: Case Study 1 - Danny's Dinner Solution

:rocket: **DBMS: SQL Server**

## :pencil2: Preparation

-   Create a temp table to join `dannys_diner.sales` and `dannys_diner.menu` table

    ```sql
    -- Create a Temp Table to join the sales and menu table.
    DROP TABLE IF EXISTS #sales_menu_table;
    SELECT Row_Number() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_order,
        sales.customer_id,
        sales.order_date,
        sales.product_id,
        menu.product_name,
        menu.price
    INTO #sales_menu_table
    FROM dannys_diner.sales AS sales
        JOIN dannys_diner.menu menu
            ON sales.product_id = menu.product_id;
    ```

<br>

## :tada: Solution

1. What is the total amount each customer spent at the restaurant?

    - Sum the `total` and group it by the `customer_id`

    <br>

    ```sql
    SELECT customer_id AS customer,
        CONCAT('$', SUM(price)) AS total_spent
    FROM #sales_menu_table
    GROUP BY customer_id;
    ```

    | customer | total_spent |
    | -------- | ----------- |
    | A        | $76         |
    | B        | $74         |
    | C        | $36         |

<br>

2. How many days has each customer visited the restaurant?

    -

    <br>

    ```sql
    SELECT customer_id AS customer,
        COUNT(DISTINCT order_date) AS days_visited
    FROM dannys_diner.sales
    GROUP BY customer_id;
    ```

    | customer | days_visited |
    | -------- | ------------ |
    | A        | 4            |
    | B        | 6            |
    | C        | 2            |

<br>

3. What was the first item from the menu purchased by each customer?

    -

    <br>

    ```sql
    SELECT customer_id AS customer,
        product_name AS first_purchase
    FROM #sales_menu_table
    WHERE row_order = 1;
    ```

    | customer | first_purchase |
    | -------- | -------------- |
    | A        | sushi          |
    | B        | curry          |
    | C        | ramen          |

<br>

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

    -

    <br>

    ```sql
    SELECT TOP 1
        product_name,
        Count(*) AS total_purchased
    FROM #sales_menu_table
    GROUP BY product_name
    ORDER BY 2 DESC;
    ```

    | product_name | total_purchased |
    | ------------ | --------------- |
    | ramen        | 8               |

<br>

5. Which item was the most popular for each customer?

    -

    <br>

    ```sql
    WITH popular_products
    AS (SELECT customer_id,
            product_name,
            RANK() OVER (PARTITION BY customer_id ORDER BY Count(customer_id) DESC) AS rank_product
        FROM #sales_menu_table
        GROUP BY customer_id,
                product_Name
    )
    SELECT customer_id AS customer,
        product_name
    FROM popular_products
    WHERE rank_product = 1;
    ```

    | customer | product_name |
    | -------- | ------------ |
    | A        | ramen        |
    | B        | sushi        |
    | B        | curry        |
    | B        | ramen        |
    | C        | ramen        |

<br>

6. Which item was purchased first by the customer after they became a member?

    -

    <br>

    ```sql
    WITH after_member_purchase
    AS (SELECT RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank_member,
            sales.customer_id,
            sales.product_name
        FROM #sales_menu_table AS sales
            JOIN dannys_diner.members AS members
                ON sales.customer_id = members.customer_id
                AND sales.order_date >= members.join_date
    )
    SELECT customer_id AS customer,
        product_name
    FROM after_member_purchase
    WHERE rank_member = 1;
    ```

    | customer | product_name |
    | -------- | ------------ |
    | A        | curry        |
    | B        | sushi        |

<br>

1. Which item was purchased just before the customer became a member?

    -

    <br>

    ```sql
    WITH before_member_purchase
    AS (SELECT RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank_member,
            sales.customer_id,
            sales.product_name
        FROM #sales_menu_table AS sales
            JOIN dannys_diner.members AS members
                ON sales.customer_id = members.customer_id
                AND sales.order_date < members.join_date
    )
    SELECT customer_id AS customer,
        product_name
    FROM before_member_purchase
    WHERE rank_member = 1;
    ```

    | customer | product_name |
    | -------- | ------------ |
    | A        | sushi        |
    | A        | curry        |
    | B        | curry        |

<br>

1. What is the total items and amount spent for each member before they became a member?

    -

    <br>

    ```sql
    WITH before_member_spent
    AS (SELECT sales.customer_id,
            sales.product_id,
            sales.price
        FROM #sales_menu_table AS sales
            JOIN dannys_diner.members AS members
                ON sales.customer_id = members.customer_id
                AND sales.order_date < members.join_date
    )
    SELECT customer_id AS customer,
        COUNT(*) AS item_purchased,
        CONCAT('$', SUM(price)) AS total_spent
    FROM before_member_spent
    GROUP BY customer_id;
    ```

    | customer | item_purchased | total_spent |
    | -------- | -------------- | ----------- |
    | A        | 2              | $25         |
    | B        | 3              | $40         |

<br>

1. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

    -

    <br>

    ```sql
    WITH points_table
    AS (SELECT customer_id,
            price,
            CASE
                WHEN product_name = 'sushi' THEN
            ((price * 10) * 2)
                ELSE
            (price * 10)
            END AS points
        FROM #sales_menu_table
    )
    SELECT customer_id AS customer,
        SUM(points) AS total_points
    FROM points_table
    GROUP BY customer_id;

    ```

    | customer | total_points |
    | -------- | ------------ |
    | A        | 860          |
    | B        | 940          |
    | C        | 360          |

<br>

1.  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

    -

    <br>

    ```sql
    WITH member_week1
    AS (SELECT members.customer_id AS customer_id,
            members.join_date AS join_date,
            DATEADD(day, 7, join_date) AS first_week,
            sales.order_date AS order_date,
            sales.product_id AS product_id
        FROM dannys_diner.members AS members
            JOIN #sales_menu_table AS sales
                ON members.customer_id = sales.customer_id
    ),
        points
    AS (SELECT customer_id,
            join_date,
            first_week,
            order_date,
            menu.product_name,
            menu.price,
            CASE
                WHEN menu.product_name = 'sushi'
                        AND order_date
                        BETWEEN join_date AND first_week THEN
            (((menu.price * 10) * 2) * 2)
                WHEN order_date
                        BETWEEN join_date AND first_week THEN
            ((menu.price * 10) * 2)
                WHEN menu.product_name = 'sushi' THEN
            ((menu.price * 10) * 2)
                ELSE
                    menu.price * 10
            END AS point
        FROM member_week1 AS member
            JOIN dannys_diner.menu AS menu
                ON member.product_id = menu.product_id
    )
    SELECT customer_id,
        Sum(point) AS total_points
    FROM points
    GROUP BY customer_id;
    ```

    | customer_id | total_points |
    | ----------- | ------------ |
    | A           | 1370         |
    | B           | 1260         |
