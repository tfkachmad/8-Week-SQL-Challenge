USE EightWeekSQLChallenge;
--
/*
	========	B. TRANSACTION ANALYSIS	========
*/
--
--	1.	How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS unique_transaction_cnt
FROM balanced_tree.sales;
/*
	unique_transaction_cnt
	----------------------
	2500
*/
--
--	2.	What is the average unique products purchased in each transaction?
WITH products_CTE
AS (
	SELECT txn_id
		,COUNT(DISTINCT prod_id) AS unique_product_cnt
	FROM balanced_tree.sales
	GROUP BY txn_id
	)
SELECT AVG(unique_product_cnt) AS unique_products_purchased_avg
FROM products_CTE;
/*
	unique_products_purchased_avg
	-----------------------------
	6
*/
--
--	3.	What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue_CTE
AS (
	SELECT txn_id
		,SUM((qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100))) AS revenue
	FROM balanced_tree.sales
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
			) OVER () AS median
		,PERCENTILE_CONT(0.75) WITHIN
	GROUP (
			ORDER BY revenue
			) OVER () AS revenue_75_percentile
	FROM revenue_CTE
	)
SELECT FORMAT(revenue_25_percentile, '##.##') AS revenue_25_percentile
	,FORMAT(median, '##.##') AS revenue_median
	,FORMAT(revenue_75_percentile, '##.##') AS revenue_75_percentile
FROM percentile_CTE;
/*
	revenue_25_percentile  median  revenue_75_percentile
	---------------------- ------- ----------------------
	326.41				   441.23  572.76
*/
--
--	4.	What is the average discount value per transaction?
WITH discount_CTE
AS (
	SELECT txn_id
		,SUM((qty * price * (CAST(discount AS FLOAT) / 100))) AS discount
	FROM balanced_tree.sales
	GROUP BY txn_id
	)
SELECT FORMAT(AVG(discount), '##.##') discount_avg
FROM discount_CTE;
/*
	discount_avg
	-------------
	62.49
*/
--
--	5.	What is the percentage split of all transactions for members vs non-members?
WITH trx_CTE
AS (
	SELECT CASE 
			WHEN member = 1
				THEN 'Members'
			ELSE 'Non-Members'
			END AS members
		,COUNT(*) AS trx_cnt
	FROM balanced_tree.sales
	GROUP BY CASE 
			WHEN member = 1
				THEN 'Members'
			ELSE 'Non-Members'
			END
	)
	,calc_CTE
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
SELECT members
	,trx_cnt
	,FORMAT(transaction_pct, 'p') AS transaction_pct
FROM calc_CTE;
/*
	members     trx_cnt     transaction_pct
	----------- ----------- ----------------
	Members     9061        60.03%
	Non-Members 6034        39.97%
*/
--
--	6.	What is the average revenue for member transactions and non-member transactions?
WITH revenue_CTE
AS (
	SELECT CASE 
			WHEN member = 1
				THEN 'Members'
			ELSE 'Non-Members'
			END AS members
		,(qty * price) - (qty * price * (CAST(discount AS FLOAT) / 100)) AS revenue
	FROM balanced_tree.sales
	)
SELECT members
	,FORMAT(AVG(revenue), '#.##') AS revenue_avg
FROM revenue_CTE
GROUP BY members;


/*
	members     revenue_avg
	----------- ------------
	Members     75.43
	Non-Members 74.54
*/
