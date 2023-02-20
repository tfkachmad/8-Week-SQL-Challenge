# :ramen: Case Study 1 - Danny's Dinner Solution

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

## :tada: Solution

1. What is the total amount each customer spent at the restaurant?

    ```sql
    SELECT
        s.customer_id AS customer,
        SUM(m.price) AS total_spent
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
    GROUP BY
        1
    ORDER BY
        1;
    ```

    | "customer" | "total_spent" |
    |------------|---------------|
    | A          | 76            |
    | B          | 74            |
    | C          | 36            |

    <br>

2. How many days has each customer visited the  restaurant?

    ```sql
    SELECT
        customer_id,
        COUNT(DISTINCT order_date) AS visit_num
    FROM
        dannys_diner.sales
    GROUP BY
        1;
    ```

    | "customer_id" | "visit_num" |
    |---------------|-------------|
    | A             | 4           |
    | B             | 6           |
    | C             | 2           |

3. What was the first item from the menu purchased by each customer?

    ```sql
    SELECT DISTINCT
        s.customer_id,
        m.product_name AS first_purchase
    FROM (
        SELECT
            customer_id, product_id,
            RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS ranking
        FROM
            dannys_diner.sales) AS s
        JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
    WHERE
        s.ranking = 1;
    ```

    | "customer_id" | "first_purchase" |
    |---------------|------------------|
    | A             | curry            |
    | A             | sushi            |
    | B             | curry            |
    | C             | ramen            |

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

    ```sql
    SELECT
        m.product_name,
        COUNT(s.product_id) AS purchased_total
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
    GROUP BY
        1
    ORDER BY
        2 DESC
    LIMIT 1;
    ```

    | "product_name" | "sold_total" |
    |----------------|--------------|
    | ramen          | 8            |

5. Which item was the most popular for each customer?

    ```sql
    WITH product_cte AS (
        SELECT
            customer_id,
            product_id,
            num,
            RANK() OVER (PARTITION BY customer_id ORDER BY num DESC) AS ranking
        FROM (
            SELECT
                customer_id,
                product_id,
                COUNT(product_id) AS num
            FROM
                dannys_diner.sales
            GROUP BY
                customer_id,
                product_id) AS s
    )
    SELECT
        p.customer_id,
        m.product_name
    FROM
        product_cte AS p
        JOIN dannys_diner.menu AS m ON p.product_id = m.product_id
    WHERE
        p.ranking = 1
    ORDER BY
        1;
    ```

    | "customer_id" | "product_name" |
    |---------------|----------------|
    | A             | ramen          |
    | B             | sushi          |
    | B             | curry          |
    | B             | ramen          |
    | C             | ramen          |

6. Which item was purchased first by the customer after they became a member?

    ```sql
    WITH sales_cte AS (
    SELECT
        s1.customer_id,
        s1.order_date,
        s1.product_id,
        RANK() OVER (PARTITION BY s1.customer_id ORDER BY s1.order_date) AS ranking
    FROM
        dannys_diner.sales AS s1
        JOIN dannys_diner.members AS m1 ON s1.customer_id = m1.customer_id
            AND s1.order_date >= m1.join_date
    )
    SELECT
        s2.customer_id,
        m2.product_name
    FROM
        sales_cte AS s2
        JOIN dannys_diner.menu AS m2 ON s2.product_id = m2.product_id
    WHERE
        ranking = 1
    ORDER BY
        1;
    ```

    | "customer_id" | "product_name" |
    |---------------|----------------|
    | A             | curry          |
    | B             | sushi          |

7. Which item was purchased just before the customer became a member?

    ```sql
    WITH sales_cte AS (
    SELECT
        s1.customer_id,
        s1.order_date,
        s1.product_id,
        RANK() OVER (PARTITION BY s1.customer_id ORDER BY s1.order_date DESC) AS ranking
    FROM
        dannys_diner.sales AS s1
        JOIN dannys_diner.members AS m1 ON s1.customer_id = m1.customer_id
            AND s1.order_date < m1.join_date
    )
    SELECT
        s2.customer_id,
        m2.product_name
    FROM
        sales_cte AS s2
        JOIN dannys_diner.menu AS m2 ON s2.product_id = m2.product_id
    WHERE
        ranking = 1
    ORDER BY
        1;
    ```

    | "customer_id" | "product_name" |
    |---------------|----------------|
    | A             | sushi          |
    | A             | curry          |
    | B             | sushi          |

