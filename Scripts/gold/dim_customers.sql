DROP VIEW IF EXISTS gold.dim_customers CASCADE ;

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER ( ORDER BY c.customer_key )  AS customer_key ,   -- surrogate key
	c.customer_key                                 AS customer_id ,    -- original key
	c.customer_name ,
	c.gender ,
	c.birthday ,
	c.city ,
	c.state_code ,
	c.state ,
	c.zip_code ,
	c.country ,
	c.continent
FROM silver.customers c ;
