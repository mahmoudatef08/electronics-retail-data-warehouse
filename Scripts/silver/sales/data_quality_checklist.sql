-- data quality checklist for sales table 

-- 1. show the whole table 

SELECT * FROM bronze.sales ; 

-- 2. check for duplicate & invalid order_number 

SELECT
	order_number , 
	line_item
FROM (
	SELECT
		order_number :: INTEGER AS order_number ,
		line_item :: INTEGER AS line_item ,
		ROW_NUMBER() OVER( PARTITION BY order_number :: INTEGER, line_item :: INTEGER
		                   ORDER BY order_number :: INTEGER ) AS rn
	FROM bronze.sales
	WHERE order_number :: INTEGER IS NOT NULL
) t WHERE rn > 1 ;

-- 3. Data Standerdization And Consistency

SELECT DISTINCT 
	currency_code :: VARCHAR(10) 
FROM bronze.sales ;

-- 4. check for unwanted spaces 

SELECT customer_key
FROM bronze.sales
WHERE customer_key != TRIM(customer_key) ;

SELECT product_key
FROM bronze.sales
WHERE product_key != TRIM(product_key) ;

SELECT store_key
FROM bronze.sales
WHERE store_key != TRIM(store_key) ;

-- 5. check for invalid date 

SELECT
	order_date :: DATE ,
	delivery_date :: DATE 
FROM bronze.sales
WHERE TO_DATE(order_date, 'MM/DD/YYYY') > CURRENT_DATE
   OR TO_DATE(delivery_date, 'MM/DD/YYYY') > CURRENT_DATE
   OR EXTRACT( YEAR FROM TO_DATE(order_date, 'MM/DD/YYYY') ) < 1900
   OR EXTRACT( YEAR FROM TO_DATE(delivery_date, 'MM/DD/YYYY') ) < 1900 ;

-- 6. check for exists data in anthor tables 

SELECT DISTINCT
	s.customer_key :: INTEGER AS customer_key
FROM bronze.sales s
WHERE NOT EXISTS (
	SELECT 1
	FROM bronze.customers c
	WHERE c.customer_key :: INTEGER = s.customer_key :: INTEGER
) ;

SELECT DISTINCT
	s.product_key :: INTEGER AS product_key
FROM bronze.sales s
WHERE NOT EXISTS (
	SELECT 1
	FROM bronze.products p
	WHERE p.product_key :: INTEGER = s.product_key :: INTEGER
) ;

SELECT DISTINCT
	s.store_key :: INTEGER AS store_key
FROM bronze.sales s
WHERE NOT EXISTS (
	SELECT 1
	FROM bronze.stores st
	WHERE st.store_key :: INTEGER = s.store_key :: INTEGER
) ;
