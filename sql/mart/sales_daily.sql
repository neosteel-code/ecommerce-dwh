DROP TABLE IF EXISTS mart.sales_daily;

CREATE TABLE mart.sales_daily AS
SELECT
    d.date_key,
    d.year,
    d.month,
    d.year_month,
    d.is_weekend,
    p.category,
    count(DISTINCT f.order_id) FILTER (WHERE f.order_status = 'delivered') AS orders_delivered,
    sum(f.price)   FILTER (WHERE f.order_status = 'delivered') AS revenue_delivered,
    sum(f.freight) FILTER (WHERE f.order_status = 'delivered') AS freight_delivered,
    sum(f.price)   FILTER (WHERE f.order_status NOT IN ('canceled','unavailable')) AS revenue_pipeline
FROM core.fact_order_items f
JOIN core.dim_date    d ON d.date_key = f.date_key
JOIN core.dim_product p ON p.product_key = f.product_key
GROUP BY d.date_key, d.year, d.month, d.year_month, d.is_weekend, p.category;