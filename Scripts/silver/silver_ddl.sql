DROP TABLE IF EXISTS silver.customers ;

CREATE TABLE silver.customers (

	customer_key		INTEGER ,
	gender				VARCHAR(10) ,
	customer_name		VARCHAR(50) ,
	city				VARCHAR(100) ,
	state_code			VARCHAR(50) ,
	state				VARCHAR(50) ,
	zip_code			VARCHAR(20) ,
	country 			VARCHAR(50) ,
	continent			VARCHAR(50) ,
	birthday			DATE ,
	dwh_create_date		TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	
) ;

DROP TABLE IF EXISTS silver.exchange_rates ;

CREATE TABLE silver.exchange_rates (

	exchange_date		DATE ,
	currency		    VARCHAR(10) ,
	exchange			DECIMAL(10,4) ,
	dwh_create_date		TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ;

DROP TABLE IF EXISTS silver.products ;

CREATE TABLE silver.products (

	product_key		    INTEGER ,
	product_name		VARCHAR(100) ,
	brand				VARCHAR(50) , 
	color				VARCHAR(50) ,
	unit_cost_usd 		DECIMAL(10,2) ,
	unit_price_usd		DECIMAL(10,2) ,
	subcategory_key		INTEGER ,
	subcategory 		VARCHAR(50) ,
	category_key		INTEGER , 
	category			VARCHAR(50) ,
	dwh_create_date		TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ;

DROP TABLE IF EXISTS silver.sales ;

CREATE TABLE silver.sales (

	order_number		INTEGER ,
	line_item			INTEGER ,
	order_date			DATE , 
	delivery_date		DATE ,
	customer_key 		INTEGER ,
	store_key			INTEGER ,
	product_key			INTEGER ,
	quantity 			INTEGER ,
	currency_code		VARCHAR(10) ,
	dwh_create_date		TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ;

DROP TABLE IF EXISTS silver.stores ;

CREATE TABLE silver.stores (

	store_key		    INTEGER ,
	country				VARCHAR(50) ,
	state				VARCHAR(100) , 
	square_meters		INTEGER ,
	open_date	 		DATE ,
	dwh_create_date		TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ;
