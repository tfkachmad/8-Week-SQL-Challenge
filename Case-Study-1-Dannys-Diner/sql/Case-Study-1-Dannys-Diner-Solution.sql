--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 1 - Danny's Diner
--
-- 1. What is the total amount each customer spent at the restaurant?
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

--
-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_num
FROM
    dannys_diner.sales
GROUP BY
    1;

--
-- 3. What was the first item from the menu purchased by each customer?
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

--
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
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

-- Or,
SELECT
    m.product_name,
    COUNT(s.product_id) AS sold_total
FROM
    dannys_diner.sales AS s
    JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY
    m.product_name
ORDER BY
    COUNT(s.product_id) DESC
LIMIT 1;

--
-- 5. Which item was the most popular for each customer?
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

--
-- 6. Which item was purchased first by the customer after they became a member?
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

--
-- 7. Which item was purchased just before the customer became a member?
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

--
--  8.  What is the total items and amount spent for each member before they became a member?
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

--
--  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier
--      how many points would each customer have?
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

--
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- 		not just sushi - how many points do customer A and B have at the end of January?
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

--
-- Bonus Questions - Join all
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

--
-- Bonus Questions - Ranking
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
