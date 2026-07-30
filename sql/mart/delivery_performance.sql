DROP TABLE IF EXISTS mart.delivery_performance;

CREATE TABLE mart.delivery_performance AS
SELECT
    d.year_month,
    count(DISTINCT o.order_id)                                          AS orders,
    round(avg(o.delivered_at::date - o.purchased_at::date), 1)          AS avg_delivery_days,
    count(DISTINCT o.order_id) FILTER (
        WHERE o.delivered_at > o.estimated_at
    )                                                                    AS late_orders,
    round(
        100.0 * count(DISTINCT o.order_id) FILTER (WHERE o.delivered_at > o.estimated_at)
        / count(DISTINCT o.order_id), 2
    )                                                                    AS late_pct
FROM stg.orders o
JOIN core.dim_date d ON d.date_key = o.purchased_at::date
WHERE o.order_status = 'delivered'
  AND o.date_quality_flag = 'ok'
GROUP BY d.year_month
ORDER BY d.year_month;