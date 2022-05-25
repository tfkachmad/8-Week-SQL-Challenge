# :orange: Case Study 8 - Fresh Segments: Solution C. Segment Analysis

![badge](https://img.shields.io/badge/Powered%20By-SQL%20Server-%23CC2927?logo=microsoftsqlserver)

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year`

    - Let's create the filtered table first

        Query:

        ```sql
        DROP TABLE IF EXISTS #sub_metrics;
        WITH total_months_CTE
        AS (
            SELECT interest_id
                ,COUNT(DISTINCT new_month_year) AS total_months
            FROM fresh_segments.interest_metrics
            WHERE new_month_year IS NOT NULL
            GROUP BY interest_id
            HAVING COUNT(DISTINCT new_month_year) >= 6
            )
        SELECT *
        INTO #sub_metrics
        FROM fresh_segments.interest_metrics
        WHERE interest_id IN (
                SELECT interest_id
                FROM total_months_CTE
                );
        ```

    - Finding the top 10 interests with **highest** composition value.

        Query:

        ```sql
        WITH max_CTE
        AS (
            SELECT new_month_year
                ,interest_id
                ,MAX(composition) AS comp
            FROM #sub_metrics
            GROUP BY new_month_year
                ,interest_id
            )
            ,row_CTE
        AS (
            SELECT *
                ,ROW_NUMBER() OVER (
                    ORDER BY comp DESC
                    ) AS highest
                ,ROW_NUMBER() OVER (
                    ORDER BY comp
                    ) AS lowest
            FROM max_CTE
            )
        SELECT t1.new_month_year, map.interest_name, t1.comp AS composition_value
        FROM row_CTE AS t1
        JOIN fresh_segments.interest_map AS map ON t1.interest_id = map.id
        WHERE highest <= 10
        ORDER BY comp DESC;
        ```

        Result:

        | new_month_year | interest_name                     | composition_value |
        | -------------- | --------------------------------- | ----------------- |
        | 2018-12-01     | Work Comes First Travelers        | 21.2              |
        | 2018-10-01     | Work Comes First Travelers        | 20.28             |
        | 2018-11-01     | Work Comes First Travelers        | 19.45             |
        | 2019-01-01     | Work Comes First Travelers        | 18.99             |
        | 2018-07-01     | Gym Equipment Owners              | 18.82             |
        | 2019-02-01     | Work Comes First Travelers        | 18.39             |
        | 2018-09-01     | Work Comes First Travelers        | 18.18             |
        | 2018-07-01     | Furniture Shoppers                | 17.44             |
        | 2018-07-01     | Luxury Retail Shoppers            | 17.19             |
        | 2018-10-01     | Luxury Boutique Hotel Researchers | 15.15             |

    - Finding the top 10 interests with **lowest** composition value.

        Query:

        ```sql
        WITH max_CTE
        AS (
            SELECT new_month_year
                ,interest_id
                ,MAX(composition) AS comp
            FROM #sub_metrics
            GROUP BY new_month_year
                ,interest_id
            )
            ,row_CTE
        AS (
            SELECT *
                ,ROW_NUMBER() OVER (
                    ORDER BY comp DESC
                    ) AS highest
                ,ROW_NUMBER() OVER (
                    ORDER BY comp
                    ) AS lowest
            FROM max_CTE
            )
        SELECT t1.new_month_year, map.interest_name, t1.comp AS composition_value
        FROM row_CTE AS t1
        JOIN fresh_segments.interest_map AS map ON t1.interest_id = map.id
        WHERE lowest <= 10
        ORDER BY comp;
        ```

        Result:

        | new_month_year | interest_name                | composition_value |
        | -------------- | ---------------------------- | ----------------- |
        | 2019-05-01     | Mowing Equipment Shoppers    | 1.51              |
        | 2019-06-01     | Disney Fans                  | 1.52              |
        | 2019-05-01     | Beer Aficionados             | 1.52              |
        | 2019-06-01     | New York Giants Fans         | 1.52              |
        | 2019-05-01     | Gastrointestinal Researchers | 1.52              |
        | 2019-05-01     | Philadelphia 76ers Fans      | 1.52              |
        | 2019-04-01     | United Nations Donors        | 1.52              |
        | 2019-05-01     | LED Lighting Shoppers        | 1.53              |
        | 2019-06-01     | Online Directory Searchers   | 1.53              |
        | 2019-05-01     | Crochet Enthusiasts          | 1.53              |

    <br/>

2. Which 5 interests had the lowest average ranking value?

    Query:

    ```sql
    WITH rank_CTE
    AS (
        SELECT interest_id
            ,AVG(ranking) AS ranking_avg
        FROM #sub_metrics
        GROUP BY interest_id
        )
        ,row_CTE
    AS (
        SELECT *
            ,ROW_NUMBER() OVER (
                ORDER BY ranking_avg DESC
                ) AS rnk
        FROM rank_CTE
        )
    SELECT interest_name, ranking_avg
    FROM row_CTE AS r
    JOIN fresh_segments.interest_map AS m
        ON r.interest_id = m.id
    WHERE rnk <= 5;
    ```

    Output:

    | interest_name                                      | ranking_avg |
    | -------------------------------------------------- | ----------- |
    | Astrology Enthusiasts                              | 968         |
    | Computer Processor and Data Center Decision Makers | 974         |
    | Medieval History Enthusiasts                       | 961         |
    | Budget Mobile Phone Researchers                    | 961         |
    | League of Legends Video Game Fans                  | 1037        |

    <br/>

3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?

    Query:

    ```sql
    WITH std_CTE
    AS (
        SELECT interest_id
            ,ROUND(STDEV(percentile_ranking), 2) AS percentile_ranking_std
        FROM #sub_metrics
        GROUP BY interest_id
        )
        ,row_CTE
    AS (
        SELECT interest_id
            ,percentile_ranking_std
            ,ROW_NUMBER() OVER (
                ORDER BY percentile_ranking_std DESC
                ) AS rn
        FROM std_CTE
        )
    SELECT interest_name, percentile_ranking_std
    FROM row_CTE AS r
    JOIN fresh_segments.interest_map AS m ON r.interest_id = m.id
    WHERE rn <= 5
    ORDER BY rn;
    ```

    Output:

    | interest_name                          | percentile_ranking_std |
    | -------------------------------------- | ---------------------- |
    | Techies                                | 30.18                  |
    | Entertainment Industry Decision Makers | 28.97                  |
    | Oregon Trip Planners                   | 28.32                  |
    | Personalized Gift Shoppers             | 26.24                  |
    | Tampa and St Petersburg Trip Planners  | 25.61                  |

    <br/>

4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

    - The 5 interests are having lower percentile_ranking along the time. For example, `Techies` that have **86.69** `percentile_ranking` on **2018-07-01**, on **2019-08-01** having only **7.92**. This means, its composition, or customer interaction for this interest are getting lower along the time.

    Query:

    ```sql
    WITH std_CTE
    AS (
        SELECT interest_id
            ,ROUND(STDEV(percentile_ranking), 2) AS percentile_ranking_std
        FROM #sub_metrics
        GROUP BY interest_id
        )
        ,row_CTE
    AS (
        SELECT interest_id
            ,percentile_ranking_std
            ,ROW_NUMBER() OVER (
                ORDER BY percentile_ranking_std DESC
                ) AS rn
        FROM std_CTE
        )
        ,interest_CTE
    AS (
        SELECT interest_id
        FROM row_CTE AS r
        WHERE rn <= 5
        )
        ,ranking_CTE
    AS (
        SELECT new_month_year
            ,interest_id
            ,percentile_ranking
            ,ROW_NUMBER() OVER (
                PARTITION BY interest_id ORDER BY percentile_ranking
                ) AS min_rn
            ,ROW_NUMBER() OVER (
                PARTITION BY interest_id ORDER BY percentile_ranking DESC
                ) AS max_rn
        FROM #sub_metrics
        WHERE interest_id IN (
                SELECT interest_id
                FROM interest_CTE
                )
        )
    SELECT r.new_month_year
        ,m.interest_name
        ,r.percentile_ranking
    FROM ranking_CTE AS r
    JOIN fresh_segments.interest_map AS m
        ON r.interest_id = m.id
    WHERE min_rn = 1
        OR max_rn = 1
    ORDER BY interest_id, percentile_ranking;
    ```

    Output:

    | new_month_year | interest_name                          | percentile_ranking |
    | -------------- | -------------------------------------- | ------------------ |
    | 2019-03-01     | Tampa and St Petersburg Trip Planners  | 4.84               |
    | 2018-07-01     | Tampa and St Petersburg Trip Planners  | 75.03              |
    | 2019-08-01     | Entertainment Industry Decision Makers | 11.23              |
    | 2018-07-01     | Entertainment Industry Decision Makers | 86.15              |
    | 2019-08-01     | Techies                                | 7.92               |
    | 2018-07-01     | Techies                                | 86.69              |
    | 2019-07-01     | Oregon Trip Planners                   | 2.2                |
    | 2018-11-01     | Oregon Trip Planners                   | 82.44              |
    | 2019-06-01     | Personalized Gift Shoppers             | 5.7                |
    | 2019-03-01     | Personalized Gift Shoppers             | 73.15              |

    <br/>

5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

    - Based on the top interests with highest composition value, the majority of customers possibly are **adult** with interest in traveling. The contents/interest that have higher interaction are the indicator for that, for example *Work Comes First Travelers*.
    - Contents that are related with travelling would be the best things to show to these customers. It's better to avoid showing contents that related to sport and games because they attract less interaction from our customers.

---
