-- Staging: маркетинговые расходы
-- Источник: raw.marketing_spend
-- Дефекты см. docs/known_defects.md

CREATE TABLE IF NOT EXISTS stg.channel_mapping (
    raw_channel   text PRIMARY KEY,
    clean_channel text NOT NULL,
    reason        text,
    created_at    timestamptz NOT NULL DEFAULT now()
);

INSERT INTO stg.channel_mapping (raw_channel, clean_channel, reason) VALUES
    ('facebok_ads', 'facebook_ads', 'Опечатка: пропущена буква o. Май 2018 - единственный месяц без facebook_ads, суммы продолжают ряд')
ON CONFLICT (raw_channel) DO NOTHING;

DROP TABLE IF EXISTS stg.marketing_spend;

CREATE TABLE stg.marketing_spend AS
SELECT
    sub.spend_date,
    COALESCE(m.clean_channel, sub.channel) AS channel,
    sub.spend,
    sub.clicks,
    sub.impressions,
    CASE
        WHEN sub.spend IS NULL THEN 'missing_spend'
        WHEN sub.spend < 0     THEN 'negative_spend'
        ELSE 'ok'
    END AS quality_flag
FROM (
    SELECT
        CASE
            WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN to_date(date, 'YYYY-MM-DD')
            WHEN date ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(date, 'DD/MM/YYYY')
            ELSE NULL
        END                                     AS spend_date,
        replace(lower(trim(channel)), ' ', '_') AS channel,
        replace(spend, ',', '.')::numeric       AS spend,
        clicks::int                             AS clicks,
        impressions::int                        AS impressions,
        row_number() OVER (
            PARTITION BY
                CASE
                    WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN to_date(date, 'YYYY-MM-DD')
                    WHEN date ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(date, 'DD/MM/YYYY')
                    ELSE NULL
                END,
                lower(trim(channel))
            ORDER BY spend
        ) AS rn
    FROM raw.marketing_spend
) sub
LEFT JOIN stg.channel_mapping m
    ON m.raw_channel = sub.channel
WHERE sub.rn = 1;