--
-- Case study solutions for the #8WeeksSQLChallenge by Danny Ma
-- Week 3 - Foodie-Fi
-- Part A - Customer Journey
--
--	Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer�s onboarding journey.
--	Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
SELECT s.customer_id, s.start_date, p.plan_name, p.price
FROM foodie_fi.subscriptions AS s
	JOIN foodie_fi.plans AS p
	ON s.plan_id = p.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY s.customer_id, s.start_date;

/*
	All the customer started their journey using Foodie-Fi with the Trial plan. Some customers choose one of the three available plans, plan with plan_id with either 1 (basic monthly), 2 (pro monthly), or 3 (pro annual) after their trial plan ends. There are also customers that churned/canceled their subscriptions either after their trial plan ended or after a certain plan.
*/
