-- =====================================================================
-- CHECKS  (run them one by one)
-- =====================================================================

-- 1. Row count: expected 2517
SELECT count(*) AS total_rows FROM gold.dim_products ;

-- 2. Surrogate key is unique and continuous: expected 2517 | 2517 | 1 | 2517
SELECT
	count(DISTINCT product_key) AS distinct_keys ,
	count(DISTINCT product_id)  AS distinct_ids ,
	MIN(product_key)            AS min_key ,
	MAX(product_key)            AS max_key
FROM gold.dim_products ;

-- 3. NULL keys / prices: expected 0 rows
SELECT * FROM gold.dim_products
WHERE product_key IS NULL OR product_id IS NULL
   OR unit_cost_usd IS NULL OR unit_price_usd IS NULL ;

-- 4. Empty product names: expected 0 rows
SELECT * FROM gold.dim_products WHERE TRIM(product_name) = '' ;

-- 5. Price range: expected cost 0.48 .. 1060.22 | price 0.95 .. 3199.99
SELECT
	MIN(unit_cost_usd)  AS min_cost ,  MAX(unit_cost_usd)  AS max_cost ,
	MIN(unit_price_usd) AS min_price , MAX(unit_price_usd) AS max_price
FROM gold.dim_products ;

-- 6. Cost must not exceed price: expected 0 rows
SELECT * FROM gold.dim_products WHERE unit_cost_usd > unit_price_usd ;

-- 7. Quick look
SELECT * FROM gold.dim_products ORDER BY product_key LIMIT 10 ;
