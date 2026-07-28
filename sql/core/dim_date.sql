-- Dimension: календарь
-- Одна строка = один день
-- Период: 2016-01-01 .. 2018-12-31 (покрывает данные Olist с запасом)
-- Источник: generate_series, не зависит от данных

DROP TABLE IF EXISTS core.dim_date;

CREATE TABLE core.dim_date AS
SELECT
    d::date                          AS date_key,
    extract(year FROM d)::int        AS year,
    extract(quarter FROM d)::int     AS quarter,
    extract(month FROM d)::int       AS month,
    to_char(d, 'YYYY-MM')            AS year_month,
    trim(to_char(d, 'Month'))        AS month_name,
    extract(day FROM d)::int         AS day_of_month,
    extract(isodow FROM d)::int      AS day_of_week,
    trim(to_char(d, 'Day'))          AS day_name,
    extract(week FROM d)::int        AS week_of_year,
    (extract(isodow FROM d) >= 6)    AS is_weekend
FROM generate_series('2016-01-01'::date, '2018-12-31'::date, '1 day') AS d;