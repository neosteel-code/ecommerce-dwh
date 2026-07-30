DROP TABLE IF EXISTS mart.customer_rfm;

CREATE TABLE mart.customer_rfm AS
SELECT
    c.customer_key,
    c.customer_unique_id,
    c.state,
    c.orders_count                                      AS frequency,
    (SELECT max(date_key) FROM core.fact_order_items) - c.last_order_at::date AS recency_days,
    sum(f.price) FILTER (WHERE f.order_status = 'delivered') AS monetary
FROM core.dim_customer c
JOIN core.fact_order_items f ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.customer_unique_id, c.state, c.orders_count, c.last_order_at;