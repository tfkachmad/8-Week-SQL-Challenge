# :shopping_cart: Case Study 5 - Data Mart: Solution A. Data Cleansing

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the `week_date` to a `DATE` format

- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column

- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values

- Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value

    | segment | age_band     |
    |---------|--------------|
    | 1       | Young Adults |
    | 2       | Middle Aged  |
    | 3 or 4  | Retirees     |

- Add a new demographic column using the following mapping for the first letter in the segment values:

    | segment | demographic |
    |---------|-------------|
    | C       | Couples     |
    | F       | Families    |

- Ensure all `null` string values with an `"unknown"` string value in the original `segment` column as well as the new `age_band` and `demographic` columns

- Generate a new `avg_transaction` column as the `sales` value divided by `transactions` rounded to 2 decimal places for each record

    Query:

    ```sql
    SET search_path = data_mart;

    DROP TABLE IF EXISTS clean_weekly_sales;

    CREATE TABLE clean_weekly_sales AS
    WITH segments AS (
        SELECT DISTINCT
            segment,
            CASE WHEN segment = 'null' THEN
                'unknown'
            ELSE
            LEFT (segment,
                1)
            END AS segment_demo,
            CASE WHEN segment = 'null' THEN
                'unknown'
            ELSE
            RIGHT (segment,
                1)
            END AS segment_age
        FROM
            data_mart.weekly_sales
    )
    SELECT
        TO_DATE(week_date, 'DD/MM/YY') AS week_date,
        EXTRACT('WEEK' FROM TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
        EXTRACT('MONTH' FROM TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
        EXTRACT('YEAR' FROM TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
        w.region,
        w.platform,
        CASE WHEN s.segment = 'null' THEN
            'unknown'
        ELSE
            s.segment
        END AS segment,
        CASE s.segment_demo
        WHEN 'C' THEN
            'Couples'
        WHEN 'F' THEN
            'Families'
        ELSE
            s.segment_demo
        END AS demographic,
        CASE s.segment_age
        WHEN '1' THEN
            'Young Adults'
        WHEN '2' THEN
            'Middle Aged'
        WHEN '3' THEN
            'Retirees'
        WHEN '4' THEN
            'Retirees'
        ELSE
            s.segment_age
        END AS age_band,
        w.customer_type,
        w.transactions,
        w.sales,
        ROUND((w.sales / w.transactions::NUMERIC), 2) AS avg_transaction
    FROM
        data_mart.weekly_sales AS w
        JOIN segments AS s ON w.segment = s.segment;
    ```

    Output:

    Showing the first 10 rows

    | 2020-08-31 | 36 | 8 | 2020 | ASIA   | Retail  | C3      | Couples  | Retirees     | New      | 120631 | 3656163  | 30.31  |
    |------------|----|---|------|--------|---------|---------|----------|--------------|----------|--------|----------|--------|
    | 2020-08-31 | 36 | 8 | 2020 | ASIA   | Retail  | F1      | Families | Young Adults | New      | 31574  | 996575   | 31.56  |
    | 2020-08-31 | 36 | 8 | 2020 | USA    | Retail  | unknown | unknown  | unknown      | Guest    | 529151 | 16509610 | 31.20  |
    | 2020-08-31 | 36 | 8 | 2020 | EUROPE | Retail  | C1      | Couples  | Young Adults | New      | 4517   | 141942   | 31.42  |
    | 2020-08-31 | 36 | 8 | 2020 | AFRICA | Retail  | C2      | Couples  | Middle Aged  | New      | 58046  | 1758388  | 30.29  |
    | 2020-08-31 | 36 | 8 | 2020 | CANADA | Shopify | F2      | Families | Middle Aged  | Existing | 1336   | 243878   | 182.54 |
    | 2020-08-31 | 36 | 8 | 2020 | AFRICA | Shopify | F3      | Families | Retirees     | Existing | 2514   | 519502   | 206.64 |
    | 2020-08-31 | 36 | 8 | 2020 | ASIA   | Shopify | F1      | Families | Young Adults | Existing | 2158   | 371417   | 172.11 |
    | 2020-08-31 | 36 | 8 | 2020 | AFRICA | Shopify | F2      | Families | Middle Aged  | New      | 318    | 49557    | 155.84 |
    | 2020-08-31 | 36 | 8 | 2020 | AFRICA | Retail  | C3      | Couples  | Retirees     | New      | 111032 | 3888162  | 35.02  |

---
