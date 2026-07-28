-- Dimension: товары
-- Одна строка = один товар
-- Категории переведены на английский в stg, товары без категории -> 'undefined'
-- Источник: stg.products

DROP TABLE IF EXISTS core.dim_product;

CREATE TABLE core.dim_product AS
SELECT
    row_number() OVER (ORDER BY product_id) AS product_key,
    product_id,
    category,
    category_pt,
    weight_g,
    length_cm,
    height_cm,
    width_cm
FROM stg.products;