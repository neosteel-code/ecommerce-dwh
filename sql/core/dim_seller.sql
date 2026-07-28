-- Dimension: продавцы
-- Одна строка = один продавец
-- ТЕХДОЛГ: тянем напрямую из raw, минуя stg. Нужно завести stg.sellers.
-- Источник: raw.sellers

DROP TABLE IF EXISTS core.dim_seller;

CREATE TABLE core.dim_seller AS
SELECT
    row_number() OVER (ORDER BY seller_id) AS seller_key,
    seller_id,
    seller_zip_code_prefix        AS zip_prefix,
    initcap(trim(seller_city))    AS city,
    upper(trim(seller_state))     AS state
FROM raw.sellers;