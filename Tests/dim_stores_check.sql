-- =====================================================================
-- CHECKS  (run them one by one)
-- =====================================================================

-- 1. Row count: expected 67
SELECT count(*) AS total_rows FROM gold.dim_stores ;

-- 2. Surrogate key is unique and continuous: expected 67 | 67 | 1 | 67
SELECT
	count(DISTINCT store_key) AS distinct_keys ,
	count(DISTINCT store_id)  AS distinct_ids ,
	MIN(store_key)            AS min_key ,
	MAX(store_key)            AS max_key
FROM gold.dim_stores ;

-- 3. Store types: expected Online = 1, Physical = 66
SELECT store_type, count(*) FROM gold.dim_stores GROUP BY store_type ;

-- 4. The Online store: expected 1 row (store_id 0, country/state 'Online', square_meters NULL)
SELECT * FROM gold.dim_stores WHERE store_id = 0 ;

-- 5. square_meters NULL only for the Online store: expected 1
SELECT count(*) AS null_square_meters FROM gold.dim_stores WHERE square_meters IS NULL ;

-- 6. Quick look
SELECT * FROM gold.dim_stores ORDER BY store_key LIMIT 10 ;
