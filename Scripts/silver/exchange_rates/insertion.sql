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
