USE EightWeekSQLChallenge;
--
/*
	========	B. DIGITAL ANALYSIS		========
*/
--
--	 1.	How many users are there?
SELECT COUNT(DISTINCT [user_id]) AS users_count
FROM clique_bait.users;
/*
	users_count
	-----------
	500
*/
--
--	 2.	How many cookies does each user have on average?
WITH user_cookies_CTE
AS (
	SELECT [user_id]
		,COUNT(cookie_id) AS cookies
	FROM clique_bait.users
	GROUP BY [user_id]
	)
SELECT AVG(cookies) AS user_average_cookies
FROM user_cookies_CTE;
/*
	user_average_cookies
	--------------------
	3
*/
--
--	 3.	What is the unique number of visits by all users per month?
WITH month_cte
AS (
	SELECT visit_id
		,event_time
		,DATEPART(MONTH, event_time) AS month_num
		,DATENAME(MONTH, event_time) AS [month]
	FROM clique_bait.[events]
	)
SELECT [month]
	,COUNT(DISTINCT visit_id) AS unique_visits_count
FROM month_cte
GROUP BY month_num
	,[month]
ORDER BY month_num;
/*
	month                          unique_visits_count
	------------------------------ -------------------
	January                        876
	February                       1488
	March                          916
	April                          248
	May                            36
*/
--
--	 4.	What is the number of events for each event type?
SELECT ei.event_name
	,COUNT(*) AS events_count
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
	ON e.event_type = ei.event_type
GROUP BY ei.event_type
	,ei.event_name
ORDER BY ei.event_type;
/*
	event_name    events_count
	------------- ------------
	Page View     20928
	Add to Cart   8451
	Purchase      1777
	Ad Impression 876
	Ad Click      702
*/
--
--	 5.	What is the percentage of visits which have a purchase event?
WITH purchase_CTE
AS (
	SELECT CAST(COUNT(*) AS FLOAT) AS purchase_events
	FROM clique_bait.events AS e
	JOIN clique_bait.event_identifier AS ei
		ON e.event_type = ei.event_type
	WHERE ei.event_name LIKE 'purchase'
	)
	,total_events_CTE
AS (
	SELECT COUNT(*) AS total_events
	FROM clique_bait.events
	)
SELECT CONCAT (
		ROUND((
				purchase_events / (
					SELECT total_events
					FROM total_events_CTE
					) * 100
				), 2)
		,'%'
		) AS purchase_events_percentage
FROM purchase_CTE;
/*
	purchase_events_percentage
	--------------------------
	5.43%
*/
--
--	 6.	What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH purchase_CTE
AS (
	SELECT DISTINCT e.visit_id
	FROM clique_bait.events AS e
	JOIN clique_bait.event_identifier AS ei
		ON e.event_type = ei.event_type
	WHERE ei.event_name LIKE 'purchase'
	)
	,checkout_CTE
AS (
	SELECT CAST(COUNT(*) AS FLOAT) AS checkout_only_events
	FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS p
		ON e.page_id = p.page_id
	WHERE p.page_name LIKE 'checkout'
		AND e.visit_id NOT IN (
			SELECT visit_id
			FROM purchase_CTE
			)
	)
	,total_events_CTE
AS (
	SELECT COUNT(*) AS total_events
	FROM clique_bait.events
	)
SELECT CONCAT (
		ROUND((
				checkout_only_events / (
					SELECT total_events
					FROM total_events_CTE
					) * 100
				), 2)
		,'%'
		) AS checkout_only_events_percentage
FROM checkout_CTE;
/*
	checkout_only_events_percentage
	-------------------------------
	1%
*/
--
--	 7.	What are the top 3 pages by number of views?
WITH pages_view_CTE
AS (
	SELECT p.page_name
		,COUNT(*) AS views_count
	FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS p
		ON e.page_id = p.page_id
	GROUP BY p.page_name
	)
	,rank_CTE
AS (
	SELECT page_name
		,views_count
		,RANK() OVER (
			ORDER BY views_count DESC
			) AS views_count_rank
	FROM pages_view_CTE
	)
SELECT page_name
	,views_count
FROM rank_CTE
WHERE views_count_rank <= 3
ORDER BY views_count_rank;
/*
	page_name      views_count
	-------------- -----------
	All Products   4752
	Lobster        2515
	Crab           2513
*/
--
--	 8.	What is the number of views and cart adds for each product category?
WITH views_CTE
AS (
	SELECT p.product_category
		,COUNT(*) AS views_count
	FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS p
		ON e.page_id = p.page_id
	GROUP BY p.product_category
	)
	,add_to_cart_CTE
AS (
	SELECT p.product_category
		,COUNT(*) AS add_to_cart_count
	FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS p
		ON e.page_id = p.page_id
	JOIN clique_bait.event_identifier AS ei
		ON e.event_type = ei.event_type
	WHERE ei.event_name LIKE 'Add%'
	GROUP BY p.product_category
	)
SELECT t1.product_category
	,views_count
	,add_to_cart_count
FROM views_CTE AS t1
LEFT JOIN add_to_cart_CTE AS t2
	ON t1.product_category = t2.product_category;
/*
	product_category views_count add_to_cart_count
	---------------- ----------- -----------------
	NULL             10414       NULL
	Fish             7422        2789
	Shellfish        9996        3792
	Luxury           4902        1870
*/
--
--	 9.	What are the top 3 products by purchases?
WITH purchase_CTE
AS (
	SELECT DISTINCT visit_id
	FROM clique_bait.events AS e
	JOIN clique_bait.event_identifier AS ei
		ON e.event_type = ei.event_type
	WHERE ei.event_name LIKE 'Purchase'
	)
	,products_CTE
AS (
	SELECT p.page_name
		,COUNT(*) AS product_purchased
	FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS p
		ON e.page_id = p.page_id
	JOIN clique_bait.event_identifier AS ei
		ON e.event_type = ei.event_type
	WHERE p.product_category IS NOT NULL
		AND ei.event_name LIKE 'Add%'
		AND e.visit_id IN (
			SELECT visit_id
			FROM purchase_CTE
			)
	GROUP BY p.page_name
	)
	,rank_CTE
AS (
	SELECT page_name
		,product_purchased
		,RANK() OVER (
			ORDER BY product_purchased DESC
			) AS product_rank
	FROM products_CTE
	)
SELECT page_name
	,product_purchased
FROM rank_CTE
WHERE product_rank <= 3;
/*
	page_name      product_purchased
	-------------- -----------------
	Lobster        754
	Oyster         726
	Crab           719
*/
