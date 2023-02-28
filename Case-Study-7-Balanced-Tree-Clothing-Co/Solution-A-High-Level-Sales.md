# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution A. High Level Sales Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. What was the total quantity sold for all products?

    Query:

    ```sql
    SELECT
        SUM(qty) AS quantity_sold_total
    FROM
        balanced_tree.sales;
    ```

    Output:

    | "quantity_sold_total" |
    |-----------------------|
    | 45216                 |

    <br>

2. What is the total generated revenue for all products before discounts?

    Query:

    ```sql
    SELECT
        TO_CHAR(SUM(qty * price), '9,999,999') AS gross_revenue_total
    FROM
        balanced_tree.sales;
    ```

    Output:

    | "gross_revenue_total" |
    |-----------------------|
    |  1,289,453            |

    <br>

3. What was the total discount amount for all products?

    Query:

    ```sql
    SELECT
        TO_CHAR(SUM(qty * price * discount::NUMERIC / 100), '9,999,999') AS discount_total
    FROM
        balanced_tree.sales;
    ```

    Output:

    | "discount_total" |
    |------------------|
    |    156,229       |

---
