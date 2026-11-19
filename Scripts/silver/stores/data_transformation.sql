SELECT 
	TRIM(store_key) :: INTEGER AS store_key ,
	INITCAP(TRIM(country)) :: VARCHAR(50) AS country ,
	INITCAP(TRIM(state)) :: VARCHAR(100) AS state ,
	TRIM(square_meters) :: INTEGER AS square_meters ,
	TO_DATE(open_date, 'MM/DD/YYYY')
FROM bronze.stores 
WHERE store_key :: INTEGER != 0 ;
