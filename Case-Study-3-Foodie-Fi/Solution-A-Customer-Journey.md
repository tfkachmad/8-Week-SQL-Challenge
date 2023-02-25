# :avocado: Case Study 3 - Foodie-Fi: Solution A. Customer Journey

![badge](https://img.shields.io/badge/PostgreSQL-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

1. Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
    - The `subscription` table example:

        | customer_id | plan_id | start_date |
        | ----------- | ------- | ---------- |
        | 1           | 0       | 2020-08-01 |
        | 1           | 1       | 2020-08-08 |
        | 2           | 0       | 2020-09-20 |
        | 2           | 3       | 2020-09-27 |
        | 11          | 0       | 2020-11-19 |
        | 11          | 4       | 2020-11-26 |
        | 13          | 0       | 2020-12-15 |
        | 13          | 1       | 2020-12-22 |
        | 13          | 2       | 2021-03-29 |
        | 15          | 0       | 2020-03-17 |
        | 15          | 2       | 2020-03-24 |
        | 15          | 4       | 2020-04-29 |
        | 16          | 0       | 2020-05-31 |
        | 16          | 1       | 2020-06-07 |
        | 16          | 3       | 2020-10-21 |
        | 18          | 0       | 2020-07-06 |
        | 18          | 2       | 2020-07-13 |
        | 19          | 0       | 2020-06-22 |
        | 19          | 2       | 2020-06-29 |
        | 19          | 3       | 2020-08-29 |

    > All the customer started their journey using Foodie-Fi with the Trial plan. Some customers choose one of the three available plans, plan with plan_id with either 1 (basic monthly), 2 (pro monthly), or 3 (pro annual) after their trial plan ends. There are also customers that churned/canceled their subscriptions either after their trial plan ended or after a certain plan.
