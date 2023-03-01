# :orange: Case Study 8 - Fresh Segments: Solution D. Index Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the `composition` column by the `index_value` column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?

    - Create the average composition column

        Query:

        ```sql
        SET search_path = 'fresh_segments';

        DROP TABLE IF EXISTS interest_metrics_comp;

        CREATE TEMPORARY TABLE interest_metrics_comp AS
        SELECT
            month_year,
            interest_id,
            composition,
            index_value,
            ROUND((composition / index_value)::NUMERIC, 2) AS composition_average,
            ranking,
            percentile_ranking
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL;
        ```

    - Finding the interests

        Query:

        ```sql
        WITH interest_ranking AS (
            SELECT
                month_year,
                interest_id,
                composition_average,
                ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_rank
            FROM
                interest_metrics_comp
        )
        SELECT
            i1.month_year,
            i2.interest_name,
            composition_average
        FROM
            interest_ranking AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        WHERE
            interest_rank <= 10
        ORDER BY
            i1.month_year,
            i1.interest_rank;
        ```

        Example output for **2018-07-01**:

        | "month_year" | "interest_name"               | "composition_average" |
        |--------------|-------------------------------|-----------------------|
        | 2018-07-01   | Las Vegas Trip Planners       | 7.36                  |
        | 2018-07-01   | Gym Equipment Owners          | 6.94                  |
        | 2018-07-01   | Cosmetics and Beauty Shoppers | 6.78                  |
        | 2018-07-01   | Luxury Retail Shoppers        | 6.61                  |
        | 2018-07-01   | Furniture Shoppers            | 6.51                  |
        | 2018-07-01   | Asian Food Enthusiasts        | 6.10                  |
        | 2018-07-01   | Recently Retired Individuals  | 5.72                  |
        | 2018-07-01   | Family Adventures Travelers   | 4.85                  |
        | 2018-07-01   | Work Comes First Travelers    | 4.80                  |
        | 2018-07-01   | HDTV Researchers              | 4.71                  |

    <br/>

2. For all of these top 10 interests - which interest appears the most often?

    Query:

    ```sql
    WITH interest_ranking AS (
        SELECT
            month_year,
            interest_id,
            composition_average,
            ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_comp_rank
        FROM
            interest_metrics_comp
    ),
    top_interest AS (
        SELECT
            i2.interest_name,
            COUNT(*) AS count_total,
            RANK() OVER (ORDER BY COUNT(*) DESC) AS interest_rank
        FROM
            interest_ranking AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        WHERE
            interest_comp_rank <= 10
        GROUP BY
            1
    )
    SELECT
        interest_name,
        count_total
    FROM
        top_interest
    WHERE
        interest_rank = 1;
    ```

    Output:

    | "interest_name"          | "count_total" |
    |--------------------------|---------------|
    | Solar Energy Researchers | 10            |
    | Alabama Trip Planners    | 10            |
    | Luxury Bedding Shoppers  | 10            |

    <br/>

3. What is the average of the average composition for the top 10 interests for each month?

    Query:

    ```sql
    WITH interest_ranking AS (
        SELECT
            month_year,
            composition_average,
            ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_comp_rank
        FROM
            interest_metrics_comp
    )
    SELECT
        month_year,
        ROUND(AVG(composition_average), 2) AS average_composition_average
    FROM
        interest_ranking
    WHERE
        interest_comp_rank <= 10
    GROUP BY
        1
    ORDER BY
        1;
    ```

    Output:

    | "month_year" | "average_composition_average" |
    |--------------|-------------------------------|
    | 2018-07-01   | 6.04                          |
    | 2018-08-01   | 5.95                          |
    | 2018-09-01   | 6.90                          |
    | 2018-10-01   | 7.07                          |
    | 2018-11-01   | 6.62                          |
    | 2018-12-01   | 6.65                          |
    | 2019-01-01   | 6.40                          |
    | 2019-02-01   | 6.58                          |
    | 2019-03-01   | 6.17                          |
    | 2019-04-01   | 5.75                          |
    | 2019-05-01   | 3.54                          |
    | 2019-06-01   | 2.43                          |
    | 2019-07-01   | 2.77                          |
    | 2019-08-01   | 2.63                          |

    <br/>

