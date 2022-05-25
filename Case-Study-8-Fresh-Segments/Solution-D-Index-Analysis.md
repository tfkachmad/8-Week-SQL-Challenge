# :orange: Case Study 8 - Fresh Segments: Solution D. Index Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the `composition` column by the `index_value` column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?

    - Create the average composition column

        Query:

        ```sql
        DROP TABLE IF EXISTS #new_interest_matrics;
        SELECT *, ROUND((CAST(composition AS float) / index_value), 2) AS average_composition
        INTO #new_interest_matrics
        FROM fresh_segments.interest_metrics;
        ```

    - Finding the interests

        Query:

        ```sql
        WITH interest_CTE
        AS (
            SELECT interest_id
                ,new_month_year
                ,average_composition
                ,interest_name
                ,ROW_NUMBER() OVER (
                    PARTITION BY new_month_year ORDER BY average_composition DESC
                    ) AS rn
            FROM #new_interest_matrics AS mat
            JOIN fresh_segments.interest_map AS map
                ON mat.interest_id = map.id
            WHERE new_month_year IS NOT NULL
            )
        SELECT new_month_year
            ,interest_name
            ,average_composition
        FROM interest_CTE
        WHERE rn BETWEEN 1
                AND 10;
        ```

        Example output for **2018-07-01**:

        | new_month_year | interest_name                 | average_composition |
        | -------------- | ----------------------------- | ------------------- |
        | 2018-07-01     | Las Vegas Trip Planners       | 7.36                |
        | 2018-07-01     | Gym Equipment Owners          | 6.94                |
        | 2018-07-01     | Cosmetics and Beauty Shoppers | 6.78                |
        | 2018-07-01     | Luxury Retail Shoppers        | 6.61                |
        | 2018-07-01     | Furniture Shoppers            | 6.51                |
        | 2018-07-01     | Asian Food Enthusiasts        | 6.1                 |
        | 2018-07-01     | Recently Retired Individuals  | 5.72                |
        | 2018-07-01     | Family Adventures Travelers   | 4.85                |
        | 2018-07-01     | Work Comes First Travelers    | 4.8                 |
        | 2018-07-01     | HDTV Researchers              | 4.71                |

    <br/>

2. For all of these top 10 interests - which interest appears the most often?

    Query:

    ```sql
    WITH interest_CTE
    AS (
        SELECT interest_id
            ,new_month_year
            ,average_composition
            ,CAST(interest_name AS VARCHAR) AS interest_name
            ,ROW_NUMBER() OVER (
                PARTITION BY new_month_year ORDER BY average_composition DESC
                ) AS rn
        FROM #new_interest_matrics AS mat
        JOIN fresh_segments.interest_map AS map
            ON mat.interest_id = map.id
        WHERE new_month_year IS NOT NULL
        )
        ,top_interest_CTE
    AS (
        SELECT interest_id
            ,new_month_year
            ,interest_name
            ,average_composition
        FROM interest_CTE
        WHERE rn BETWEEN 1
                AND 10
        )
        ,ranking_CTE
    AS (
        SELECT interest_name
            ,COUNT(interest_name) AS appearance_cnt
            ,RANK() OVER (
                ORDER BY COUNT(interest_name) DESC
                ) AS rnk
        FROM top_interest_CTE
        GROUP BY interest_name
        )
    SELECT interest_name
        ,appearance_cnt
    FROM ranking_CTE
    WHERE rnk = 1;
    ```

    Output:

    | interest_name            | appearance_cnt |
    | ------------------------ | -------------- |
    | Solar Energy Researchers | 10             |
    | Luxury Bedding Shoppers  | 10             |
    | Alabama Trip Planners    | 10             |

    <br/>

