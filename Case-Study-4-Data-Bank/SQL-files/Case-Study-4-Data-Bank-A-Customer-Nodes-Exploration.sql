USE EightWeekSQLChallenge;
--
/*
	========	A. Customer Nodes Exploration	========
*/
--
--	1.	How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS nodes
FROM data_bank.customer_nodes;
/*
	nodes
	-----------
	5
*/
--
--	2.	What is the number of nodes per region?
SELECT r.region_name
	,COUNT(DISTINCT n.node_id) AS nodes
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r
	ON n.region_id = r.region_id
GROUP BY r.region_id
	,r.region_name
ORDER BY r.region_id;
/*
	region_name nodes
	----------- -----------
	Australia   5
	America     5
	Africa      5
	Asia        5
	Europe      5
*/
--
--	3.	How many customers are allocated to each region?
SELECT r.region_name
	,COUNT(*) AS customers
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r
	ON n.region_id = r.region_id
GROUP BY r.region_id
	,r.region_name
ORDER BY r.region_id;
/*
	region_name customers
	----------- -----------
	Australia   770
	America     735
	Africa      714
	Asia        665
	Europe      616
*/
--
--	4.	How many days on average are customers reallocated to a different node?
-- Start date on every node
WITH starting_date
AS (
	SELECT customer_id
		,node_id
		,MIN(start_date) OVER (
			PARTITION BY node_id
			,customer_id ORDER BY start_date
			) AS start_node
	FROM data_bank.customer_nodes AS n
	JOIN data_bank.regions AS r
		ON n.region_id = r.region_id
	)
	,grouped
AS (
	SELECT customer_id
		,node_id
		,start_node
	FROM starting_date
	GROUP BY customer_id
		,node_id
		,start_node
	)
	,next_node
AS (
	SELECT customer_id
		,node_id
		,start_node
		,LEAD(start_node) OVER (
			PARTITION BY customer_id ORDER BY start_node
			) AS next_node_id
	FROM grouped
	)
SELECT AVG(DATEDIFF(DAY, start_node, next_node_id)) AS average_days
FROM next_node
WHERE next_node_id IS NOT NULL;
/*
	average_days
	------------
	23
*/
--
--	5.	What is the median, 80th and 95th percentile for this same reallocation 
--		days metric for each region?
WITH starting_date
AS (
	SELECT n.customer_id
		,n.node_id
		,r.region_name
		,MIN(start_date) OVER (
			PARTITION BY node_id
			,customer_id ORDER BY start_date
			) AS start_node
	FROM data_bank.customer_nodes AS n
	JOIN data_bank.regions AS r
		ON n.region_id = r.region_id
	)
	,grouped
AS (
	SELECT customer_id
		,node_id
		,start_node
		,region_name
	FROM starting_date
	GROUP BY customer_id
		,node_id
		,start_node
		,region_name
	)
	,next_node
AS (
	SELECT customer_id
		,node_id
		,start_node
		,region_name
		,LEAD(start_node) OVER (
			PARTITION BY customer_id ORDER BY start_node
			) AS next_node_id
	FROM grouped
	)
	,diff
AS (
	SELECT region_name
		,DATEDIFF(DAY, start_node, next_node_id) AS dd
	FROM next_node
	WHERE next_node_id IS NOT NULL
	)
SELECT DISTINCT region_name
	,PERCENTILE_CONT(0.5) WITHIN
GROUP (
		ORDER BY dd
		) OVER (PARTITION BY region_name) AS reallocation_median
	,PERCENTILE_CONT(0.8) WITHIN
GROUP (
		ORDER BY dd
		) OVER (PARTITION BY region_name) AS reallocation_80
	,PERCENTILE_CONT(0.95) WITHIN
GROUP (
		ORDER BY dd
		) OVER (PARTITION BY region_name) AS reallocation_95
FROM diff;
/*
	region_name reallocation_median    reallocation_80        reallocation_95
	----------- ---------------------- ---------------------- ----------------------
	Africa      21                     33.2                   58.8
	America     21                     33.2                   57
	Asia        22                     32.4                   49.85
	Australia   22                     31                     54
	Europe      22                     31                     54.3
*/
