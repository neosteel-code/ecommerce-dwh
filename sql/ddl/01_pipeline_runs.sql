-- Таблица аудита запусков пайплайна.
-- Каждый вызов extract.py регистрирует свой запуск: начало, конец,
-- статус, количество строк. Используется для обнаружения аномалий
-- объёма данных между последовательными запусками (см. src/audit.py).

CREATE TABLE IF NOT EXISTS raw.pipeline_runs (
    run_id       serial PRIMARY KEY,
    pipeline_name text NOT NULL,
    source_file   text,
    target_table  text,
    started_at    timestamptz NOT NULL DEFAULT now(),
    finished_at   timestamptz,
    status        text NOT NULL DEFAULT 'running',
    rows_loaded   int,
    error_message text
);