8. What is the total items and amount spent for each member before they became a member?

    - Find each customer data from `#sales_menu_table` that occured before they become member from `member` table
    - Count each item purchased by each member
    - Sum the price of each item purchased by each member

    ```sql
    SELECT
        s.customer_id,
        COUNT(*) AS items_total,
        SUM(price) AS spent_total
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.members AS m1 ON s.customer_id = m1.customer_id
            AND s.order_date < m1.join_date
        JOIN dannys_diner.menu AS m2 ON s.product_id = m2.product_id
    GROUP BY
        1
    ORDER BY
        1;
    ```

    | "customer_id" | "items_total" | "spent_total" |
    |---------------|---------------|---------------|
    | A             | 2             | 25            |
    | B             | 3             | 40            |

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

    ```sql
    SELECT
        s.customer_id,
        SUM(
            CASE WHEN m.product_name = 'sushi' THEN
                (m.price * 20)
            ELSE
                m.price * 10
            END) AS points_total
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id
    ORDER BY
        customer_id;
    ```

    | "customer_id" | "points_total" |
    |---------------|----------------|
    | A             | 860            |
    | B             | 940            |
    | C             | 360            |

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

    ```sql
    WITH sales_cte AS (
    SELECT
        s.customer_id,
        s.order_date,
        m1.join_date,
        (m1.join_date + INTERVAL '6 DAY') AS first_week,
        m2.price,
        m2.product_name
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.members AS m1 ON s.customer_id = m1.customer_id
        JOIN dannys_diner.menu AS m2 ON s.product_id = m2.product_id
    WHERE
        s.order_date < '2021-02-01'
    )
    SELECT
        customer_id,
        SUM(
            CASE WHEN product_name = 'sushi'
                OR order_date BETWEEN join_date AND first_week THEN
                (price * 20)
            ELSE
                (price * 10)
            END) AS points_total
    FROM
        sales_cte
    GROUP BY
        1
    ORDER BY
        1;
    ```

    | "customer_id" | "points_total" |
    |---------------|----------------|
    | A             | 1370           |
    | B             | 820            |

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
    SELECT
        s.customer_id,
        s.order_date,
        m1.product_name,
        m1.price,
        CASE WHEN m2.join_date IS NULL
            OR s.order_date < m2.join_date THEN
            'N'
        ELSE
            'Y'
        END AS member
    FROM
        dannys_diner.sales AS s
        JOIN dannys_diner.menu AS m1 ON s.product_id = m1.product_id
        LEFT JOIN dannys_diner.members AS m2 ON s.customer_id = m2.customer_id
    ORDER BY
        1,
        2;
    ```

- Result:

    | "customer_id" | "order_date" | "product_name" | "price" | "member" |
    |---------------|--------------|----------------|---------|----------|
    | A             | 2021-01-01   | sushi          | 10      | N        |
    | A             | 2021-01-01   | curry          | 15      | N        |
    | A             | 2021-01-07   | curry          | 15      | Y        |
    | A             | 2021-01-10   | ramen          | 12      | Y        |
    | A             | 2021-01-11   | ramen          | 12      | Y        |
    | A             | 2021-01-11   | ramen          | 12      | Y        |
    | B             | 2021-01-01   | curry          | 15      | N        |
    | B             | 2021-01-02   | curry          | 15      | N        |
    | B             | 2021-01-04   | sushi          | 10      | N        |
    | B             | 2021-01-11   | sushi          | 10      | Y        |
    | B             | 2021-01-16   | ramen          | 12      | Y        |
    | B             | 2021-02-01   | ramen          | 12      | Y        |
    | C             | 2021-01-01   | ramen          | 12      | N        |
    | C             | 2021-01-01   | ramen          | 12      | N        |
    | C             | 2021-01-07   | ramen          | 12      | N        |

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
    WITH complete_data AS (
        SELECT
            s.customer_id,
            s.order_date,
            m1.product_name,
            m1.price,
            CASE WHEN m2.join_date IS NULL
                OR s.order_date < m2.join_date THEN
                'N'
            ELSE
                'Y'
            END AS member
        FROM
            dannys_diner.sales AS s
            JOIN dannys_diner.menu AS m1 ON s.product_id = m1.product_id
            LEFT JOIN dannys_diner.members AS m2 ON s.customer_id = m2.customer_id
    )
    SELECT
        *,
        CASE WHEN member = 'Y' THEN
            RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
        ELSE
            NULL
        END AS ranking
    FROM
        complete_data;
    ```

- Result:

    | "customer_id" | "order_date" | "product_name" | "price" | "member" | "ranking" |
    |---------------|--------------|----------------|---------|----------|-----------|
    | A             | 2021-01-01   | sushi          | 10      | N        |           |
    | A             | 2021-01-01   | curry          | 15      | N        |           |
    | A             | 2021-01-07   | curry          | 15      | Y        | 1         |
    | A             | 2021-01-10   | ramen          | 12      | Y        | 2         |
    | A             | 2021-01-11   | ramen          | 12      | Y        | 3         |
    | A             | 2021-01-11   | ramen          | 12      | Y        | 3         |
    | B             | 2021-01-01   | curry          | 15      | N        |           |
    | B             | 2021-01-02   | curry          | 15      | N        |           |
    | B             | 2021-01-04   | sushi          | 10      | N        |           |
    | B             | 2021-01-11   | sushi          | 10      | Y        | 1         |
    | B             | 2021-01-16   | ramen          | 12      | Y        | 2         |
    | B             | 2021-02-01   | ramen          | 12      | Y        | 3         |
    | C             | 2021-01-01   | ramen          | 12      | N        |           |
    | C             | 2021-01-01   | ramen          | 12      | N        |           |
    | C             | 2021-01-07   | ramen          | 12      | N        |

---
