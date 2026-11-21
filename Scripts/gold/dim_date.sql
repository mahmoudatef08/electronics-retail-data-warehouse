DROP VIEW IF EXISTS gold.dim_date CASCADE ;

CREATE VIEW gold.dim_date AS
SELECT
	TO_CHAR(g.d, 'YYYYMMDD') :: INTEGER            AS date_key ,       -- e.g. 20160101
	g.d :: DATE                                    AS full_date ,
	EXTRACT(YEAR    FROM g.d) :: INTEGER           AS year ,
	EXTRACT(QUARTER FROM g.d) :: INTEGER           AS quarter ,
	EXTRACT(MONTH   FROM g.d) :: INTEGER           AS month ,
	TO_CHAR(g.d, 'FMMonth')                        AS month_name ,
	EXTRACT(DAY     FROM g.d) :: INTEGER           AS day ,
	EXTRACT(ISODOW  FROM g.d) :: INTEGER           AS day_of_week ,    -- 1 = Monday
	TO_CHAR(g.d, 'FMDay')                          AS day_name ,
	( EXTRACT(ISODOW FROM g.d) IN (6, 7) )         AS is_weekend
FROM generate_series(
	( SELECT DATE_TRUNC('year', MIN(order_date) :: TIMESTAMP) FROM silver.sales ) ,
	( SELECT DATE_TRUNC('year', GREATEST(MAX(order_date), MAX(delivery_date)) :: TIMESTAMP)
	         + INTERVAL '1 year' - INTERVAL '1 day' FROM silver.sales ) ,
	INTERVAL '1 day'
) AS g(d) ;
