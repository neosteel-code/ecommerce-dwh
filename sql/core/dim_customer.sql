-- Dimension: клиенты
-- Одна строка = один реальный человек (customer_unique_id)
-- ВАЖНО: customer_id из источника - это клиент в рамках ОДНОГО заказа,
--        по нему retention считать нельзя (даст 0%)
-- 122 человека имеют несколько городов -> берём последний по дате заказа
-- Источник: stg.customers + stg.orders

DROP TABLE IF EXISTS core.dim_customer;

CREATE TABLE core.dim_customer AS
SELECT
    row_number() OVER (ORDER BY customer_unique_id) AS customer_key,
    customer_unique_id,
    city,
    state,
    zip_prefix,
    first_order_at,
    last_order_at,
    orders_count
FROM (
    SELECT
        c.customer_unique_id,
        c.city,
        c.state,
        c.zip_prefix,
        min(o.purchased_at) OVER (PARTITION BY c.customer_unique_id) AS first_order_at,
        max(o.purchased_at) OVER (PARTITION BY c.customer_unique_id) AS last_order_at,
        count(*)            OVER (PARTITION BY c.customer_unique_id) AS orders_count,
        row_number()        OVER (PARTITION BY c.customer_unique_id
                                  ORDER BY o.purchased_at DESC)      AS rn
    FROM stg.customers c
    JOIN stg.orders o ON o.customer_id = c.customer_id
) sub
WHERE rn = 1;