USE EightWeekSQLChallenge;
--
/*
	========	A. HIGH LEVEL SALES ANALYSIS	========
*/
--
--	1.	What was the total quantity sold for all products?
SELECT p.product_name
	,SUM(s.qty) AS total_sold
FROM balanced_tree.sales AS s
JOIN balanced_tree.product_details AS p
	ON s.prod_id = p.product_id
GROUP BY p.product_id
	,p.product_name
ORDER BY p.product_id;
/*
	product_name                     total_sold
	-------------------------------- -----------
	Blue Polo Shirt - Mens           3819
	Pink Fluro Polkadot Socks - Mens 3770
	White Tee Shirt - Mens           3800
	Indigo Rain Jacket - Womens      3757
	Grey Fashion Jacket - Womens     3876
	White Striped Socks - Mens       3655
	Navy Oversized Jeans - Womens    3856
	Teal Button Up Shirt - Mens      3646
	Khaki Suit Jacket - Womens       3752
	Cream Relaxed Jeans - Womens     3707
	Black Straight Jeans - Womens    3786
	Navy Solid Socks - Mens          3792
*/
--
--	2.	What is the total generated revenue for all products before discounts?
WITH revenue_CTE
AS (
	SELECT p.product_id
		,p.product_name
		,(s.qty * s.price) AS revenue
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	)
SELECT product_name
	,FORMAT(SUM(revenue), '#,#') AS total_revenue
FROM revenue_CTE
GROUP BY product_id
	,product_name
ORDER BY product_id;
/*
	product_name                     total_revenue
	-------------------------------- --------------------
	Blue Polo Shirt - Mens           217,683
	Pink Fluro Polkadot Socks - Mens 109,330
	White Tee Shirt - Mens           152,000
	Indigo Rain Jacket - Womens      71,383
	Grey Fashion Jacket - Womens     209,304
	White Striped Socks - Mens       62,135
	Navy Oversized Jeans - Womens    50,128
	Teal Button Up Shirt - Mens      36,460
	Khaki Suit Jacket - Womens       86,296
	Cream Relaxed Jeans - Womens     37,070
	Black Straight Jeans - Womens    121,152
	Navy Solid Socks - Mens          136,512
*/
--
--	3.	What was the total discount amount for all products?
WITH discount_CTE
AS (
	SELECT p.product_id
		,p.product_name
		,(s.qty * s.price * (CAST(s.discount AS FLOAT) / 100)) AS discount
	FROM balanced_tree.sales AS s
	JOIN balanced_tree.product_details AS p
		ON s.prod_id = p.product_id
	)
SELECT product_name
	,FORMAT(SUM(discount), '#,#.00') AS total_discount
FROM discount_CTE
GROUP BY product_id
	,product_name
ORDER BY product_id;
/*
	product_name                     total_discount
	-------------------------------- ---------------
	Blue Polo Shirt - Mens           26,819.07
	Pink Fluro Polkadot Socks - Mens 12,952.27
	White Tee Shirt - Mens           18,377.60
	Indigo Rain Jacket - Womens      8,642.53
	Grey Fashion Jacket - Womens     25,391.88
	White Striped Socks - Mens       7,410.81
	Navy Oversized Jeans - Womens    6,135.61
	Teal Button Up Shirt - Mens      4,397.60
	Khaki Suit Jacket - Womens       10,243.05
	Cream Relaxed Jeans - Womens     4,463.40
	Black Straight Jeans - Womens    14,744.96
	Navy Solid Socks - Mens          16,650.36
*/
