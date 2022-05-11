--USE EightWeekSQLChallenge;
--CREATE SCHEMA data_mart;

DROP TABLE IF EXISTS data_mart.weekly_sales;
CREATE TABLE data_mart.weekly_sales (
  "week_date" VARCHAR(7),
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(4),
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER
);

BULK INSERT data_mart.weekly_sales
FROM 'C:\Users\Taufik\Documents\Data-Mart.csv'
WITH (FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR='\n');