USE EightWeekSQLChallenge;
--
/*
	========	C. PRODUCT ANALYSIS		========
*/
--
--	1.	What are the top 3 products by total revenue before discount?
WITH revenue_CTE
AS (
	SELECT p.product_name
		,SUM((s.qty * s.price)) AS revenue_total
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.product_name
	)
	,row_CTE
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY revenue_total DESC
			) AS row_num
		,product_name
		,FORMAT(revenue_total, '#,#') AS revenue_total
	FROM revenue_CTE
	)
SELECT product_name
	,revenue_total
FROM row_CTE
WHERE row_num <= 3;
/*
	product_name                     revenue_total
	-------------------------------- --------------
	Blue Polo Shirt - Mens           217,683
	Grey Fashion Jacket - Womens     209,304
	White Tee Shirt - Mens           152,000
*/
--
--	2.	What is the total quantity, revenue and discount for each segment?
WITH sub_CTE
AS (
	SELECT p.segment_id
		,p.segment_name
		,SUM(s.qty) AS quantity
		,SUM(s.qty * s.price) AS revenue
		,SUM(s.qty * s.price * (CAST(s.discount AS FLOAT) / 100)) AS discount
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id
		,p.segment_name
	)
SELECT segment_name
	,quantity AS total_quantity
	,FORMAT(revenue, '#,#') AS total_revenue
	,FORMAT(discount, '#,#.##') AS total_discount
FROM sub_CTE
ORDER BY segment_id;
/*
	segment_name quantity    revenue	 discount
	------------ ----------- ----------- -----------
	Jeans        11349       208,350	 25,343.97
	Jacket       11385       366,983	 44,277.46
	Shirt        11265       406,143	 49,594.27
	Socks        11217       307,977	 37,013.44      
*/
--
--	3.	What is the top selling product for each segment?
WITH sold_CTE
AS (
	SELECT p.segment_id
		,p.segment_name
		,p.product_name
		,SUM(s.qty) AS sold
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id
		,p.segment_name
		,p.product_name
	)
	,row_CTE
AS (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY segment_id ORDER BY sold DESC
			) AS row_num
		,*
	FROM sold_CTE
	)
SELECT segment_name
	,product_name
	,sold
FROM row_CTE
WHERE row_num = 1
ORDER BY segment_id;
/*
	segment_name product_name                     sold
	------------ -------------------------------- -----------
	Jeans        Navy Oversized Jeans - Womens    3856
	Jacket       Grey Fashion Jacket - Womens     3876
	Shirt        Blue Polo Shirt - Mens           3819
	Socks        Navy Solid Socks - Mens          3792
*/
--
--	4.	What is the total quantity, revenue and discount for each category?
WITH sub_CTE
AS (
	SELECT p.category_id
		,p.category_name
		,SUM(s.qty) AS quantity
		,SUM(s.qty * s.price) AS revenue
		,SUM(s.qty * s.price * (CAST(s.discount AS FLOAT) / 100)) AS discount
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.category_id
		,p.category_name
	)
SELECT category_name
	,quantity AS total_quantity
	,FORMAT(revenue, '#,#') AS total_revenue
	,FORMAT(discount, '#,#.##') AS total_discount
FROM sub_CTE
ORDER BY category_id;
--
--	5.	What is the top selling product for each category?
WITH sold_CTE
AS (
	SELECT p.category_id
		,p.category_name
		,p.product_name
		,SUM(s.qty) AS sold
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.category_id
		,p.category_name
		,p.product_name
	)
	,row_CTE
AS (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY category_id ORDER BY sold DESC
			) AS row_num
		,*
	FROM sold_CTE
	)
SELECT category_name
	,product_name
	,sold
FROM row_CTE
WHERE row_num = 1
ORDER BY category_id;
/*
	category_name product_name                     sold
	------------- -------------------------------- -----------
	Womens        Grey Fashion Jacket - Womens     3876
	Mens          Blue Polo Shirt - Mens           3819
*/
--
--	6.	What is the percentage split of revenue by product for each segment?
WITH revenue_CTE
AS (
	SELECT p.segment_id
		,p.segment_name
		,p.product_id
		,p.product_name
		,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id
		,p.segment_name
		,p.product_id
		,p.product_name
	)
	,calc_CTE
AS (
	SELECT segment_id
		,segment_name
		,product_id
		,product_name
		,revenue
		,(
			revenue / (
				SELECT SUM(revenue)
				FROM revenue_CTE
				)
			) AS revenue_pct
	FROM revenue_CTE
	)
SELECT segment_name
	,product_name
	,FORMAT(revenue, '#,#.#0') AS revenue
	,FORMAT(revenue_pct, 'p') AS revenue_pct
FROM calc_CTE
ORDER BY segment_id
	,product_id;
