USE EightWeekSQLChallenge;
--
/*
	========	E. BONUS CHALLENGE	========
*/
--
--	Use a single SQL query to transform the product_hierarchy and product_prices 
--	datasets to the product_details table.
--
--	Hint: you may want to consider using a recursive CTE to solve this problem!
--
DROP TABLE IF EXISTS #new_product_details;
WITH products_CTE
AS (
	SELECT id
		,parent_id
		,level_text
		,level_name
		,1 AS level_count
		,0 AS category_id
		,level_text AS category
		,0 AS segment_id
		,CAST('' AS VARCHAR(19)) AS segment
		,0 AS style_id
	FROM balanced_tree.product_hierarchy
	WHERE parent_id IS NULL
	
	UNION ALL
	
	SELECT h.id
		,h.parent_id
		,h.level_text
		,h.level_name
		,level_count + 1
		,CASE 
			WHEN level_count = 1
				THEN p.id
			ELSE category_id
			END
		,CASE 
			WHEN level_count = 1
				THEN p.level_text
			ELSE category
			END
		,CASE 
			WHEN level_count = 2
				THEN p.id
			ELSE segment_id
			END
		,CASE 
			WHEN level_count = 2
				THEN p.level_text
			ELSE segment
			END
		,h.id
	FROM products_CTE AS p
	JOIN balanced_tree.product_hierarchy AS h
		ON p.id = h.parent_id
	)
SELECT prices.product_id
	,prices.price
	,(product.level_text + ' ' + segment + ' - '  + category) AS product_name
	,product.category_id
	,product.segment_id
	,product.style_id
	,product.category AS category_name
	,product.segment AS segment_name
	,product.level_text AS style_name
INTO #new_product_details
FROM products_CTE AS product
JOIN balanced_tree.product_prices AS prices
	ON product.id = prices.id
ORDER BY product.id;
--
--	Comparing both tables
--
SELECT *
FROM #new_product_details;
--
SELECT *
FROM balanced_tree.product_details;
