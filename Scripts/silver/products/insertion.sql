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
