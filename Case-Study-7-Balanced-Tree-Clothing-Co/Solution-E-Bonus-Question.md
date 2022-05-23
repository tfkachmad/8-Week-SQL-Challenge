# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution E. Bonus Question

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

- The query to create a new product_details table:

    ```sql
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
    ```

- The original `product_details` table:

    |product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
    |:----|:----|:----|:----|:----|:----|:----|:----|:----|
    |c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
    |e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
    |e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
    |d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
    |72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|
    |9ec847|54|Grey Fashion Jacket - Womens|1|4|12|Womens|Jacket|Grey Fashion|
    |5d267b|40|White Tee Shirt - Mens|2|5|13|Mens|Shirt|White Tee|
    |c8d436|10|Teal Button Up Shirt - Mens|2|5|14|Mens|Shirt|Teal Button Up|
    |2a2353|57|Blue Polo Shirt - Mens|2|5|15|Mens|Shirt|Blue Polo|
    |f084eb|36|Navy Solid Socks - Mens|2|6|16|Mens|Socks|Navy Solid|
    |b9a74d|17|White Striped Socks - Mens|2|6|17|Mens|Socks|White Striped|
    |2feb6b|29|Pink Fluro Polkadot Socks - Mens|2|6|18|Mens|Socks|Pink Fluro Polkadot|

    <br/>

- The new product details table:

    |product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
    |:----|:----|:----|:----|:----|:----|:----|:----|:----|
    |c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
    |e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
    |e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
    |d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
    |72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|
    |9ec847|54|Grey Fashion Jacket - Womens|1|4|12|Womens|Jacket|Grey Fashion|
    |5d267b|40|White Tee Shirt - Mens|2|5|13|Mens|Shirt|White Tee|
    |c8d436|10|Teal Button Up Shirt - Mens|2|5|14|Mens|Shirt|Teal Button Up|
    |2a2353|57|Blue Polo Shirt - Mens|2|5|15|Mens|Shirt|Blue Polo|
    |f084eb|36|Navy Solid Socks - Mens|2|6|16|Mens|Socks|Navy Solid|
    |b9a74d|17|White Striped Socks - Mens|2|6|17|Mens|Socks|White Striped|
    |2feb6b|29|Pink Fluro Polkadot Socks - Mens|2|6|18|Mens|Socks|Pink Fluro Polkadot|

---
