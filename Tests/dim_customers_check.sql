-- =====================================================================
-- CHECKS  (run them one by one)
-- =====================================================================

-- 1. Row count: expected 15266
SELECT count(*) AS total_rows FROM gold.dim_customers ;

-- 2. Surrogate key is unique and continuous: expected 15266 | 15266 | 1 | 15266
SELECT
	count(DISTINCT customer_key) AS distinct_keys ,
	count(DISTINCT customer_id)  AS distinct_ids ,
	MIN(customer_key)            AS min_key ,
	MAX(customer_key)            AS max_key
FROM gold.dim_customers ;

-- 3. Same row count as silver: expected 0 rows
SELECT
	(SELECT count(*) FROM silver.customers) AS silver_rows ,
	(SELECT count(*) FROM gold.dim_customers) AS gold_rows
WHERE (SELECT count(*) FROM silver.customers) <> (SELECT count(*) FROM gold.dim_customers) ;

-- 4. NULL keys: expected 0 rows
SELECT * FROM gold.dim_customers
WHERE customer_key IS NULL OR customer_id IS NULL ;

-- 5. Napoli customers keep state_code 'NA': expected 10
SELECT count(*) AS napoli_na
FROM gold.dim_customers
WHERE country = 'Italy' AND state_code = 'NA' ;

-- 6. Quick look
SELECT * FROM gold.dim_customers ORDER BY customer_key LIMIT 10 ;
