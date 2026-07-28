-- Fact: позиции заказов
-- ЗЕРНО: одна строка = одна позиция одного заказа
-- Ключ: (order_id, item_no)
-- Меры: price, freight, item_total
-- Источник: stg.order_items + stg.orders + все измерения
--
-- LEFT JOIN к измерениям намеренно: если ключ не найдётся, строка останется
-- с NULL, и потерю будет видно. INNER JOIN потерял бы деньги молча.

DROP TABLE IF EXISTS core.fact_order_items;

CREATE TABLE core.fact_order_items AS
SELECT
    i.order_id,
    i.item_no,
    d.date_key,
    c.customer_key,
    p.product_key,
    s.seller_key,
    o.order_status,
    i.price,
    i.freight,
    i.item_total,
    o.purchased_at,
    o.delivered_at,
    o.estimated_at,
    o.date_quality_flag
FROM stg.order_items i
JOIN stg.orders    o ON o.order_id = i.order_id
JOIN stg.customers sc ON sc.customer_id = o.customer_id
LEFT JOIN core.dim_date     d ON d.date_key = o.purchased_at::date
LEFT JOIN core.dim_customer c ON c.customer_unique_id = sc.customer_unique_id
LEFT JOIN core.dim_product  p ON p.product_id = i.product_id
LEFT JOIN core.dim_seller   s ON s.seller_id = i.seller_id;