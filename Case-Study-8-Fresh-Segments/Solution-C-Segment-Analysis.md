# :orange: Case Study 8 - Fresh Segments: Solution C. Segment Analysis

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year`

    - Let's create the filtered table first

        Query:

        ```sql
        SET search_path = 'fresh_segments';

        CREATE TEMPORARY TABLE IF NOT EXISTS filtered_interest AS
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
            *
        FROM
            fresh_segments.interest_metrics
        WHERE
            month_year IS NOT NULL
            AND interest_id IN (
                SELECT
                    interest_id
                FROM
                    interest_id_list);
        ```

    - Finding the top 10 interests with **highest** composition value.

        Query:

        ```sql
        WITH interest_composition AS (
            SELECT
                month_year,
                interest_id,
                MAX(composition) AS max_composition
            FROM
                filtered_interest
            GROUP BY
                1,
                2
        ),
        interest_ranking AS (
            SELECT
                *,
                ROW_NUMBER() OVER (ORDER BY max_composition DESC) AS top_interest
            FROM
                interest_composition
        )
        SELECT
            i1.month_year,
            i2.interest_name,
            i1.max_composition
        FROM
            interest_ranking AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        WHERE
            top_interest <= 10
        ORDER BY
            1;
        ```

        Result:

    | "month_year" | "interest_name"                   | "max_composition" |
    |--------------|-----------------------------------|-------------------|
    | 2018-07-01   | Gym Equipment Owners              | 18.82             |
    | 2018-07-01   | Luxury Retail Shoppers            | 17.19             |
    | 2018-07-01   | Furniture Shoppers                | 17.44             |
    | 2018-09-01   | Work Comes First Travelers        | 18.18             |
    | 2018-10-01   | Luxury Boutique Hotel Researchers | 15.15             |
    | 2018-10-01   | Work Comes First Travelers        | 20.28             |
    | 2018-11-01   | Work Comes First Travelers        | 19.45             |
    | 2018-12-01   | Work Comes First Travelers        | 21.2              |
    | 2019-01-01   | Work Comes First Travelers        | 18.99             |
    | 2019-02-01   | Work Comes First Travelers        | 18.39             |

    - Finding the top 10 interests with **lowest** composition value.

        Query:

        ```sql
        WITH interest_composition AS (
            SELECT
                month_year,
                interest_id,
                MAX(composition) AS max_composition
            FROM
                filtered_interest
            GROUP BY
                1,
                2
        ),
        interest_ranking AS (
            SELECT
                *,
                ROW_NUMBER() OVER (ORDER BY max_composition) AS bottom_interest
            FROM
                interest_composition
        )
        SELECT
            i1.month_year,
            i2.interest_name,
            i1.max_composition
        FROM
            interest_ranking AS i1
            JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
        WHERE
            bottom_interest < 10
        ORDER BY
            1;
        ```

        Result:

        | "month_year" | "interest_name"              | "max_composition" |
        |--------------|------------------------------|-------------------|
        | 2019-04-01   | United Nations Donors        | 1.52              |
        | 2019-05-01   | Beer Aficionados             | 1.52              |
        | 2019-05-01   | Gastrointestinal Researchers | 1.52              |
        | 2019-05-01   | Philadelphia 76ers Fans      | 1.52              |
        | 2019-05-01   | Mowing Equipment Shoppers    | 1.51              |
        | 2019-05-01   | LED Lighting Shoppers        | 1.53              |
        | 2019-05-01   | Crochet Enthusiasts          | 1.53              |
        | 2019-06-01   | New York Giants Fans         | 1.52              |
        | 2019-06-01   | Disney Fans                  | 1.52              |

    <br>

2. Which 5 interests had the lowest average ranking value?

    Query:

    ```sql
    WITH interest_ranking AS (
        SELECT
            interest_id,
            ROUND(AVG(ranking)) AS rank_average
        FROM
            filtered_interest
        GROUP BY
            1
    ),
    interest_ranking_rank AS (
        SELECT
            interest_id,
            rank_average,
            ROW_NUMBER() OVER (ORDER BY rank_average DESC) AS ranking_rank
        FROM
            interest_ranking
    )
    SELECT
        i2.interest_name,
        i1.rank_average
    FROM
        interest_ranking_rank AS i1
        JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
    WHERE
        ranking_rank <= 5;
    ```

    Output:

    | "interest_name"                                    | "rank_average" |
    |----------------------------------------------------|----------------|
    | League of Legends Video Game Fans                  | 1037           |
    | Computer Processor and Data Center Decision Makers | 974            |
    | Astrology Enthusiasts                              | 969            |
    | Medieval History Enthusiasts                       | 962            |
    | Budget Mobile Phone Researchers                    | 961            |

    <br>

3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?

    Query:

    ```sql
    WITH interest_percentile_ranking AS (
        SELECT
            interest_id,
            ROUND(STDDEV(percentile_ranking)::NUMERIC, 2) AS percentile_ranking_std
        FROM
            filtered_interest
        GROUP BY
            1
    ),
    percentile_ranking_rank AS (
        SELECT
            interest_id,
            percentile_ranking_std,
            ROW_NUMBER() OVER (ORDER BY percentile_ranking_std DESC) AS percentile_rank
        FROM
            interest_percentile_ranking
    )
    SELECT
        i.interest_name,
        p.percentile_ranking_std
    FROM
        percentile_ranking_rank AS p
        JOIN fresh_segments.interest_map AS i ON p.interest_id::INTEGER = i.id
    WHERE
        percentile_rank <= 5;
    ```

    Output:

    | "interest_name"                        | "percentile_ranking_std" |
    |----------------------------------------|--------------------------|
    | Techies                                | 30.18                    |
    | Entertainment Industry Decision Makers | 28.97                    |
    | Oregon Trip Planners                   | 28.32                    |
    | Personalized Gift Shoppers             | 26.24                    |
    | Tampa and St Petersburg Trip Planners  | 25.61                    |

    <br>

4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?

    - The 5 interests are having lower `percentile_ranking` over time. For example, `Techies` that have **86.69** `percentile_ranking` on **2018-07-01**, on **2019-08-01** having only **7.92**. This means, its composition or customer interaction for this interest is getting lower over time.

    Query:

    ```sql
    WITH interest_percentile_ranking AS (
        SELECT
            interest_id,
            ROUND(STDDEV(percentile_ranking)::NUMERIC, 2) AS percentile_ranking_std
        FROM
            filtered_interest
        GROUP BY
            1
    ),
    percentile_ranking_rank AS (
        SELECT
            interest_id,
            percentile_ranking_std,
            ROW_NUMBER() OVER (ORDER BY percentile_ranking_std DESC) AS percentile_rank
        FROM
            interest_percentile_ranking
    ),
    interest_list AS (
        SELECT
            interest_id
        FROM
            percentile_ranking_rank
        WHERE
            percentile_rank <= 5
    ),
    interest_ranking AS (
        SELECT
            month_year,
            interest_id,
            percentile_ranking,
            ROW_NUMBER() OVER (PARTITION BY interest_id ORDER BY percentile_ranking DESC) AS top_rank,
        ROW_NUMBER() OVER (PARTITION BY interest_id ORDER BY percentile_ranking) AS bottom_rank
    FROM
        filtered_interest
        WHERE
            interest_id IN (
                SELECT
                    interest_id
                FROM
                    interest_list))
    SELECT
        i1.month_year,
        i2.interest_name,
        i1.percentile_ranking
    FROM
        interest_ranking AS i1
        JOIN fresh_segments.interest_map AS i2 ON i1.interest_id::INTEGER = i2.id
    WHERE
        top_rank = 1
        OR bottom_rank = 1
    ORDER BY
        2,
        1;
    ```

    Output:

    | "month_year" | "interest_name"                        | "percentile_ranking" |
    |--------------|----------------------------------------|----------------------|
    | 2018-07-01   | Entertainment Industry Decision Makers | 86.15                |
    | 2019-08-01   | Entertainment Industry Decision Makers | 11.23                |
    | 2018-11-01   | Oregon Trip Planners                   | 82.44                |
    | 2019-07-01   | Oregon Trip Planners                   | 2.2                  |
    | 2019-03-01   | Personalized Gift Shoppers             | 73.15                |
    | 2019-06-01   | Personalized Gift Shoppers             | 5.7                  |
    | 2018-07-01   | Tampa and St Petersburg Trip Planners  | 75.03                |
    | 2019-03-01   | Tampa and St Petersburg Trip Planners  | 4.84                 |
    | 2018-07-01   | Techies                                | 86.69                |
    | 2019-08-01   | Techies                                | 7.92                 |

    <br>

5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

    - Based on the top interests with the highest composition value, the majority of customers possibly are **adults** with an interest in traveling. The contents/interests that have higher interaction are the indicator for that, for example, *Work Comes First Travelers*.
    - Contents that are related to traveling would be the best things to show to these customers. It's better to avoid showing content that is related to sports and games because they attract less interaction from our customers.

---
