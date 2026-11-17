-- data quality checklist for customers table --

-- 1. show the whole table 

SELECT * FROM bronze.customers ;

-- 2. check for duplicted & invalid customer_key 

SELECT 
	customer_key :: INTEGER 
FROM (
	SELECT 
		customer_key :: INTEGER ,
		ROW_NUMBER() OVER( PARTITION BY customer_key :: INTEGER ORDER BY customer_key :: INTEGER ASC ) AS rn 
	FROM bronze.customers 
	WHERE customer_key :: INTEGER IS NOT NULL 
) t WHERE rn > 1 ;

-- 2. Data Standerdization And Consistency 

SELECT DISTINCT 
	gender :: VARCHAR(10) 
FROM bronze.customers ; 

SELECT DISTINCT 
	state_code :: VARCHAR(50) 
FROM bronze.customers ; 

SELECT DISTINCT
	 zip_code :: VARCHAR(20)
FROM bronze.customers ; 

SELECT DISTINCT
	 country :: VARCHAR(50)
FROM bronze.customers ; 

SELECT DISTINCT
	 continent :: VARCHAR(50)
FROM bronze.customers ;

-- 3. check for unwanted spaces 

SELECT  
	gender :: VARCHAR(10) 
FROM bronze.customers
WHERE gender :: VARCHAR(10) != TRIM(gender :: VARCHAR(10)) ; 

SELECT  
	customer_name :: VARCHAR(50) 
FROM bronze.customers
WHERE customer_name :: VARCHAR(50) != TRIM(customer_name :: VARCHAR(50)) ; 

SELECT  
	city :: VARCHAR(100) 
FROM bronze.customers
WHERE city :: VARCHAR(100) != TRIM(city :: VARCHAR(100)) ; 

SELECT  
	 state_code :: VARCHAR(50)
FROM bronze.customers
WHERE state_code :: VARCHAR(50) != TRIM(state_code :: VARCHAR(50)) ; 

SELECT  
	 state :: VARCHAR(50)
FROM bronze.customers
WHERE state :: VARCHAR(50) != TRIM(state :: VARCHAR(50)) ; 

SELECT  
	 zip_code :: VARCHAR(20)
FROM bronze.customers
WHERE zip_code :: VARCHAR(20) != TRIM(zip_code :: VARCHAR(20)) ; 

SELECT
	 country :: VARCHAR(50)
FROM bronze.customers 
WHERE country :: VARCHAR(50) != TRIM(country :: VARCHAR(50)) ;

SELECT
	 continent :: VARCHAR(50)
FROM bronze.customers 
WHERE continent :: VARCHAR(50) != TRIM(continent :: VARCHAR(50)) ;

-- 4. check for invalid birthday 

SELECT 
	birthday :: DATE 
FROM bronze.customers 
WHERE birthday :: DATE > CURRENT_DATE 
   OR EXTRACT( YEAR FROM  birthday :: DATE ) < 1900 
