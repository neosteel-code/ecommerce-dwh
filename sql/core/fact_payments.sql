-- Fact: платежи
-- ЗЕРНО: одна строка = один платёж по заказу
-- Ключ: (order_id, payment_no)
-- Меры: payment_value
--
-- ВНИМАНИЕ: зерно ОТЛИЧАЕТСЯ от fact_order_items.
-- 103 886 платежей на 99 440 заказов - один заказ может оплачиваться
-- несколькими платежами. Соединять две таблицы фактов напрямую нельзя:
-- суммы задвоятся. Сводить только через общие измерения.
--
-- ТЕХДОЛГ: тянем напрямую из raw, минуя stg. Нужно завести stg.order_payments.
-- Источник: raw.order_payments + stg.orders

DROP TABLE IF EXISTS core.fact_payments;

CREATE TABLE core.fact_payments AS
SELECT
    p.order_id,
    p.payment_sequential::int      AS payment_no,
    d.date_key,
    c.customer_key,
    p.payment_type,
    p.payment_installments::int    AS installments,
    p.payment_value::numeric(12,2) AS payment_value,
    o.order_status
FROM raw.order_payments p
JOIN stg.orders     o  ON o.order_id = p.order_id
JOIN stg.customers  sc ON sc.customer_id = o.customer_id
LEFT JOIN core.dim_date     d ON d.date_key = o.purchased_at::date
LEFT JOIN core.dim_customer c ON c.customer_unique_id = sc.customer_unique_id;