TRUNCATE TABLE silver.customers ; 

INSERT INTO silver.customers (

	customer_key ,
	gender ,
	customer_name ,
	city ,
	state_code ,
	state ,
	zip_code ,
	country ,
	continent ,
	birthday

)
SELECT 
	TRIM(customer_key) :: INTEGER AS customer_key ,
	INITCAP(TRIM(gender)) :: VARCHAR(10) AS gender ,
	TRIM(customer_name) :: VARCHAR(50) AS customer_name ,
	CASE
		WHEN TRIM(city) = UPPER(TRIM(city)) THEN INITCAP(TRIM(city)) 
		ELSE TRIM(city) 
	END :: VARCHAR(100) AS city ,
	NULLIF(TRIM(state_code), '') :: VARCHAR(50) AS state_code  ,
	TRIM(state) :: VARCHAR(50) AS state ,
	UPPER(TRIM(zip_code)) :: VARCHAR(20) AS zip_code ,
	INITCAP(TRIM(country)) :: VARCHAR(50) AS country ,
	INITCAP(TRIM(continent)) :: VARCHAR(50) AS continent ,
	TO_DATE(birthday, 'MM/DD/YYYY') AS birthday
FROM (
	SELECT 
		* ,
		ROW_NUMBER() OVER( PARTITION BY customer_key :: INTEGER ORDER BY customer_key :: INTEGER ASC ) AS rn 
	FROM bronze.customers 
	WHERE customer_key :: INTEGER IS NOT NULL 
) t WHERE rn = 1 ;
