USE EightWeekSQLChallenge;
--
/*
	========	D. REPORTING CHALLENGE	========
*/
--
--	Write a single SQL script that combines all of the previous questions into a scheduled report 
--	that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s value
--
--	Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions 
--	at the end of every month.
--	He first wants you to generate the data for January only - but then he also wants you to demonstrate 
--	that you can easily run the same analysis for February without many changes (if at all).
--
--	Feel free to split up your final outputs into as many tables as you need 
--	- but be sure to explicitly reference which table outputs relate to which question for full marks :)
--
--	====	MONTHLY SUBSET DATA		====
--
DECLARE @MonthName AS VARCHAR(10) = 'January';
DROP TABLE
IF EXISTS #balanced_tree_sub;
	WITH sub_CTE
	AS (
		SELECT p.product_id
			,p.product_name
			,qty
			,s.price
			,discount
			,member
			,txn_id
			,DATENAME(month, start_txn_time) AS [month]
			,p.category_id
			,p.segment_id
			,p.style_id
			,p.category_name
			,p.style_name
			,p.segment_name
		FROM balanced_tree.sales AS s
		JOIN balanced_tree.product_details AS p
			ON prod_id = p.product_id
		WHERE DATENAME(month, start_txn_time) LIKE @MonthName
		)
	SELECT *
	INTO #balanced_tree_sub
	FROM sub_CTE;
--
--
--	====	HIGH LEVEL SALES ANALYSIS	====
--
DROP TABLE
IF EXISTS #high_level_sales;
	WITH high_level_sales_CTE
	AS (
		SELECT product_id
			,product_name
			,SUM(qty) AS total_sold
			,SUM((qty * price)) AS revenue_before_disc
			,SUM((qty * price * (CAST(discount AS FLOAT) / 100))) AS total_discount
		FROM #balanced_tree_sub
		GROUP BY product_id
			,product_name
		)
	SELECT @MonthName AS [month]
		,product_name
		,total_sold
		,FORMAT(revenue_before_disc, '#,#') AS revenue_before_disc
		,FORMAT(total_discount, '#.00') AS total_discount
	INTO #high_level_sales
	FROM high_level_sales_CTE
	ORDER BY product_id;