/*
	segment_name product_name                     revenue     revenue_pct
	------------ -------------------------------- ----------- -----------
	Jeans        Navy Oversized Jeans - Womens    43,992.39	  3.88%
	Jeans        Cream Relaxed Jeans - Womens     32,606.60   2.88%
	Jeans        Black Straight Jeans - Womens    106,407.04  9.39%
	Jacket       Indigo Rain Jacket - Womens      62,740.47   5.54%
	Jacket       Grey Fashion Jacket - Womens     183,912.12  16.23%
	Jacket       Khaki Suit Jacket - Womens       76,052.95   6.71%
	Shirt        Blue Polo Shirt - Mens           190,863.93  16.84%
	Shirt        White Tee Shirt - Mens           133,622.40  11.79%
	Shirt        Teal Button Up Shirt - Mens      32,062.40   2.83%
	Socks        Pink Fluro Polkadot Socks - Mens 96,377.73   8.50%
	Socks        White Striped Socks - Mens       54,724.19   4.83%
	Socks        Navy Solid Socks - Mens          119,861.64  10.58%
*/
--
--	7.	What is the percentage split of revenue by segment for each category?
WITH revenue_CTE
AS (
	SELECT p.category_id
		,p.category_name
		,p.segment_id
		,p.segment_name
		,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.category_id
		,p.category_name
		,p.segment_id
		,p.segment_name
	)
	,calc_CTE
AS (
	SELECT segment_id
		,segment_name
		,category_id
		,category_name
		,revenue
		,(
			revenue / (
				SELECT SUM(revenue)
				FROM revenue_CTE
				)
			) AS revenue_pct
	FROM revenue_CTE
	)
SELECT category_name
	,segment_name
	,FORMAT(revenue, '#,#.#0') AS revenue
	,FORMAT(revenue_pct, 'p') AS revenue_pct
FROM calc_CTE
ORDER BY segment_id
	,category_id;
/*
	category_name segment_name revenue    revenue_pct
	------------- ------------ ---------- -----------
	Womens        Jeans        183,006.03 16.15%
	Womens        Jacket       322,705.54 28.48%
	Mens          Shirt        356,548.73 31.46%
	Mens          Socks        270,963.56 23.91%
*/
--
--	8.	What is the percentage split of total revenue by category?
WITH revenue_CTE
AS (
	SELECT p.category_id
		,p.category_name
		,SUM((s.qty * s.price) - (s.qty * s.price * (CAST(s.discount AS FLOAT) / 100))) AS revenue
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.category_id
		,p.category_name
	)
	,calc_CTE
AS (
	SELECT category_id
		,category_name
		,revenue
		,(
			revenue / (
				SELECT SUM(revenue)
				FROM revenue_CTE
				)
			) AS revenue_pct
	FROM revenue_CTE
	)
SELECT category_name
	,FORMAT(revenue, '#,#.##') AS revenue
	,FORMAT(revenue_pct, 'p') AS revenue_pct
FROM calc_CTE
ORDER BY category_id;
/*
	category_name revenue    revenue_pct
	------------- ---------- -----------
	Womens        505,711.57 44.63%
	Mens          627,512.29 55.37%
*/
--
--	9.	What is the total transaction ?penetration? for each product?
--		(hint: penetration = number of transactions where at least 1 quantity of a product 
--		was purchased divided by total number of transactions)
WITH trx_CTE
AS (
	SELECT p.product_id
		,p.product_name
		,CAST(COUNT(p.product_name) AS FLOAT) AS trx_cnt
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	GROUP BY p.product_id
		,p.product_name
	)
SELECT product_name
	,FORMAT((
			trx_cnt / (
				SELECT COUNT(DISTINCT txn_id)
				FROM balanced_tree.sales
				)
			), 'p') AS penetration_pct
FROM trx_CTE
ORDER BY product_id;
/*
	product_name                     penetration_pct
	-------------------------------- ----------------
	Blue Polo Shirt - Mens           50.72%
	Pink Fluro Polkadot Socks - Mens 50.32%
	White Tee Shirt - Mens           50.72%
	Indigo Rain Jacket - Womens      50.00%
	Grey Fashion Jacket - Womens     51.00%
	White Striped Socks - Mens       49.72%
	Navy Oversized Jeans - Womens    50.96%
	Teal Button Up Shirt - Mens      49.68%
	Khaki Suit Jacket - Womens       49.88%
	Cream Relaxed Jeans - Womens     49.72%
	Black Straight Jeans - Womens    49.84%
	Navy Solid Socks - Mens          51.24%
*/
--
--	10.	What is the most common combination of at least 1 quantity of any 3 products 
--		in a 1 single transaction?
WITH product_CTE
AS (
	SELECT s.txn_id
		,p.product_id
		,p.product_name
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	)
	,combination_CTE
AS (
	SELECT p1.product_name AS product_name_1
		,p2.product_name AS product_name_2
		,p3.product_name AS product_name_3
		,COUNT(*) AS cnt
	FROM product_CTE AS p1
	JOIN product_CTE AS p2
		ON p1.txn_id = p2.txn_id
			AND p1.product_id < p2.product_id
	JOIN product_CTE AS p3
		ON p2.txn_id = p3.txn_id
			AND p2.product_id < p3.product_id
	GROUP BY p1.product_name
		,p2.product_name
		,p3.product_name
	)
	,row_CTE
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY cnt DESC
			) AS rn
		,*
	FROM combination_CTE
	)
SELECT product_name_1
	,product_name_2
	,product_name_3
	,cnt AS trx_cnt
FROM row_CTE
WHERE rn = 1;
/*
	product_name_1                   product_name_2                   product_name_3                   trx_cnt
	-------------------------------- -------------------------------- -------------------------------- -----------
	White Tee Shirt - Mens           Grey Fashion Jacket - Womens     Teal Button Up Shirt - Mens      352
*/
