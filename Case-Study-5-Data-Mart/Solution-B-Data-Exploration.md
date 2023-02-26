# :shopping_cart: Case Study 5 - Data Mart: Solution B. Data Exploration

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. What day of the week is used for each `week_date` value?

    Query:

    ```sql
    SELECT DISTINCT
        TO_CHAR(week_date, 'Day') AS day_of_week
    FROM
        data_mart.clean_weekly_sales;
    ```

    Output:

    | "day_of_week" |
    |---------------|
    | Monday        |

    <br>

2. What range of week numbers are missing from the dataset?

    Query:

    ```sql
    SELECT
        calendar_year,
        MIN(week_number) AS first_week_data,
        MAX(week_number) AS last_week_data
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "calendar_year" | "first_week_data" | "last_week_data" |
    |-----------------|-------------------|------------------|
    | 2018            | 13                | 36               |
    | 2019            | 13                | 36               |
    | 2020            | 13                | 36               |

    <br>

3. How many total transactions were there for each year in the dataset?

    Query:

    ```sql
    SELECT
        calendar_year,
        TO_CHAR(SUM(transactions), '9,999,999,999') AS transactions_total
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "calendar_year" | "transactions_total" |
    |-----------------|----------------------|
    | 2018            |    346,406,460       |
    | 2019            |    365,639,285       |
    | 2020            |    375,813,651       |

    <br>

4. What is the total sales for each region for each month?

    Query:

    ```sql
    SELECT
        region,
        TO_CHAR(week_date, 'Month') AS month_name,
        TO_CHAR(SUM(sales), '9,999,999,999') AS sales_total
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1,
        2,
        month_number
    ORDER BY
        1,
        month_number;
    ```

    Output:

    | "region"      | "month_name" | "sales_total"  |
    |---------------|--------------|----------------|
    | AFRICA        | March        |    567,767,480 |
    | AFRICA        | April        |  1,911,783,504 |
    | AFRICA        | May          |  1,647,244,738 |
    | AFRICA        | June         |  1,767,559,760 |
    | AFRICA        | July         |  1,960,219,710 |
    | AFRICA        | August       |  1,809,596,890 |
    | AFRICA        | September    |    276,320,987 |
    | ASIA          | March        |    529,770,793 |
    | ASIA          | April        |  1,804,628,707 |
    | ASIA          | May          |  1,526,285,399 |
    | ASIA          | June         |  1,619,482,889 |
    | ASIA          | July         |  1,768,844,756 |
    | ASIA          | August       |  1,663,320,609 |
    | ASIA          | September    |    252,836,807 |
    | CANADA        | March        |    144,634,329 |
    | CANADA        | April        |    484,552,594 |
    | CANADA        | May          |    412,378,365 |
    | CANADA        | June         |    443,846,698 |
    | CANADA        | July         |    477,134,947 |
    | CANADA        | August       |    447,073,019 |
    | CANADA        | September    |     69,067,959 |
    | EUROPE        | March        |     35,337,093 |
    | EUROPE        | April        |    127,334,255 |
    | EUROPE        | May          |    109,338,389 |
    | EUROPE        | June         |    122,813,826 |
    | EUROPE        | July         |    136,757,466 |
    | EUROPE        | August       |    122,102,995 |
    | EUROPE        | September    |     18,877,433 |
    | OCEANIA       | March        |    783,282,888 |
    | OCEANIA       | April        |  2,599,767,620 |
    | OCEANIA       | May          |  2,215,657,304 |
    | OCEANIA       | June         |  2,371,884,744 |
    | OCEANIA       | July         |  2,563,459,400 |
    | OCEANIA       | August       |  2,432,313,652 |
    | OCEANIA       | September    |    372,465,518 |
    | SOUTH AMERICA | March        |     71,023,109 |
    | SOUTH AMERICA | April        |    238,451,531 |
    | SOUTH AMERICA | May          |    201,391,809 |
    | SOUTH AMERICA | June         |    218,247,455 |
    | SOUTH AMERICA | July         |    235,582,776 |
    | SOUTH AMERICA | August       |    221,166,052 |
    | SOUTH AMERICA | September    |     34,175,583 |
    | USA           | March        |    225,353,043 |
    | USA           | April        |    759,786,323 |
    | USA           | May          |    655,967,121 |
    | USA           | June         |    703,878,990 |
    | USA           | July         |    760,331,754 |
    | USA           | August       |    712,002,790 |
    | USA           | September    |    110,532,368 |

    <br>

5. What is the total count of transactions for each platform

    Query:

    ```sql
    SELECT
        platform,
        COUNT(*) AS transactions_num
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1;
    ```

    Output:

    | "platform" | "transactions_num" |
    |------------|--------------------|
    | Shopify    | 8549               |
    | Retail     | 8568               |

    <br>

