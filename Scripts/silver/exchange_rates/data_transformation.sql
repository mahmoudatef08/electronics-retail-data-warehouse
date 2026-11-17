SELECT
	TO_DATE(TRIM(exchange_date), 'MM/DD/YYYY') AS exchange_date , 
	currency :: VARCHAR(10) AS currency , 
	exchange :: DECIMAL(10,4) AS exchange 
FROM bronze.exchange_rates ;
