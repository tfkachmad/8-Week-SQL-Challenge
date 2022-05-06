USE EightWeekSQLChallenge;
--
/*
	========	A. Customer Journey		========
*/
--
--	Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
--	Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
SELECT *
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans AS plans
	ON sub.plan_id = plans.plan_id
WHERE sub.customer_id IN (
		1
		,2
		,11
		,13
		,15
		,16
		,18
		,19
		)
	--
/* 
	Each of the customers form the sample above started their journey with the trial plans and
	most of them continued their subscription with one of the available subscription option.
*/
