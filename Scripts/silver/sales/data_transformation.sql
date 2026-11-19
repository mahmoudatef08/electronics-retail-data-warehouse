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
