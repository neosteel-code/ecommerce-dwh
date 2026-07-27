DROP TABLE IF EXISTS stg.customers;

CREATE TABLE stg.customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix              AS zip_prefix,
    initcap(trim(customer_city))          AS city,
    upper(trim(customer_state))           AS state
FROM raw.customers;