# :orange: Case Study 8 - Fresh Segments: Solution A. Data Exploration and Cleansing

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month

    Query:

    ```sql
    ALTER TABLE fresh_segments.interest_metrics
        ALTER COLUMN month_year TYPE DATE
        USING TO_DATE(month_year, 'MM-YYYY');
    ```

    Output (first 5 rows):

    | "_month" | "_year" | "month_year" | "interest_id" | "composition" | "index_value" | "ranking" | "percentile_ranking" |
    |----------|---------|--------------|---------------|---------------|---------------|-----------|----------------------|
    | 7        | 2018    | 2018-07-01   | 32486         | 11.89         | 6.19          | 1         | 99.86                |
    | 7        | 2018    | 2018-07-01   | 6106          | 9.93          | 5.31          | 2         | 99.73                |
    | 7        | 2018    | 2018-07-01   | 18923         | 10.85         | 5.29          | 3         | 99.59                |
    | 7        | 2018    | 2018-07-01   | 6344          | 10.32         | 5.1           | 4         | 99.45                |
    | 7        | 2018    | 2018-07-01   | 100           | 10.77         | 5.04          | 5         | 99.31                |

    <br>

2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?

    Query:

    ```sql
    SELECT
        month_year,
        COUNT(*) AS records_num
    FROM
        fresh_segments.interest_metrics
    GROUP BY
        1
    ORDER BY
        1 NULLS FIRST;
    ```

    Output:

    | "month_year" | "records_num" |
    |--------------|---------------|
    |              | 1194          |
    | 2018-07-01   | 729           |
    | 2018-08-01   | 767           |
    | 2018-09-01   | 780           |
    | 2018-10-01   | 857           |
    | 2018-11-01   | 928           |
    | 2018-12-01   | 995           |
    | 2019-01-01   | 973           |
    | 2019-02-01   | 1121          |
    | 2019-03-01   | 1136          |
    | 2019-04-01   | 1099          |
    | 2019-05-01   | 857           |
    | 2019-06-01   | 824           |
    | 2019-07-01   | 864           |
    | 2019-08-01   | 1149          |

    <br>

3. What do you think we should do with these `null` values in the `fresh_segments.interest_metrics`

    - Dropping the rows where the month_year value is missing could be the right thing to do. This is because there are rows with missing values on month_year column and also have missing interest_id values. That means the aggregated values for those rows don't point/map to any interest in the fresh_segment.interest_map table.

        Query:

        ```sql
        SELECT *
        FROM fresh_segments.interest_metrics
        WHERE new_month_year IS NULL;
        ```

        Output:

        | _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking | new_month_year |
        | ------ | ----- | ---------- | ----------- | ----------- | ----------- | ------- | ------------------ | -------------- |
        | NULL   | NULL  | NULL       | NULL        | 6.12        | 2.85        | 43      | 96.4               | NULL           |
        | NULL   | NULL  | NULL       | NULL        | 7.13        | 2.84        | 45      | 96.23              | NULL           |
        | NULL   | NULL  | NULL       | NULL        | 6.82        | 2.84        | 45      | 96.23              | NULL           |
        | NULL   | NULL  | NULL       | NULL        | 5.96        | 2.83        | 47      | 96.06              | NULL           |
        | NULL   | NULL  | NULL       | NULL        | 7.73        | 2.82        | 48      | 95.98              | NULL           |

    <br>

4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?

    - `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map`

        Query:

        ```sql
        SELECT
            COUNT(*) AS interest_metrics_id_num
        FROM
            fresh_segments.interest_metrics
        WHERE
            interest_id::INTEGER NOT IN (
                SELECT
                    DISTINCT id
                FROM
                    fresh_segments.interest_map);

        ```

        Output:

        | "interest_metrics_id_num" |
        |---------------------------|
        | 0                         |

    - `id` values exist in the `fresh_segments.interest_map` table but not in the `fresh_segments.interest_metrics`

        Query:

        ```sql
        SELECT
            COUNT(id) AS interest_map_id_num
        FROM
            fresh_segments.interest_map
        WHERE
            id NOT IN ( SELECT DISTINCT
                    interest_id::INTEGER
                FROM
                    fresh_segments.interest_metrics
                WHERE
                    interest_id IS NOT NULL);
        ```

        Output:

        | "interest_map_id_num" |
        |-----------------------|
        | 7                     |

    <br>

