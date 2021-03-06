# :ramen: Case Study 1 - Danny's Dinner Solution

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

## :pencil2: Preparation

- Create a temp table to join `sales` and `menu` table. Also, add order number for each order by customer.

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

    - Sum the price of each items from the `#sales_menu_table` and group it by each customer

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

2. How many days has each customer visited the  restaurant?

    - Count the distinct of each order from the `sales` table and group it by each customer

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

    - Find the `row_order = 1` for each customer

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

    - Count the number of each order occured and group it by the product name
    - Order the count result descending and `SELECT TOP 1` the product name and the count

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

    - `RANK()` the count of order by each customer
    - Find the rank that is equal to 1 for each customer and the product name

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

    - Find each customer order from `#sales_menu_table` that occured after they become member from `member` table
    - `RANK()` the order date by each member
    - Find the rank result that equal to 1 for each member and display their id and the product they order

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

    <p align="center">

    | customer | product_name |
    | -------- | ------------ |
    | A        | curry        |
    | B        | sushi        |

<br>

7. Which item was purchased just before the customer became a member?

    - Find each customer order from `#sales_menu_table` that occured before they become member from `member` table
    - `RANK()` the order date by each member to find their latest order before became a member
    - Find the rank result that equal to 1 for each member and display their id and the product they order

    <br>

    ```sql
    WITH before_member_purchase
    AS (SELECT RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS rank_member,
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

    | customer_id | product_name |
    | ----------- | ------------ |
    | A           | sushi        |
    | A           | curry        |
    | B           | sushi        |

<br>

8. What is the total items and amount spent for each member before they became a member?

    - Find each customer data from `#sales_menu_table` that occured before they become member from `member` table
    - Count each item purchased by each member
    - Sum the price of each item purchased by each member

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

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

    - Find the points for orders each customer made
    - Sum the total points each customer made from their orders

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

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

    - Create a CTE for each customer, their join date, and add their join date by 7 using `DATEADD`
    - Find the points each customer made for their orders based on the required condition above
    - Sum the total points from each order customer made

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

    <p align="center">

    | customer_id | total_points |
    | ----------- | ------------ |
    | A           | 1370         |
    | B           | 1260         |

## Bonus Question

### Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

<details>
<summary>Click to expand</summary>

| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

</details>

- Query:

    ```sql
    DROP TABLE
    IF EXISTS #all_table_join;
        SELECT sales_menu.customer_id
            ,sales_menu.order_date
            ,sales_menu.product_name
            ,sales_menu.price
            ,member.join_date
            ,CASE
                WHEN member.join_date IS NOT NULL
                    AND sales_menu.order_date >= member.join_date
                    THEN 'Y'
                WHEN member.join_date IS NOT NULL
                    AND sales_menu.order_date < member.join_date
                    THEN 'N'
                ELSE 'N'
                END AS member
        INTO #all_table_join
        FROM #sales_menu_table AS sales_menu
        LEFT JOIN dannys_diner.members AS member
            ON sales_menu.customer_id = member.customer_id;
    ```

- Result:

    | customer_id | order_date | product_name | price | join_date  | member |
    | ----------- | ---------- | ------------ | ----- | ---------- | ------ |
    | A           | 2021-01-01 | sushi        | 10    | 2021-01-07 | N      |
    | A           | 2021-01-01 | curry        | 15    | 2021-01-07 | N      |
    | A           | 2021-01-07 | curry        | 15    | 2021-01-07 | Y      |
    | A           | 2021-01-10 | ramen        | 12    | 2021-01-07 | Y      |
    | A           | 2021-01-11 | ramen        | 12    | 2021-01-07 | Y      |
    | A           | 2021-01-11 | ramen        | 12    | 2021-01-07 | Y      |
    | B           | 2021-01-01 | curry        | 15    | 2021-01-09 | N      |
    | B           | 2021-01-02 | curry        | 15    | 2021-01-09 | N      |
    | B           | 2021-01-04 | sushi        | 10    | 2021-01-09 | N      |
    | B           | 2021-01-11 | sushi        | 10    | 2021-01-09 | Y      |
    | B           | 2021-01-16 | ramen        | 12    | 2021-01-09 | Y      |
    | B           | 2021-02-01 | ramen        | 12    | 2021-01-09 | Y      |
    | C           | 2021-01-01 | ramen        | 12    | NULL       | N      |
    | C           | 2021-01-01 | ramen        | 12    | NULL       | N      |
    | C           | 2021-01-07 | ramen        | 12    | NULL       | N      |

<br/>

### Rank All The Things

Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

<details>
<summary>Click to expand</summary>

| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      | null    |
| A           | 2021-01-01 | sushi        | 10    | N      | null    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | null    |
| B           | 2021-01-02 | curry        | 15    | N      | null    |
| B           | 2021-01-04 | sushi        | 10    | N      | null    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-07 | ramen        | 12    | N      | null    |

</details>

- Query:

    ```sql
    DROP TABLE
    IF EXISTS #all_table_join_rank;
        SELECT *
            ,CASE
                WHEN member LIKE 'Y'
                    THEN RANK() OVER (
                            PARTITION BY customer_id
                            ,member ORDER BY order_date
                            )
                ELSE NULL
                END AS ranking
        INTO #all_table_join_rank
        FROM #all_table_join;
    ```

- Result:

    | customer_id | order_date | product_name | price | join_date  | member | ranking |
    | ----------- | ---------- | ------------ | ----- | ---------- | ------ | ------- |
    | A           | 2021-01-01 | sushi        | 10    | 2021-01-07 | N      | NULL    |
    | A           | 2021-01-01 | curry        | 15    | 2021-01-07 | N      | NULL    |
    | A           | 2021-01-07 | curry        | 15    | 2021-01-07 | Y      | 1       |
    | A           | 2021-01-10 | ramen        | 12    | 2021-01-07 | Y      | 2       |
    | A           | 2021-01-11 | ramen        | 12    | 2021-01-07 | Y      | 3       |
    | A           | 2021-01-11 | ramen        | 12    | 2021-01-07 | Y      | 3       |
    | B           | 2021-01-01 | curry        | 15    | 2021-01-09 | N      | NULL    |
    | B           | 2021-01-02 | curry        | 15    | 2021-01-09 | N      | NULL    |
    | B           | 2021-01-04 | sushi        | 10    | 2021-01-09 | N      | NULL    |
    | B           | 2021-01-11 | sushi        | 10    | 2021-01-09 | Y      | 1       |
    | B           | 2021-01-16 | ramen        | 12    | 2021-01-09 | Y      | 2       |
    | B           | 2021-02-01 | ramen        | 12    | 2021-01-09 | Y      | 3       |
    | C           | 2021-01-01 | ramen        | 12    | NULL       | N      | NULL    |
    | C           | 2021-01-01 | ramen        | 12    | NULL       | N      | NULL    |
    | C           | 2021-01-07 | ramen        | 12    | NULL       | N      | NULL    |

---