--
--	Result
SELECT *
FROM #high_level_sales;
/*
	month      product_name                     total_sold  revenue_before_disc total_discount
	---------- -------------------------------- ----------- ------------------- --------------
	January    Navy Oversized Jeans - Womens    1257        16,341              2023.84
	January    Blue Polo Shirt - Mens           1214        69,198              8523.78
	January    Cream Relaxed Jeans - Womens     1282        12,820              1595.80
	January    Grey Fashion Jacket - Womens     1300        70,200              8580.60
	January    Teal Button Up Shirt - Mens      1220        12,200              1539.00
	January    Black Straight Jeans - Womens    1238        39,616              4863.04
	January    White Tee Shirt - Mens           1256        50,240              6165.60
	January    Navy Solid Socks - Mens          1264        45,504              5557.32
	January    Khaki Suit Jacket - Womens       1225        28,175              3438.50
	January    Pink Fluro Polkadot Socks - Mens 1157        33,553              4091.61
	January    White Striped Socks - Mens       1150        19,550              2357.73
	January    Indigo Rain Jacket - Womens      1225        23,275              2852.28
*/
--
--	====	TRANSACTION ANALYSIS	====
--
--	TRANSACTIONS ANALYSIS
--
DROP TABLE
IF EXISTS #transaction_analysis;
	WITH unique_trx_CTE
	AS (
		SELECT COUNT(DISTINCT txn_id) AS unique_trx_cnt
		FROM #balanced_tree_sub
		)
		,products_CTE
	AS (
		SELECT txn_id
			,COUNT(DISTINCT product_id) AS unique_product_cnt
		FROM #balanced_tree_sub
		GROUP BY txn_id
		)
		,unique_product_CTE
	AS (
		SELECT AVG(unique_product_cnt) AS unique_products_avg
		FROM products_CTE
		)
		,revenue_discount_CTE
	AS (
		SELECT txn_id
			,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
			,SUM((qty * price * (CAST(discount AS FLOAT) / 100))) AS discount
		FROM #balanced_tree_sub
		GROUP BY txn_id
		)
		,percentile_CTE
	AS (
		SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_25_percentile
			,PERCENTILE_CONT(0.5) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_median
			,PERCENTILE_CONT(0.75) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_75_percentile
		FROM revenue_discount_CTE
		)
		,discount_CTE
	AS (
		SELECT FORMAT(AVG(discount), '##.##') AS discount_avg
		FROM revenue_discount_CTE
		)
		,result_CTE
	AS (
		SELECT DISTINCT (
				SELECT unique_trx_cnt
				FROM unique_trx_CTE
				) AS unique_trx_cnt
			,(
				SELECT unique_products_avg
				FROM unique_product_CTE
				) AS unique_products_avg
			,PERCENTILE_CONT(0.25) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_25_percentile
			,PERCENTILE_CONT(0.5) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_median
			,PERCENTILE_CONT(0.75) WITHIN
		GROUP (
				ORDER BY revenue
				) OVER () AS revenue_75_percentile
			,(
				SELECT discount_avg
				FROM discount_CTE
				) AS discount_avg
		FROM revenue_discount_CTE
		)
	SELECT @MonthName AS [month]
		,unique_trx_cnt
		,unique_products_avg
		,FORMAT(revenue_25_percentile, '#.#0') AS revenue_25_pctl
		,FORMAT(revenue_median, '#.#0') AS revenue_median
		,FORMAT(revenue_75_percentile, '#.#0') AS revenue_75_pctl
		,discount_avg
	INTO #transaction_analysis
	FROM result_CTE;
--
--	Result
SELECT *
FROM #transaction_analysis;
/*
	month      unique_trx_cnt unique_products_avg revenue_25_pctl revenue_median revenue_75_pctl                                                                                                                                                                                                                                                  discount_avg
	---------- -------------- ------------------- --------------- -------------- ---------------
	January    828            5                   313.17          434.10         563.69                                                                                                                                                                                                                                                           62.31
*/
--
--	MEMBER VS. NON-MEMBER TRANSACTIONS
DROP TABLE
IF EXISTS #member_trx_analysis;
	WITH trx_CTE
	AS (
		SELECT CASE 
				WHEN member = 1
					THEN 'Members'
				ELSE 'Non-Members'
				END AS members
			,COUNT(*) AS trx_cnt
		FROM #balanced_tree_sub
		GROUP BY CASE 
				WHEN member = 1
					THEN 'Members'
				ELSE 'Non-Members'
				END
		)
		,revenue_CTE
	AS (
		SELECT CASE 
				WHEN member = 1
					THEN 'Members'
				ELSE 'Non-Members'
				END AS members
			,(qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100)) AS revenue
		FROM balanced_tree.sales
		)
		,trx_calc_CTE
	AS (
		SELECT members
			,trx_cnt
			,(
				CAST(trx_cnt AS FLOAT) / (
					SELECT SUM(trx_cnt)
					FROM trx_CTE
					)
				) AS transaction_pct
		FROM trx_CTE
		)
		,revenue_calc_CTE
	AS (
		SELECT members
			,AVG(revenue) AS revenue_avg
		FROM revenue_CTE
		GROUP BY members
		)
	SELECT @MonthName AS [month]
		,t.members
		,t.trx_cnt AS total_transactions
		,FORMAT(t.transaction_pct, 'p') AS total_transaction_pct
		,FORMAT(revenue_avg, '#.##') AS revenue_avg
	INTO #member_trx_analysis
	FROM trx_calc_CTE AS t
	JOIN revenue_calc_CTE AS r
		ON t.members = r.members;
