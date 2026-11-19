CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql AS 
$$ 
BEGIN 

	RAISE NOTICE 'Start Task' ; 

	RAISE NOTICE 'Start Loading customers' ; 

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

	RAISE NOTICE 'Finish Loading customers' ; 

	RAISE NOTICE 'Start Loading exchange_rates' ;

	TRUNCATE TABLE silver.exchange_rates ; 

	INSERT INTO silver.exchange_rates ( 
	
		exchange_date ,
		currency ,
		exchange			
	
	)
	SELECT
		TO_DATE(TRIM(exchange_date), 'MM/DD/YYYY') AS exchange_date , 
		currency :: VARCHAR(10) AS currency , 
		exchange :: DECIMAL(10,4) AS exchange 
	FROM bronze.exchange_rates ;

	RAISE NOTICE 'Finish Loading exchange_rates' ;

	RAISE NOTICE 'Start Loading products' ;

	TRUNCATE TABLE silver.products ; 

	INSERT INTO silver.products (
	
		product_key ,
		product_name ,
		brand , 
		color ,
		unit_cost_usd ,
		unit_price_usd ,
		subcategory_key ,
		subcategory ,
		category_key , 
		category
	
	)
	SELECT 
		TRIM(product_key) :: INTEGER AS product_key ,
		TRIM(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(TRIM(product_name), '^(' || TRIM(brand) || '|NT|SV|MGS|WWI)\s+', ''),
					'\s+' || TRIM(color) || '$', '', 'i'
				),
				'\s+[A-Z]{1,2}\d{1,5}W?$', ''
				)
		) :: VARCHAR(100) AS product_name ,
		INITCAP(TRIM(brand :: VARCHAR(50))) AS brand ,
		INITCAP(TRIM(color :: VARCHAR(50))) AS color ,
		REPLACE(REPLACE(TRIM(unit_cost_usd), '$', ''), ',', '') :: DECIMAL(10,2) AS unit_cost_usd ,
		REPLACE(REPLACE(TRIM(unit_price_usd), '$', ''), ',', '') :: DECIMAL(10,2) AS unit_price_usd ,
		TRIM(subcategory_key) :: INTEGER AS subcategory_key ,
		TRIM(subcategory):: VARCHAR(50) AS subcategory ,
		TRIM(category_key) :: INTEGER AS category_key ,
		TRIM(category):: VARCHAR(50) AS category
	FROM (
		SELECT 
			* ,
			ROW_NUMBER() OVER( PARTITION BY product_key :: INTEGER ORDER BY product_key :: INTEGER ASC ) AS rn 
		FROM bronze.products 
		WHERE product_key :: INTEGER IS NOT NULL 
	) t WHERE rn = 1 ;

	RAISE NOTICE 'Finish Loading products' ;

	RAISE NOTICE 'Start Loading sales' ;

	TRUNCATE TABLE silver.sales ; 

	INSERT INTO silver.sales (
	
		order_number ,
		line_item ,
		order_date , 
		delivery_date ,
		customer_key ,
		store_key ,
		product_key ,
		quantity ,
		currency_code
	
	)
	SELECT 
		TRIM(order_number) :: INTEGER AS order_number ,
		TRIM(line_item) :: INTEGER AS line_item , 
		TO_DATE(TRIM(order_date), 'MM/DD/YYYY') AS order_date ,
		TO_DATE(NULLIF(TRIM(delivery_date), ''), 'MM/DD/YYYY') AS delivery_date ,
		TRIM(customer_key) :: INTEGER AS customer_key ,
		TRIM(store_key) :: INTEGER AS store_key ,
		TRIM(product_key) :: INTEGER AS product_key ,
		TRIM(quantity) :: INTEGER AS quantity ,
		UPPER(TRIM(currency_code)) :: VARCHAR(10) AS currency_code
	FROM bronze.sales ;

	RAISE NOTICE 'Finish Loading sales' ;

	RAISE NOTICE 'Start Loading stores' ;

	TRUNCATE TABLE silver.stores ; 

	INSERT INTO silver.stores (
	
		store_key ,
		country ,
		state , 
		square_meters ,
		open_date
	
	)
	SELECT 
		TRIM(store_key) :: INTEGER AS store_key ,
		INITCAP(TRIM(country)) :: VARCHAR(50) AS country ,
		INITCAP(TRIM(state)) :: VARCHAR(100) AS state ,
		TRIM(square_meters) :: INTEGER AS square_meters ,
		TO_DATE(open_date, 'MM/DD/YYYY')
	FROM bronze.stores 
	WHERE store_key :: INTEGER != 0 ;

	RAISE NOTICE 'Finish Loading stores' ;

	RAISE NOTICE 'Finish Task' ;

END ; 
$$ ;
