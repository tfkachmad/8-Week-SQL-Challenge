# :shopping_cart: Case Study 5 - Data Mart: Solution D. Bonus Question

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

Query:

```sql
WITH sales_12_weeks_before AS (
    SELECT
        '2020-06-15' AS baseline_week,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MIN(TO_CHAR(('2020-06-15'::DATE - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
        SUM(sales) AS sales_before
    FROM
        data_mart.clean_weekly_sales
    WHERE
        week_date BETWEEN TO_CHAR(('2020-06-15'::DATE - INTERVAL '12 week'), 'YYYY-MM-DD')::DATE AND '2020-06-15'::DATE
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6
),
sales_12_weeks_after AS (
    SELECT
        '2020-06-15' AS baseline_week,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MAX(TO_CHAR(('2020-06-15'::DATE + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE),
        SUM(sales) AS sales_after
    FROM
        data_mart.clean_weekly_sales
    WHERE
        week_date BETWEEN '2020-06-15'::DATE AND TO_CHAR(('2020-06-15'::DATE + INTERVAL '12 week'), 'YYYY-MM-DD')::DATE
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6
)
SELECT
    s1.region,
    s1.platform,
    s1.age_band,
    s1.demographic,
    s1.customer_type,
    TO_CHAR(s1.sales_before, '9,999,999,999') AS sales_total_12_weeks_before,
    TO_CHAR(s2.sales_after, '9,999,999,999') AS sales_total_12_weeks_after,
    TO_CHAR((s2.sales_after - s1.sales_before), '9,999,999,999') AS total_sales_change,
    ROUND((100 * (s2.sales_after - s1.sales_before) / s1.sales_before::NUMERIC), 2) AS total_sales_change_percentage
FROM
    sales_12_weeks_before AS s1
    JOIN sales_12_weeks_after AS s2 ON s1.baseline_week = s2.baseline_week
        AND s1.region = s2.region
        AND s1.platform = s2.platform
        AND s1.age_band = s2.age_band
        AND s1.demographic = s2.demographic
        AND s1.customer_type = s2.customer_type
    ORDER BY
        (s2.sales_after - s1.sales_before);
```

Output:

Showing the 10 highest negative sales change between 12 weeks before and 12 weeks period.

| "region" | "platform" | "age_band"  | "demographic" | "customer_type" | "sales_total_12_weeks_before" | "sales_total_12_weeks_after" | "total_sales_change" | "total_sales_change_percentage" |
|----------|------------|-------------|---------------|-----------------|-------------------------------|------------------------------|----------------------|---------------------------------|
| OCEANIA  | Retail     | unknown     | unknown       | Guest           |    855,251,197                |    760,352,031               |    -94,899,166       | -11.10                          |
| ASIA     | Retail     | unknown     | unknown       | Guest           |    652,279,562                |    576,625,191               |    -75,654,371       | -11.60                          |
| AFRICA   | Retail     | unknown     | unknown       | Guest           |    585,155,905                |    533,702,201               |    -51,453,704       | -8.79                           |
| OCEANIA  | Retail     | Retirees    | Families      | Existing        |    395,014,402                |    355,341,719               |    -39,672,683       | -10.04                          |
| OCEANIA  | Retail     | Retirees    | Couples       | Existing        |    321,981,048                |    286,558,374               |    -35,422,674       | -11.00                          |
| OCEANIA  | Retail     | Middle Aged | Families      | Existing        |    239,971,442                |    212,140,211               |    -27,831,231       | -11.60                          |
| ASIA     | Retail     | Retirees    | Families      | Existing        |    263,781,527                |    237,915,427               |    -25,866,100       | -9.81                           |
| ASIA     | Retail     | Retirees    | Couples       | Existing        |    215,851,064                |    190,527,375               |    -25,323,689       | -11.73                          |
| USA      | Retail     | unknown     | unknown       | Guest           |    220,462,651                |    197,203,239               |    -23,259,412       | -10.55                          |
| AFRICA   | Retail     | Retirees    | Families      | Existing        |    292,038,157                |    269,415,746               |    -22,622,411       | -7.75                           |

Looking at the result, sales made from Retail mostly experienced a significant decrease in the number of sales made for the 12 weeks before and after the period. We can also see that the first 3 rows from the result have decreased in sales by more than $50 million. From those 3 rows alone, we can see that sales from customers that is not regularly purchased Data Mart's products probably don't know about the new packaging. Meaning, there should be a new way to market our product to the occasional customers so they know about the changes Data Mart made to the products.