--
--	Result
SELECT *
FROM #member_trx_analysis;
/*
	month      members     total_transactions total_transaction_pct revenue_avg
	---------- ----------- ------------------ --------------------- -----------
	January    Members     2955               59.60%                75.43
	January    Non-Members 2003               40.40%                74.54
*/
--
--	====		PRODUCT ANALYSIS	====
--
--	TOP 3 PRODUCTS OF THE MONTH
DROP TABLE
IF EXISTS #top_3_products;
	WITH revenue_CTE
	AS (
		SELECT product_name
			,SUM((qty * price)) AS revenue_total
		FROM #balanced_tree_sub
		GROUP BY product_name
		)
		,row_CTE
	AS (
		SELECT ROW_NUMBER() OVER (
				ORDER BY revenue_total DESC
				) AS row_num
			,product_name
			,FORMAT(revenue_total, '#,#') AS total_revenue
		FROM revenue_CTE
		)
	SELECT @MonthName AS [month]
		,product_name
		,total_revenue 
	INTO #top_3_products
	FROM row_CTE
	WHERE row_num <= 3;
--
--	Result
SELECT *
FROM #top_3_products;
/*
	month      product_name                     total_revenue
	---------- -------------------------------- -------------
	January    Grey Fashion Jacket - Womens     70,200
	January    Blue Polo Shirt - Mens           69,198
	January    White Tee Shirt - Mens           50,240
*/
--
--	SEGMENTS ANALYSIS
DROP TABLE
IF EXISTS #segment_analysis;
	WITH sub_CTE
	AS (
		SELECT segment_id
			,segment_name
			,SUM(qty) AS quantity
			,SUM(qty * price) AS revenue
			,SUM(qty * price * (CAST(discount AS FLOAT) / 100)) AS discount
		FROM #balanced_tree_sub
		GROUP BY segment_id
			,segment_name
		)
	SELECT @MonthName AS [month]
		,segment_name
		,quantity AS quantity_sold
		,FORMAT(revenue, '#,#') AS total_revenue
		,FORMAT(discount, '#,#.##') AS total_discount
	INTO #segment_analysis
	FROM sub_CTE
	ORDER BY segment_id;
--
--	Result
SELECT *
FROM #segment_analysis;
/*
	month      segment_name quantity_sold total_revenue total_discount
	---------- ------------ ------------- ------------- --------------
	January    Jeans        3777          68,777        8,482.68
	January    Jacket       3750          121,650       14,871.38
	January    Shirt        3690          131,638       16,228.38
	January    Socks        3571          98,607        12,006.66
*/
--
--	TOP PRODUCT BY SEGMENT
DROP TABLE
IF EXISTS #top_product_segment;
	WITH sold_CTE
	AS (
		SELECT segment_id
			,segment_name
			,product_name
			,SUM(qty) AS sold
		FROM #balanced_tree_sub
		GROUP BY segment_id
			,segment_name
			,product_name
		)
		,row_CTE
	AS (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY segment_id ORDER BY sold DESC
				) AS row_num
			,*
		FROM sold_CTE
		)
	SELECT @MonthName AS [month]
		,segment_name
		,product_name
		,sold
	INTO #top_product_segment
	FROM row_CTE
	WHERE row_num = 1
	ORDER BY segment_id;
--
--	Result
SELECT *
FROM #top_product_segment
/*
	month      segment_name product_name                     sold
	---------- ------------ -------------------------------- -----------
	January    Jeans        Cream Relaxed Jeans - Womens     1282
	January    Jacket       Grey Fashion Jacket - Womens     1300
	January    Shirt        White Tee Shirt - Mens           1256
	January    Socks        Navy Solid Socks - Mens          1264
*/
--
--	CATEGORY ANALYSIS
DROP TABLE
IF EXISTS #category_analysis;
	WITH sub_CTE
	AS (
		SELECT category_id
			,category_name
			,SUM(qty) AS quantity
			,SUM(qty * price) AS revenue
			,SUM(qty * price * (CAST(discount AS FLOAT) / 100)) AS discount
		FROM #balanced_tree_sub
		GROUP BY category_id
			,category_name
		)
	SELECT @MonthName AS [month]
		,category_name
		,quantity AS quantity_sold
		,FORMAT(revenue, '#,#') AS total_revenue
		,FORMAT(discount, '#,#.##') AS total_discount
	INTO #category_analysis
	FROM sub_CTE
	ORDER BY category_id;
