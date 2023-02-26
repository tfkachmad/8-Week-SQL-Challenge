# :classical_building: Case Study 4 - Data Bank: Solution A. Customer Node Exploration

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. How many unique nodes are there on the Data Bank system

    Query:

    ```sql
    SELECT
        COUNT(DISTINCT node_id) AS unique_nodes
    FROM
        data_bank.customer_nodes;
    ```

    Output:

    | "unique_nodes" |
    |----------------|
    | 5              |

    <br>

2. What is the number of nodes per region?

    Query:

    ```sql
    SELECT
        r.region_name,
        COUNT(*) AS nodes_total
    FROM
        data_bank.customer_nodes AS c
        JOIN data_bank.regions AS r ON c.region_id = r.region_id
    GROUP BY
        c.region_id,
        r.region_name
    ORDER BY
        c.region_id;
    ```

    Output:

    | "region_name" | "nodes_total" |
    |---------------|---------------|
    | Australia     | 770           |
    | America       | 735           |
    | Africa        | 714           |
    | Asia          | 665           |
    | Europe        | 616           |

    <br>

3. How many customers are allocated to each region?

    Query:

    ```sql
    SELECT
        r.region_name,
        COUNT(DISTINCT customer_id) AS customer_total
    FROM
        data_bank.customer_nodes AS c
        JOIN data_bank.regions AS r ON c.region_id = r.region_id
    GROUP BY
        c.region_id,
        r.region_name
    ORDER BY
        c.region_id;
    ```

    Output:

    | "region_name" | "customer_total" |
    |---------------|------------------|
    | Australia     | 110              |
    | America       | 105              |
    | Africa        | 102              |
    | Asia          | 95               |
    | Europe        | 88               |

    <br>

4. How many days on average are customers reallocated to a different node?

    Query:

    ```sql
    WITH customer_next_nodes AS (
        SELECT
            customer_id,
            node_id,
            start_date,
            LEAD(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node,
            LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node_start_date
        FROM
            data_bank.customer_nodes
    )
    SELECT
        ROUND(AVG(next_node_start_date - start_date)) AS reallocation_days_average
    FROM
        customer_next_nodes
    WHERE
        node_id != next_node;
    ```

    Output:

    | "reallocation_days_average" |
    |-----------------------------|
    | 16                          |

    <br>

5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

    Query:

    ```sql
    WITH customer_next_nodes AS (
        SELECT
            c.start_date,
            r.region_id,
            r.region_name,
            LEAD(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node,
            LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_node_start_date
        FROM
            data_bank.customer_nodes AS c
            JOIN data_bank.regions AS r ON c.region_id = r.region_id
    ),
    reallocation_days AS (
        SELECT
            region_id,
            region_name,
            (next_node_start_date - start_date) AS days
        FROM
            customer_next_nodes
    )
    SELECT
        region_name,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY days) AS reallocation_median,
        PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY days) AS reallocation_percentile_80,
        PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY days) AS reallocation_percentile_95
    FROM
        reallocation_days
    GROUP BY
        region_id,
        region_name
    ORDER BY
        region_id;
    ```

    Output:

    | "region_name" | "reallocation_median" | "reallocation_percentile_80" | "reallocation_percentile_95" |
    |---------------|-----------------------|------------------------------|------------------------------|
    | Australia     | 16                    | 24                           | 29                           |
    | America       | 16                    | 24                           | 29                           |
    | Africa        | 16                    | 25                           | 29                           |
    | Asia          | 16                    | 24                           | 29                           |
    | Europe        | 16                    | 25                           | 29                           |

---
