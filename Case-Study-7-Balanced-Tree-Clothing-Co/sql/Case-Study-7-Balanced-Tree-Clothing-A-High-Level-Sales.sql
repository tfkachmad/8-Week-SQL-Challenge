--
-- Case study solutions for #8WeeksSQLChallenge by Danny Ma
-- Week 7 - Balanced Tree Clothing
-- Part A - High Level Sales Analysis
--
-- 1. What was the total quantity sold for all products?
SELECT
    SUM(qty) AS quantity_sold_total
FROM
    balanced_tree.sales;

--
-- 2. What is the total generated revenue for all products before discounts?
SELECT
    TO_CHAR(SUM(qty * price), '9,999,999') AS gross_revenue_total
FROM
    balanced_tree.sales;

--
-- 3. What was the total discount amount for all products?
SELECT
    TO_CHAR(SUM(qty * price * discount::NUMERIC / 100), '9,999,999') AS discount_total
FROM
    balanced_tree.sales;