3. What is the average of the average composition for the top 10 interests for each month?

    Query:

    ```sql
    WITH interest_CTE
    AS (
        SELECT interest_id
            ,new_month_year
            ,average_composition
            ,interest_name
            ,ROW_NUMBER() OVER (
                PARTITION BY new_month_year ORDER BY average_composition DESC
                ) AS rn
        FROM #new_interest_matrics AS mat
        JOIN fresh_segments.interest_map AS map
            ON mat.interest_id = map.id
        WHERE new_month_year IS NOT NULL
        )
    SELECT new_month_year
        ,ROUND((AVG(average_composition)), 2) AS average_composition_avg
    FROM interest_CTE
    WHERE rn BETWEEN 1
            AND 10
    GROUP BY new_month_year;
    ```

    Output:

    | new_month_year | average_composition_avg |
    | -------------- | ----------------------- |
    | 2018-07-01     | 6.04                    |
    | 2018-08-01     | 5.94                    |
    | 2018-09-01     | 6.89                    |
    | 2018-10-01     | 7.07                    |
    | 2018-11-01     | 6.62                    |
    | 2018-12-01     | 6.65                    |
    | 2019-01-01     | 6.4                     |
    | 2019-02-01     | 6.58                    |
    | 2019-03-01     | 6.17                    |
    | 2019-04-01     | 5.75                    |
    | 2019-05-01     | 3.54                    |
    | 2019-06-01     | 2.43                    |
    | 2019-07-01     | 2.76                    |
    | 2019-08-01     | 2.63                    |

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
    WITH numbering_CTE
    AS (
        SELECT new_month_year
            ,interest_id
            ,average_composition
            ,ROW_NUMBER() OVER (
                PARTITION BY new_month_year ORDER BY average_composition DESC
                ) AS rn
        FROM #new_interest_matrics
        WHERE new_month_year IS NOT NULL
        )
        ,max_average_comp_CTE
    AS (
        SELECT n.new_month_year
            ,CAST(m.interest_name AS VARCHAR) AS interest_name
            ,n.average_composition AS max_index_composition
            ,ROUND((
                    AVG(n.average_composition) OVER (
                        ORDER BY n.new_month_year ROWS BETWEEN 2 PRECEDING
                                AND CURRENT ROW
                        )
                    ), 2) AS [3_month_moving_avg]
        FROM numbering_CTE AS n
        JOIN fresh_segments.interest_map AS m
            ON n.interest_id = m.id
        WHERE rn = 1
        )
        ,lag_CTE
    AS (
        SELECT *
            ,LAG(interest_name, 1) OVER (
                ORDER BY new_month_year
                ) AS interest_1_month
            ,LAG(interest_name, 2) OVER (
                ORDER BY new_month_year
                ) AS interest_2_month
            ,CAST((
                    LAG(max_index_composition, 1) OVER (
                        ORDER BY new_month_year
                        )
                    ) AS VARCHAR) AS [1_month_ago]
            ,CAST((
                    LAG(max_index_composition, 2) OVER (
                        ORDER BY new_month_year
                        )
                    ) AS VARCHAR) AS [2_month_ago]
        FROM max_average_comp_CTE
        )
    SELECT new_month_year
        ,interest_name
        ,max_index_composition
        ,[3_month_moving_avg]
        ,(interest_1_month + ': ' + [1_month_ago]) AS [1_month_ago]
        ,(interest_2_month + + ': ' + [2_month_ago]) AS [2_month_ago]
    FROM lag_CTE
    WHERE new_month_year BETWEEN '2018-09-01'
            AND '2019-08-01';
    ```

    Output:

    | new_month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_month_ago                       |
    | -------------- | ----------------------------- | --------------------- | ------------------ | --------------------------------- | --------------------------------- |
    | 2018-09-01     | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36     |
    | 2018-10-01     | Work Comes First Travelers    | 9.14                  | 8.2                | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21     |
    | 2018-11-01     | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26  |
    | 2018-12-01     | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14  |
    | 2019-01-01     | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28  |
    | 2019-02-01     | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31  |
    | 2019-03-01     | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
    | 2019-04-01     | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66  |
    | 2019-05-01     | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54       |
    | 2019-06-01     | Las Vegas Trip Planners       | 2.77                  | 4.49               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28    |
    | 2019-07-01     | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41 |
    | 2019-08-01     | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77     |

    <br/>

5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

    - One possible reason based on the previous question is seasonal change. Based on the result, the customer interaction on contents that related to travel/holiday are relatively higher than the other, especially on the holiday season or end of the year. Because of this, the interaction on contents that are other than travel/holiday would be lower outside the holiday season.

---