5. Summarise the id values in the `fresh_segments.interest_map` by its total record count in this table

    - Because each id in this table represents each interest name from the client and its summary, each id would only occur once in this table, for example, the first 5 rows in the result show the count of each interest equal to 1.

        Query:

        ```sql
        SELECT
            id,
            COUNT(*) AS id_num
        FROM
            fresh_segments.interest_map
        GROUP BY
            1;
        ```

        Output (first 5 rows):

        | id  | cnt |
        | --- | --- |
        | 1   | 1   |
        | 2   | 1   |
        | 3   | 1   |
        | 4   | 1   |
        | 5   | 1   |

    <br>

6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id = 21246` in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column.

    - The `interest_id` that is equal to 21246 has an interest with a missing value for the `_month`, `_year`, and the `month_year` value. To remove the unwanted missing values, we can find join the two tables between the id columns and find the `month_year` that is equal to or bigger than the created_at column from the `interest_map` table.

        Query:

        ```sql
        SELECT
            i1.*,
            i2.interest_summary,
            i2.created_at,
            i2.last_modified
        FROM
            fresh_segments.interest_metrics AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
                AND i1.month_year >= i2.created_at
        WHERE
            i1.interest_id = '21246'
        ORDER BY
            3;
        ```

        Output:

        | "_month" | "_year" | "month_year" | "interest_id" | "composition" | "index_value" | "ranking" | "percentile_ranking" | "interest_summary"                                    | "created_at"        | "last_modified"     |
        |----------|---------|--------------|---------------|---------------|---------------|-----------|----------------------|-------------------------------------------------------|---------------------|---------------------|
        | 7        | 2018    | 2018-07-01   | 21246         | 2.26          | 0.65          | 722       | 0.96                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 8        | 2018    | 2018-08-01   | 21246         | 2.13          | 0.59          | 765       | 0.26                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 9        | 2018    | 2018-09-01   | 21246         | 2.06          | 0.61          | 774       | 0.77                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 10       | 2018    | 2018-10-01   | 21246         | 1.74          | 0.58          | 855       | 0.23                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 11       | 2018    | 2018-11-01   | 21246         | 2.25          | 0.78          | 908       | 2.16                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 12       | 2018    | 2018-12-01   | 21246         | 1.97          | 0.7           | 983       | 1.21                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 1        | 2019    | 2019-01-01   | 21246         | 2.05          | 0.76          | 954       | 1.95                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 2        | 2019    | 2019-02-01   | 21246         | 1.84          | 0.68          | 1109      | 1.07                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 3        | 2019    | 2019-03-01   | 21246         | 1.75          | 0.67          | 1123      | 1.14                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
        | 4        | 2019    | 2019-04-01   | 21246         | 1.58          | 0.63          | 1092      | 0.64                 | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |

    <br>

7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the fresh_segments.`interest_map` table? Do you think these values are valid and why?

    - Finding how many records with this condition

        Query:

        ```sql
        SELECT
            COUNT(*) AS rows_total
        FROM
            fresh_segments.interest_metrics AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
                AND i1.month_year < i2.created_at;
        ```

        Output:

        | count |
        | ----- |
        | 188   |

    - There are **188 records** with this condition. Let's see some example of it.

        Query:

        ```sql
        SELECT
            i1.month_year,
            i2.created_at
        FROM
            fresh_segments.interest_metrics AS i1 TABLESAMPLE BERNOULLI (2) -- Sampling the data
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
                AND i1.month_year < i2.created_at;
        ```

        Output:

        | "month_year" | "created_at"        |
        |--------------|---------------------|
        | 2018-11-01   | 2018-11-02 17:10:04 |
        | 2018-11-01   | 2018-11-02 17:10:05 |
        | 2019-01-01   | 2019-01-10 11:10:05 |
        | 2019-02-01   | 2019-02-04 22:00:00 |
        | 2019-02-01   | 2019-02-06 21:00:01 |

    - This result is valid because the `month_year` value is basically aggregated values for that month of the year.

---
