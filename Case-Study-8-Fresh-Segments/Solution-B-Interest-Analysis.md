# :orange: Case Study 8 - Fresh Segments: Solution B. Interest Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. Which interests have been present in all `month_year` dates in our dataset?

    - Let's find out how many interests satisfy this condition.

        Query:

        ```sql
        WITH interests_count AS (
            SELECT
                interest_id,
                COUNT(month_year) AS count_num
            FROM
                fresh_segments.interest_metrics
            WHERE
                month_year IS NOT NULL
            GROUP BY
                1
            HAVING
                COUNT(month_year) = (
                    SELECT
                        COUNT(DISTINCT month_year)
                    FROM
                        fresh_segments.interest_metrics))
        SELECT
            COUNT(*) AS interests_total
        FROM
            interests_count;
        ```

        Output:

        | "interests_total" |
        |-------------------|
        | 480               |

    - Let's see some of these interests

        First 5 rows:

        | "interest_name"           |
        |---------------------------|
        | Luxury Retail Researchers |
        | Brides & Wedding Planners |
        | Vacation Planners         |
        | Thrift Store Shoppers     |
        | NBA Fans                  |

    <br>

2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?

    Query:

    ```sql
    WITH interests_count AS (
        SELECT
            interest_id,
            COUNT(*) AS month_year_num
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
        GROUP BY
            1
        ORDER BY
            2 DESC
    ),
    month_year_count AS (
        SELECT
            month_year_num,
            COUNT(*) AS month_year_count
        FROM
            interests_count
        GROUP BY
            1
    )
    SELECT
        *,
        ROUND((SUM(month_year_count) OVER (ORDER BY month_year_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(month_year_count) OVER () * 100), 1) AS cumulative_percentage
    FROM
        month_year_count
    ORDER BY
        1 DESC;
    ```

    Output:

    | "month_year_num" | "month_year_count" | "cumulative_percentage" |
    |------------------|--------------------|-------------------------|
    | 14               | 480                | 39.9                    |
    | 13               | 82                 | 46.8                    |
    | 12               | 65                 | 52.2                    |
    | 11               | 94                 | 60.0                    |
    | 10               | 86                 | 67.1                    |
    | 9                | 95                 | 75.0                    |
    | 8                | 67                 | 80.6                    |
    | 7                | 90                 | 88.1                    |
    | 6                | 33                 | 90.8                    |
    | 5                | 38                 | 94.0                    |
    | 4                | 32                 | 96.7                    |
    | 3                | 15                 | 97.9                    |
    | 2                | 12                 | 98.9                    |
    | 1                | 13                 | 100.0                   |

    <br>

3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

    Query:

    ```sql
    WITH interest_id_list AS (
        SELECT
            interest_id,
            COUNT(*) AS month_year_num
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
        GROUP BY
            1
        HAVING
            COUNT(*) >= 6
    )
    SELECT
        COUNT(*) AS data_points_total
    FROM
        fresh_segments.interest_metrics
    WHERE
        interest_id NOT IN (
            SELECT
                interest_id
            FROM
                interest_id_list)
    ```

    Output:

    | "data_points_total" |
    |---------------------|
    | 400                 |

    <br>

