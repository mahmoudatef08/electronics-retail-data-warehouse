DROP VIEW IF EXISTS gold.dim_products CASCADE ;

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER ( ORDER BY p.product_key )   AS product_key ,    -- surrogate key
	p.product_key                                  AS product_id ,     -- original key
	p.product_name ,
	p.brand ,
	p.color ,
	p.category_key                                 AS category_id ,
	p.category ,
	p.subcategory_key                              AS subcategory_id ,
	p.subcategory ,
	p.unit_cost_usd ,
	p.unit_price_usd
FROM silver.products p ;
