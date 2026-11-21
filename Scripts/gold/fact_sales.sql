DROP VIEW IF EXISTS gold.fact_sales ;

CREATE VIEW gold.fact_sales AS
SELECT
	s.order_number ,
	s.line_item ,
	TO_CHAR(s.order_date,    'YYYYMMDD') :: INTEGER AS order_date_key ,
	TO_CHAR(s.delivery_date, 'YYYYMMDD') :: INTEGER AS delivery_date_key ,
	c.customer_key ,
	p.product_key ,
	st.store_key ,
	s.currency_code ,
	s.quantity ,
	p.unit_price_usd ,
	p.unit_cost_usd ,
	s.quantity * p.unit_price_usd                             AS sales_amount_usd ,
	s.quantity * p.unit_cost_usd                              AS cost_amount_usd ,
	s.quantity * ( p.unit_price_usd - p.unit_cost_usd )       AS profit_usd ,
	e.exchange                                                AS exchange_rate ,
	ROUND( s.quantity * p.unit_price_usd * e.exchange, 2 )    AS sales_amount_local ,
	s.delivery_date - s.order_date                            AS delivery_days
FROM silver.sales s
LEFT JOIN gold.dim_customers c  ON s.customer_key = c.customer_id
LEFT JOIN gold.dim_products  p  ON s.product_key  = p.product_id
LEFT JOIN gold.dim_stores    st ON s.store_key    = st.store_id
LEFT JOIN silver.exchange_rates e
       ON s.order_date    = e.exchange_date
      AND s.currency_code = e.currency ;
