# :shirt: Case Study 7 - Balanced Tree Clothing Co.: Solution D. Reporting Challenge

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the same analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :).

- To easily change the value for each month, a variable called `month_name` provided. This variable value can be easily changed to get the report for different month, for this example January is used.
- Before creating the actual report, a subset from the data, called `monthly_sales`, is used just to filter the data to be used based on the month value provided by the `month_name` variable.
- We can then use this sales subset data to generate the analysis to generate the report.

    ```sql
    DO $$
    DECLARE
        month_name VARCHAR(9) := 'January';
    BEGIN
        SET SEARCH_PATH = 'balanced_tree';
        DROP TABLE IF EXISTS monthly_sales;
        CREATE TEMPORARY TABLE IF NOT EXISTS monthly_sales AS
        SELECT
            *
        FROM
            balanced_tree.sales
        WHERE
            TO_CHAR(start_txn_time, 'FMMonth') = month_name;
    END
    $$;
    ```

- the final query result can be seen at [Case-Study-7-Balanced-Tree-Clothing-D-Reporting-Challenge.sql](Case-Study-7-Balanced-Tree-Clothing-Co\SQL-files\Case-Study-7-Balanced-Tree-Clothing-D-Reporting-Challenge.sql) file.

---
