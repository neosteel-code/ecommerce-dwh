DROP TABLE IF EXISTS stg.orders;

CREATE TABLE stg.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::timestamp      AS purchased_at,
    order_approved_at::timestamp             AS approved_at,
    order_delivered_carrier_date::timestamp  AS shipped_at,
    order_delivered_customer_date::timestamp AS delivered_at,
    order_estimated_delivery_date::timestamp AS estimated_at,
    CASE
        WHEN order_status = 'delivered'
         AND order_delivered_customer_date IS NULL
            THEN 'missing_delivery_date'
        WHEN order_approved_at::timestamp < order_purchase_timestamp::timestamp
          OR order_delivered_carrier_date::timestamp < order_approved_at::timestamp
          OR order_delivered_customer_date::timestamp < order_delivered_carrier_date::timestamp
            THEN 'wrong_sequence'
        ELSE 'ok'
    END AS date_quality_flag
FROM raw.orders;