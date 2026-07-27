DROP TABLE IF EXISTS stg.order_items;

CREATE TABLE stg.order_items AS
SELECT
    order_id,
    order_item_id::int                AS item_no,
    product_id,
    seller_id,
    shipping_limit_date::timestamp    AS shipping_limit_at,
    price::numeric(12,2)              AS price,
    freight_value::numeric(12,2)      AS freight,
    (price::numeric + freight_value::numeric)::numeric(12,2) AS item_total
FROM raw.order_items;