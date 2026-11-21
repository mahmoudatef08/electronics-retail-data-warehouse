DROP VIEW IF EXISTS gold.dim_stores CASCADE ;

CREATE VIEW gold.dim_stores AS
SELECT
	ROW_NUMBER() OVER ( ORDER BY s.store_key )     AS store_key ,      -- surrogate key
	s.store_key                                    AS store_id ,       -- original key
	CASE WHEN s.store_key = 0 THEN 'Online' ELSE 'Physical' END AS store_type ,
	s.country ,
	s.state ,
	s.square_meters ,
	s.open_date
FROM silver.stores s ;
