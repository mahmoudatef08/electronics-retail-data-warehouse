-- data quality checklist for products table 

-- 1. show the whole table 

SELECT * FROM bronze.products ;

-- 2. check for duplicated & invalid product_key 

SELECT 
	product_key :: INTEGER 
FROM (
	SELECT 
		product_key :: INTEGER ,
		ROW_NUMBER() OVER( PARTITION BY product_key :: INTEGER ORDER BY product_key :: INTEGER ASC ) AS rn 
	FROM bronze.products 
	WHERE product_key :: INTEGER IS NOT NULL 
) t WHERE rn > 1 ;

-- 3. The brand and color exists in product_name ( remove them with (REGEXP_REPLACE) ) 

-- 4. Data Standerdization And Consistency 

SELECT DISTINCT
	brand :: VARCHAR(50) 
FROM bronze.products ;

SELECT DISTINCT
	color :: VARCHAR(50) 
FROM bronze.products ;

SELECT DISTINCT
	category :: VARCHAR(50) 
FROM bronze.products ;

SELECT DISTINCT
	subcategory :: VARCHAR(50) 
FROM bronze.products ;

-- 5. check for unwanted spaces 

SELECT 
	brand :: VARCHAR(50) 
FROM bronze.products 
WHERE brand :: VARCHAR(50) != TRIM(brand :: VARCHAR(50)) ;

SELECT 
	 color :: VARCHAR(50)
FROM bronze.products 
WHERE color :: VARCHAR(50) != TRIM(color :: VARCHAR(50)) ;

SELECT 
	 subcategory :: VARCHAR(50)
FROM bronze.products 
WHERE subcategory :: VARCHAR(50) != TRIM(subcategory :: VARCHAR(50)) ;

SELECT 
	 category :: VARCHAR(50)
FROM bronze.products 
WHERE category :: VARCHAR(50) != TRIM(category :: VARCHAR(50)) ;

-- check for invalid unit_cost_usd & unit_price_usd

SELECT
	REPLACE(REPLACE(TRIM(unit_cost_usd), '$', ''), ',', '') :: DECIMAL(10,2) AS unit_cost_usd
FROM bronze.products 
WHERE REPLACE(REPLACE(TRIM(unit_cost_usd), '$', ''), ',', '') :: DECIMAL(10,2) <= 0 
   OR REPLACE(REPLACE(TRIM(unit_cost_usd), '$', ''), ',', '') :: DECIMAL(10,2) IS NULL ;

SELECT
	REPLACE(REPLACE(TRIM(unit_price_usd), '$', ''), ',', '') :: DECIMAL(10,2) AS unit_price_usd
FROM bronze.products 
WHERE REPLACE(REPLACE(TRIM(unit_price_usd), '$', ''), ',', '') :: DECIMAL(10,2) <= 0 
   OR REPLACE(REPLACE(TRIM(unit_price_usd), '$', ''), ',', '') :: DECIMAL(10,2) IS NULL ;
