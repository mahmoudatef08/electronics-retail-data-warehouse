-- data quality checklist for exchange_rates table 

-- 1. show the whole table 

SELECT * FROM bronze.exchange_rates ; 

-- 2. check for invalid exchange_date

SELECT 
	exchange_date
FROM bronze.exchange_rates 
WHERE TO_DATE(exchange_date, 'MM/DD/YYYY') > CURRENT_DATE 
   OR EXTRACT( YEAR FROM TO_DATE(exchange_date, 'MM/DD/YYYY') ) < 1900 ;

-- 3. Data Standerdization And Consistency 

SELECT DISTINCT 
	currency :: VARCHAR(10) 
FROM bronze.exchange_rates ;

-- 4. check for unwanted spaces 

SELECT
	currency :: VARCHAR(10) 
FROM bronze.exchange_rates 
WHERE currency :: VARCHAR(10) != TRIM(currency :: VARCHAR(10)) ;

-- 5. Check for duplicated (exchange_date, currency)

SELECT
	exchange_date ,
	currency ,
	count(*) AS cnt
FROM bronze.exchange_rates
GROUP BY exchange_date, currency
HAVING count(*) > 1 ;


-- 6. Check for invalid exchange (NULL, empty, zero or negative)

SELECT
	exchange
FROM bronze.exchange_rates
WHERE exchange IS NULL
   OR TRIM(exchange) = ''
   OR TRIM(exchange) :: NUMERIC <= 0 ;
