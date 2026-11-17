CREATE OR REPLACE PROCEDURE bronze.load_bronze ()
LANGUAGE plpgsql AS
$$
BEGIN 

	RAISE NOTICE 'Start Task' ;
	
	RAISE NOTICE 'Start Importing Data From Customers Table' ;
	
	TRUNCATE TABLE bronze.customers ;
    COPY bronze.customers
    FROM '/run/media/mahmoud-atef/Data/Projects/electronics-retail-data-warehouse/Datasets/Customers.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');

	RAISE NOTICE 'Finish Importing Data From Customers Table' ;

	RAISE NOTICE 'Start Importing Data From exchange_rates Table' ;
	
	TRUNCATE TABLE bronze.exchange_rates ;
    COPY bronze.exchange_rates
    FROM '/run/media/mahmoud-atef/Data/Projects/electronics-retail-data-warehouse/Datasets/Exchange_Rates.csv' 
    DELIMITER ',' 
    CSV HEADER;

	RAISE NOTICE 'Finish Importing Data From exchange_rates Table' ;

	RAISE NOTICE 'Start Importing Data From products Table' ;
	
	TRUNCATE TABLE bronze.products ;
    COPY bronze.products
    FROM '/run/media/mahmoud-atef/Data/Projects/electronics-retail-data-warehouse/Datasets/Products.csv' 
    DELIMITER ',' 
    CSV HEADER;

	RAISE NOTICE 'Finish Importing Data From products Table' ;

	RAISE NOTICE 'Start Importing Data From sales Table' ;
	
	TRUNCATE TABLE bronze.sales ;
    COPY bronze.sales
    FROM '/run/media/mahmoud-atef/Data/Projects/electronics-retail-data-warehouse/Datasets/Sales.csv' 
    DELIMITER ',' 
    CSV HEADER;

	RAISE NOTICE 'Finish Importing Data From sales Table' ;

	RAISE NOTICE 'Start Importing Data From stores Table' ;
	
	TRUNCATE TABLE bronze.stores ;
    COPY bronze.stores
    FROM '/run/media/mahmoud-atef/Data/Projects/electronics-retail-data-warehouse/Datasets/Stores.csv' 
    DELIMITER ',' 
    CSV HEADER;

	RAISE NOTICE 'Finish Importing Data From stores Table' ;

	RAISE NOTICE 'End Task' ;
	
END ; 
$$ ;