--
--	Result
SELECT *
FROM #category_analysis;
/*
	month      category_name quantity_sold total_revenue total_discount
	---------- ------------- ------------- ------------- --------------
	January    Mens          7261          230,245       28,235.04
	January    Womens        7527          190,427       23,354.06
*/
--
--	TOP PRODUCT BY CATEGORY
DROP TABLE
IF EXISTS #top_product_category;
	WITH sold_CTE
	AS (
		SELECT category_id
			,category_name
			,product_name
			,SUM(qty) AS sold
		FROM #balanced_tree_sub
		GROUP BY category_id
			,category_name
			,product_name
		)
		,row_CTE
	AS (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY category_id ORDER BY sold DESC
				) AS row_num
			,*
		FROM sold_CTE
		)
	SELECT @MonthName AS [month]
		,category_name
		,product_name
		,sold
	INTO #top_product_category
	FROM row_CTE
	WHERE row_num = 1
	ORDER BY category_id;
--
--	Result
SELECT *
FROM #top_product_category;
/*
	month      category_name product_name                     sold
	---------- ------------- -------------------------------- -----------
	January    Womens        Grey Fashion Jacket - Womens     1300
	January    Mens          Navy Solid Socks - Mens          1264
*/
--
--	PRODUCT REVENUE BY SEGMENT
DROP TABLE
IF EXISTS #revenue_product_segment;
	WITH revenue_CTE
	AS (
		SELECT segment_id
			,segment_name
			,product_id
			,product_name
			,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
		FROM #balanced_tree_sub
		GROUP BY segment_id
			,segment_name
			,product_id
			,product_name
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
	SELECT @MonthName AS [month]
		,segment_name
		,product_name
		,FORMAT(revenue, '#,#.#0') AS total_revenue
		,FORMAT(revenue_pct, 'p') AS revenue_pct
	INTO #revenue_product_segment
	FROM calc_CTE
	ORDER BY segment_id
		,product_id;
--
--	Result
SELECT *
FROM #revenue_product_segment;
/*
	month      segment_name product_name                     total_revenue revenue_pct
	---------- ------------ -------------------------------- ------------- -----------
	January    Jeans        Navy Oversized Jeans - Womens    14,317.16     3.88%
	January    Jeans        Cream Relaxed Jeans - Womens     11,224.20     3.04%
	January    Jeans        Black Straight Jeans - Womens    34,752.96     9.42%
	January    Jacket       Indigo Rain Jacket - Womens      20,422.72     5.53%
	January    Jacket       Grey Fashion Jacket - Womens     61,619.40     16.70%
	January    Jacket       Khaki Suit Jacket - Womens       24,736.50     6.70%
	January    Shirt        Blue Polo Shirt - Mens           60,674.22     16.44%
	January    Shirt        White Tee Shirt - Mens           44,074.40     11.94%
	January    Shirt        Teal Button Up Shirt - Mens      10,661.00     2.89%
	January    Socks        Pink Fluro Polkadot Socks - Mens 29,461.39     7.98%
	January    Socks        White Striped Socks - Mens       17,192.27     4.66%
	January    Socks        Navy Solid Socks - Mens          39,946.68     10.82%
*/
--
--	REVENUE BY SEGMENT FOR EACH CATEGORY
DROP TABLE
IF EXISTS #revenue_segment_category;
	WITH revenue_CTE
	AS (
		SELECT category_id
			,category_name
			,segment_id
			,segment_name
			,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
		FROM #balanced_tree_sub
		GROUP BY category_id
			,category_name
			,segment_id
			,segment_name
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
	SELECT @MonthName AS [month]
		,category_name
		,segment_name
		,FORMAT(revenue, '#,#.#0') AS total_revenue
		,FORMAT(revenue_pct, 'p') AS revenue_pct
	INTO #revenue_segment_category
	FROM calc_CTE
	ORDER BY segment_id
		,category_id;
--
--	Result
SELECT *
FROM #revenue_segment_category;
/*
	month      category_name segment_name total_revenue revenue_pct
	---------- ------------- ------------ ------------- -----------
	January    Mens          Shirt        115,409.62    31.27%
	January    Womens        Jeans        60,294.32     16.34%
	January    Womens        Jacket       106,778.62    28.93%
	January    Mens          Socks        86,600.34     23.46%
*/
--
--	REVENUE BY CATEGORY
DROP TABLE
IF EXISTS #revenue_category;
	WITH revenue_CTE
	AS (
		SELECT category_id
			,category_name
			,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
		FROM #balanced_tree_sub
		GROUP BY category_id
			,category_name
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
	SELECT @MonthName AS [month]
		,category_name
		,FORMAT(revenue, '#,#.##') AS total_revenue
		,FORMAT(revenue_pct, 'p') AS revenue_pct
	INTO #revenue_category
	FROM calc_CTE
	ORDER BY category_id;
--
--	Result
SELECT *
FROM #revenue_category;
/*
	month      category_name total_revenue revenue_pct
	---------- ------------- ------------- -----------
	January    Mens          202,009.96    54.73%
	January    Womens        167,072.94    45.27%
*/
--
-- PRODUCT PENETRATION
DROP TABLE
IF EXISTS #product_penetration;
	WITH trx_CTE
	AS (
		SELECT product_id
			,product_name
			,CAST(COUNT(product_name) AS FLOAT) AS trx_cnt
		FROM #balanced_tree_sub
		GROUP BY product_id
			,product_name
		)
	SELECT @MonthName AS [month]
		,product_name
		,FORMAT((
				trx_cnt / (
					SELECT COUNT(DISTINCT txn_id)
					FROM balanced_tree.sales
					)
				), 'p') AS penetration_pct
	INTO #product_penetration
	FROM trx_CTE
	ORDER BY product_id;
--
-- Result
SELECT *
FROM #product_penetration;
/*
	month      product_name                     penetration_pct
	---------- -------------------------------- ---------------
	January    Blue Polo Shirt - Mens           16.52%
	January    Cream Relaxed Jeans - Womens     17.28%
	January    Grey Fashion Jacket - Womens     17.24%
	January    Navy Oversized Jeans - Womens    16.92%
	January    Teal Button Up Shirt - Mens      16.44%
	January    Black Straight Jeans - Womens    16.32%
	January    White Tee Shirt - Mens           16.64%
	January    Navy Solid Socks - Mens          16.80%
	January    Khaki Suit Jacket - Womens       16.08%
	January    Pink Fluro Polkadot Socks - Mens 15.84%
	January    White Striped Socks - Mens       15.96%
	January    Indigo Rain Jacket - Womens      16.28%
*/
--
--	TOP PRODUCT COMBINATION
DROP TABLE
IF EXISTS #top_combination;
	WITH product_CTE
	AS (
		SELECT txn_id
			,product_id
			,product_name
		FROM #balanced_tree_sub
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
	SELECT @MonthName AS [month]
		,product_name_1
		,product_name_2
		,product_name_3
		,cnt AS trx_cnt
	INTO #top_combination
	FROM row_CTE
	WHERE rn = 1;
--
--	Result
SELECT *
FROM #top_combination;
/*
month      product_name_1                   product_name_2                   product_name_3                   trx_cnt
---------- -------------------------------- -------------------------------- -------------------------------- -----------
January    Grey Fashion Jacket - Womens     Black Straight Jeans - Womens    Navy Solid Socks - Mens          125
*/
