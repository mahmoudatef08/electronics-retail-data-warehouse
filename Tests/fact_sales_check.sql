-- =====================================================================
-- CHECKS  (run them one by one)
-- =====================================================================

-- 1. Row count: expected 62884 (must equal silver.sales)
SELECT
	(SELECT count(*) FROM gold.fact_sales)   AS fact_rows ,
	(SELECT count(*) FROM silver.sales)      AS silver_rows ;

-- 2. Orders: expected 26326
SELECT count(DISTINCT order_number) AS orders FROM gold.fact_sales ;

-- 3. Grain is unique (order_number, line_item): expected 0 rows
SELECT order_number, line_item, count(*)
FROM gold.fact_sales
GROUP BY order_number, line_item
HAVING count(*) > 1 ;

-- 4. No lost joins: expected 0 in every column
SELECT
	count(*) FILTER (WHERE customer_key  IS NULL) AS null_customer ,
	count(*) FILTER (WHERE product_key   IS NULL) AS null_product ,
	count(*) FILTER (WHERE store_key     IS NULL) AS null_store ,
	count(*) FILTER (WHERE exchange_rate IS NULL) AS null_rate ,
	count(*) FILTER (WHERE order_date_key NOT IN (SELECT date_key FROM gold.dim_date)) AS bad_order_date ,
	count(*) FILTER (WHERE delivery_date_key IS NOT NULL
	                   AND delivery_date_key NOT IN (SELECT date_key FROM gold.dim_date)) AS bad_delivery_date
FROM gold.fact_sales ;

-- 5. Delivery: expected NULL rows 49719 | min 1 | max 17
SELECT
	count(*) FILTER (WHERE delivery_days IS NULL) AS null_delivery ,
	MIN(delivery_days) AS min_days ,
	MAX(delivery_days) AS max_days
FROM gold.fact_sales ;

-- 6. Totals: sales ~ 55,755,479.59 | cost ~ 23,092,791.21 | profit ~ 32,662,688.38
--            local ~ 55,349,464.05 (rounded per line, tiny differences are fine)
SELECT
	SUM(sales_amount_usd)   AS sales_usd ,
	SUM(cost_amount_usd)    AS cost_usd ,
	SUM(profit_usd)         AS profit_usd ,
	SUM(sales_amount_local) AS sales_local
FROM gold.fact_sales ;

-- 7. Online store: expected 13165 lines | sales ~ 11,404,324.63
SELECT count(*) AS online_lines , SUM(f.sales_amount_usd) AS online_sales_usd
FROM gold.fact_sales f
JOIN gold.dim_stores s ON f.store_key = s.store_key
WHERE s.store_type = 'Online' ;

-- 8. USD orders: local amount equals USD amount: expected 0 rows
SELECT * FROM gold.fact_sales
WHERE currency_code = 'USD' AND sales_amount_local <> sales_amount_usd ;

-- 9. Sales by year (USD, rounded): 2016 ~6.95M | 2017 ~7.42M | 2018 ~12.79M | 2019 ~18.26M | 2020 ~9.29M | 2021 ~1.04M
SELECT d.year, ROUND(SUM(f.sales_amount_usd)) AS sales_usd
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.order_date_key = d.date_key
GROUP BY d.year ORDER BY d.year ;
