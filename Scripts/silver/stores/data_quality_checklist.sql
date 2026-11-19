-- data quality checklist for stores table 

-- 1. show the whole table 

SELECT * FROM bronze.stores ;

-- 2. check for duplicate & invalid store_key 

SELECT 
	store_key :: INTEGER
FROM (
SELECT 
	store_key :: INTEGER ,
	COUNT(*) AS tot 
FROM bronze.stores 
GROUP BY store_key :: INTEGER 
HAVING COUNT(*) > 1
ORDER BY store_key :: INTEGER ASC 
) t WHERE store_key :: INTEGER IS NOT NULL ;

-- 3. Data Standerdization And Consistency

SELECT DISTINCT 
	country :: VARCHAR(50) 
FROM bronze.stores ;

SELECT DISTINCT 
	state :: VARCHAR(100) 
FROM bronze.stores ;

-- 4. check for unwanted spaces 

SELECT
	 country :: VARCHAR(50)
FROM bronze.stores 
WHERE country :: VARCHAR(50) != TRIM(country :: VARCHAR(50)) ;

SELECT
	 state :: VARCHAR(100)
FROM bronze.stores 
WHERE state :: VARCHAR(100) != TRIM(state :: VARCHAR(100)) ;

-- 5. check for invalid date 

SELECT
	open_date :: DATE  
FROM bronze.stores
WHERE TO_DATE(open_date, 'MM/DD/YYYY') > CURRENT_DATE
   OR EXTRACT( YEAR FROM TO_DATE(open_date, 'MM/DD/YYYY') ) < 1900 ;
