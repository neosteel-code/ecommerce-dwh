DROP TABLE IF EXISTS stg.products;

CREATE TABLE stg.products AS
SELECT
    p.product_id,
    p.product_category_name                              AS category_pt,
    COALESCE(
        t.product_category_name_english,
        CASE
            WHEN p.product_category_name = 'pc_gamer' THEN 'pc_gamer'
            WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
                THEN 'kitchen_portables_and_food_preparers'
            WHEN p.product_category_name IS NULL THEN 'undefined'
            ELSE p.product_category_name
        END
    )                                                    AS category,
    p.product_weight_g::numeric                          AS weight_g,
    p.product_length_cm::numeric                         AS length_cm,
    p.product_height_cm::numeric                         AS height_cm,
    p.product_width_cm::numeric                          AS width_cm
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
    ON t.product_category_name = p.product_category_name;