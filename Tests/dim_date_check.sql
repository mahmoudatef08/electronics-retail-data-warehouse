-- =====================================================================
-- CHECKS  (run them one by one)
-- =====================================================================

-- 1. Row count: expected 2192  (2016-01-01 .. 2021-12-31)
SELECT count(*) AS total_rows FROM gold.dim_date ;

-- 2. Range: expected 2016-01-01 | 2021-12-31
SELECT MIN(full_date) AS first_day, MAX(full_date) AS last_day FROM gold.dim_date ;

-- 3. date_key is unique: expected 2192 | 2192
SELECT count(*) AS rows_, count(DISTINCT date_key) AS distinct_keys FROM gold.dim_date ;

-- 4. No missing days (every day exists once): expected 0 rows
SELECT d :: DATE AS missing_day
FROM generate_series(
	( SELECT MIN(full_date) FROM gold.dim_date ) :: TIMESTAMP ,
	( SELECT MAX(full_date) FROM gold.dim_date ) :: TIMESTAMP ,
	INTERVAL '1 day'
) AS g(d)
WHERE d :: DATE NOT IN ( SELECT full_date FROM gold.dim_date ) ;

-- 5. Every order and delivery date is covered: expected 0 rows
SELECT DISTINCT s.order_date AS missing_date
FROM silver.sales s
WHERE s.order_date NOT IN ( SELECT full_date FROM gold.dim_date )
UNION
SELECT DISTINCT s.delivery_date
FROM silver.sales s
WHERE s.delivery_date IS NOT NULL
  AND s.delivery_date NOT IN ( SELECT full_date FROM gold.dim_date ) ;

-- 6. Quick look
SELECT * FROM gold.dim_date ORDER BY date_key LIMIT 10 ;