4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

    - The decision to remove those data points means that the business can focus on the interests that attract customers and not waste their time on interest with less interaction. Also, we only remove a small portion of the data for each month.

        Query:

        ```sql
        WITH interest_id_list AS (
            SELECT
                interest_id,
                COUNT(*) AS month_year_num
            FROM
                fresh_segments.interest_metrics
            WHERE
                month_year IS NOT NULL
            GROUP BY
                1
            HAVING
                COUNT(*) >= 6
        ),
        interest_id_included AS (
            SELECT
                month_year,
                COUNT(*) AS interest_ids
            FROM
                fresh_segments.interest_metrics
            WHERE
                month_year IS NOT NULL
                AND interest_id IN (
                    SELECT
                        interest_id
                    FROM
                        interest_id_list)
                GROUP BY
                    1
        ),
        interest_id_excluded AS (
            SELECT
                month_year,
                COUNT(*) AS interest_ids
        FROM
            fresh_segments.interest_metrics
            WHERE
                month_year IS NOT NULL
                AND interest_id NOT IN (
                    SELECT
                        interest_id
                    FROM
                        interest_id_list)
                GROUP BY
                    1
        )
        SELECT
            i1.month_year,
            i1.interest_ids AS included_total,
            i2.interest_ids AS excluded_total,
            ROUND((100 * i2.interest_ids::NUMERIC / i1.interest_ids), 2) AS excluded_percentage
        FROM
            interest_id_included AS i1
            JOIN interest_id_excluded AS i2 ON i1.month_year = i2.month_year
        ORDER BY
            1;
        ```

        Output:

        | "month_year" | "included_total" | "excluded_total" | "excluded_percentage" |
        |--------------|------------------|------------------|-----------------------|
        | 2018-07-01   | 709              | 20               | 2.82                  |
        | 2018-08-01   | 752              | 15               | 1.99                  |
        | 2018-09-01   | 774              | 6                | 0.78                  |
        | 2018-10-01   | 853              | 4                | 0.47                  |
        | 2018-11-01   | 925              | 3                | 0.32                  |
        | 2018-12-01   | 986              | 9                | 0.91                  |
        | 2019-01-01   | 966              | 7                | 0.72                  |
        | 2019-02-01   | 1072             | 49               | 4.57                  |
        | 2019-03-01   | 1078             | 58               | 5.38                  |
        | 2019-04-01   | 1035             | 64               | 6.18                  |
        | 2019-05-01   | 827              | 30               | 3.63                  |
        | 2019-06-01   | 804              | 20               | 2.49                  |
        | 2019-07-01   | 836              | 28               | 3.35                  |
        | 2019-08-01   | 1062             | 87               | 8.19                  |

    <br>

5. After removing these interests - how many unique interests are there for each month?

    Query:

    ```sql
    WITH interest_id_list AS (
        SELECT
            interest_id,
            COUNT(*) AS month_year_num
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
        GROUP BY
            1
        HAVING
            COUNT(*) >= 6
    ),
    interest_id_included AS (
        SELECT
            month_year,
            COUNT(*) AS interest_ids
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
            AND interest_id IN (
                SELECT
                    interest_id
                FROM
                    interest_id_list)
            GROUP BY
                1
    ),
    interest_id_excluded AS (
        SELECT
            month_year,
            COUNT(*) AS interest_ids
    FROM
        fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
            AND interest_id NOT IN (
                SELECT
                    interest_id
                FROM
                    interest_id_list)
            GROUP BY
                1
    )
    SELECT
        i1.month_year,
        (i1.interest_ids - i2.interest_ids) AS interest_id_total,
        SUM((i1.interest_ids - i2.interest_ids)) OVER() AS interests_total
    FROM
        interest_id_included AS i1
        JOIN interest_id_excluded AS i2 ON i1.month_year = i2.month_year
    ORDER BY
        1;
    ```

    Output:

    | "month_year" | "interest_id_total" | "interests_total" |
    |--------------|---------------------|-------------------|
    | 2018-07-01   | 689                 | 12279             |
    | 2018-08-01   | 737                 | 12279             |
    | 2018-09-01   | 768                 | 12279             |
    | 2018-10-01   | 849                 | 12279             |
    | 2018-11-01   | 922                 | 12279             |
    | 2018-12-01   | 977                 | 12279             |
    | 2019-01-01   | 959                 | 12279             |
    | 2019-02-01   | 1023                | 12279             |
    | 2019-03-01   | 1020                | 12279             |
    | 2019-04-01   | 971                 | 12279             |
    | 2019-05-01   | 797                 | 12279             |
    | 2019-06-01   | 784                 | 12279             |
    | 2019-07-01   | 808                 | 12279             |
    | 2019-08-01   | 975                 | 12279             |

---