4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.

    Required output for question 4:

    <details>
    <summary>Click to expand</summary>

    | month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_months_ago                      |
    | :--------- | :---------------------------- | :-------------------- | :----------------- | :-------------------------------- | :-------------------------------- |
    | 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36     |
    | 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.20               | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21     |
    | 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26  |
    | 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14  |
    | 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28  |
    | 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31  |
    | 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
    | 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66  |
    | 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54       |
    | 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.49               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28    |
    | 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41 |
    | 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77     |

    </details>

    Query:

    ```sql
    WITH interest_ranking AS (
        SELECT
            month_year,
            interest_id,
            composition_average,
            ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY composition_average DESC) AS interest_rank
        FROM
            interest_metrics_comp
    ),
    max_previous_interest AS (
        SELECT
            i1.month_year,
            i2.interest_name,
            i1.composition_average,
            ROUND((AVG(i1.composition_average) OVER (ORDER BY i1.month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)), 2) AS comp_3_month_moving_avg,
            LAG(i2.interest_name) OVER (ORDER BY i1.month_year) AS interest_1_month_ago,
            LAG(i1.composition_average) OVER (ORDER BY i1.month_year) AS comp_1_month_ago,
            LAG(i2.interest_name, 2) OVER (ORDER BY i1.month_year) AS interest_2_month_ago,
            LAG(i1.composition_average) OVER (ORDER BY i1.month_year) AS comp_2_month_ago
        FROM
            interest_ranking AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        WHERE
            interest_rank = 1
    )
    SELECT
        month_year,
        interest_name,
        composition_average AS max_index_composition,
        comp_3_month_moving_avg AS "3_month_moving_avg",
        interest_1_month_ago || ': ' || comp_1_month_ago AS "1_month_ago",
        interest_2_month_ago || ': ' || comp_2_month_ago AS "2_months_ago"
    FROM
        max_previous_interest
    WHERE
        month_year >= '2018-09-01';
    ```

    Output:

    | "month_year" | "interest_name"               | "max_index_composition" | "3_month_moving_avg" | "1_month_ago"                     | "2_months_ago"                    |
    |--------------|-------------------------------|-------------------------|----------------------|-----------------------------------|-----------------------------------|
    | 2018-09-01   | Work Comes First Travelers    | 8.26                    | 7.61                 | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.21     |
    | 2018-10-01   | Work Comes First Travelers    | 9.14                    | 8.20                 | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 8.26     |
    | 2018-11-01   | Work Comes First Travelers    | 8.28                    | 8.56                 | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 9.14  |
    | 2018-12-01   | Work Comes First Travelers    | 8.31                    | 8.58                 | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 8.28  |
    | 2019-01-01   | Work Comes First Travelers    | 7.66                    | 8.08                 | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.31  |
    | 2019-02-01   | Work Comes First Travelers    | 7.66                    | 7.88                 | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
    | 2019-03-01   | Alabama Trip Planners         | 6.54                    | 7.29                 | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
    | 2019-04-01   | Solar Energy Researchers      | 6.28                    | 6.83                 | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 6.54  |
    | 2019-05-01   | Readers of Honduran Content   | 4.41                    | 5.74                 | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.28       |
    | 2019-06-01   | Las Vegas Trip Planners       | 2.77                    | 4.49                 | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 4.41    |
    | 2019-07-01   | Las Vegas Trip Planners       | 2.82                    | 3.33                 | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 2.77 |
    | 2019-08-01   | Cosmetics and Beauty Shoppers | 2.73                    | 2.77                 | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.82     |

    <br/>

5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

    - One possible reason based on the previous question is seasonal change. Based on the result, customer interaction on content related to travel/holiday is relatively higher than the other, especially during the holiday season or the end of the year. Because of this, the interaction on contents that are other than travel/holiday would be lower outside the holiday season.

---