6. What is the percentage of sales for Retail vs Shopify for each month?

    Query:

    ```sql
    WITH platform_sales AS (
        SELECT
            calendar_year,
            month_number,
            TO_CHAR(week_date, 'Month') AS month_name,
            SUM(
                CASE platform
                WHEN 'Retail' THEN
                    sales
                ELSE
                    0
                END) AS retail_sales,
            SUM(
                CASE platform
                WHEN 'Shopify' THEN
                    sales
                ELSE
                    0
                END) AS shopify_sales
        FROM
            data_mart.clean_weekly_sales
        GROUP BY
            1,
            2,
            3
    )
    SELECT
        calendar_year,
        month_name,
        ROUND((100 * retail_sales / (retail_sales + shopify_sales)::NUMERIC), 2) AS retail_sales_percentage,
        ROUND((100 * shopify_sales / (retail_sales + shopify_sales)::NUMERIC), 2) AS shopify_sales_percentage
    FROM
        platform_sales
    ORDER BY
        calendar_year,
        month_number;
    ```

    Output:

    | "calendar_year" | "month_name" | "retail_sales_percentage" | "shopify_sales_percentage" |
    |-----------------|--------------|---------------------------|----------------------------|
    | 2018            | March        | 97.92                     | 2.08                       |
    | 2018            | April        | 97.93                     | 2.07                       |
    | 2018            | May          | 97.73                     | 2.27                       |
    | 2018            | June         | 97.76                     | 2.24                       |
    | 2018            | July         | 97.75                     | 2.25                       |
    | 2018            | August       | 97.71                     | 2.29                       |
    | 2018            | September    | 97.68                     | 2.32                       |
    | 2019            | March        | 97.71                     | 2.29                       |
    | 2019            | April        | 97.80                     | 2.20                       |
    | 2019            | May          | 97.52                     | 2.48                       |
    | 2019            | June         | 97.42                     | 2.58                       |
    | 2019            | July         | 97.35                     | 2.65                       |
    | 2019            | August       | 97.21                     | 2.79                       |
    | 2019            | September    | 97.09                     | 2.91                       |
    | 2020            | March        | 97.30                     | 2.70                       |
    | 2020            | April        | 96.96                     | 3.04                       |
    | 2020            | May          | 96.71                     | 3.29                       |
    | 2020            | June         | 96.80                     | 3.20                       |
    | 2020            | July         | 96.67                     | 3.33                       |
    | 2020            | August       | 96.51                     | 3.49                       |

    <br>

7. What is the percentage of sales by demographic for each year in the dataset?

    Query:

    ```sql
    WITH demoraphic_sales AS (
        SELECT
            calendar_year,
            SUM(
                CASE demographic
                WHEN 'Couples' THEN
                    sales
                ELSE
                    0
                END) AS couples_sales,
            SUM(
                CASE demographic
                WHEN 'Families' THEN
                    sales
                ELSE
                    0
                END) AS familes_sales,
            SUM(
                CASE demographic
                WHEN 'unknown' THEN
                    sales
                ELSE
                    0
                END) AS other_sales
        FROM
            data_mart.clean_weekly_sales
        GROUP BY
            1
    )
    SELECT
        calendar_year,
        ROUND((100 * couples_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS couples_sales_percentage,
        ROUND((100 * familes_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS familes_sales_percentage,
        ROUND((100 * other_sales / (couples_sales + familes_sales + other_sales)::NUMERIC), 2) AS other_sales_percentage
    FROM
        demoraphic_sales
    ORDER BY
        calendar_year;
    ```

    Output:

    | "calendar_year" | "couples_sales_percentage" | "familes_sales_percentage" | "other_sales_percentage" |
    |-----------------|----------------------------|----------------------------|--------------------------|
    | 2018            | 26.38                      | 31.99                      | 41.63                    |
    | 2019            | 27.28                      | 32.47                      | 40.25                    |
    | 2020            | 28.72                      | 32.73                      | 38.55                    |

    <br>

8. Which `age_band` and `demographic` values contribute the most to Retail sales?

    Query:

    ```sql
    SELECT
        age_band,
        demographic,
        SUM(sales) AS sales_total
    FROM
        data_mart.clean_weekly_sales
    WHERE
        platform = 'Retail'
    GROUP BY
        1,
        2
    ORDER BY
        3 DESC
    LIMIT 1;
    ```

    Output:

    | "age_band" | "demographic" | "sales_total" |
    |------------|---------------|---------------|
    | unknown    | unknown       | 16067285533   |

    <br>

9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

    No. The avg_transaction column is showing the average sales generated made per transactions for each week.

    Query:

    ```sql
    SELECT
        calendar_year,
        ROUND(AVG(
                CASE platform
                WHEN 'Retail' THEN
                    avg_transaction
                ELSE
                    NULL
                END), 2) AS retail_transaction_size_average,
        ROUND(AVG(
                CASE platform
                WHEN 'Shopify' THEN
                    avg_transaction
                ELSE
                    NULL
                END), 2) AS shopify_transaction_size_average
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | calendar_year | retail_avg_transaction | shopify_avg_transaction |
    |---------------|------------------------|-------------------------|
    | 2018          | 36.56                  | 192.48                  |
    | 2019          | 36.83                  | 183.36                  |
    | 2020          | 36.56                  | 179.03                  |

    To calculate the average transaction per year for each platform, we can just aggregate the transactions column to the year and platform level to get the average transaction size for each year for Retail vs. Shopify.

    Query:

    ```sql
    SELECT
        calendar_year,
        ROUND(AVG(
                CASE platform
                WHEN 'Retail' THEN
                    transactions
                ELSE
                    NULL
                END), 2) AS retail_transaction_size_average,
        ROUND(AVG(
                CASE platform
                WHEN 'Shopify' THEN
                    transactions
                ELSE
                    NULL
                END), 2) AS shopify_transaction_size_average
    FROM
        data_mart.clean_weekly_sales
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Result:

    | "calendar_year" | "retail_transaction_size_average" | "shopify_transaction_size_average" |
    |-----------------|-----------------------------------|------------------------------------|
    | 2018            | 120770.14                         | 523.20                             |
    | 2019            | 127360.00                         | 665.89                             |
    | 2020            | 130698.37                         | 889.35                             |

---
