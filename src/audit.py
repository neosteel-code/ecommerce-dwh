from datetime import datetime, timezone

from src.db import get_connection
from src.logger import get_logger

log = get_logger(__name__)


def start_run(pipeline_name: str, source_file: str, target_table: str) -> int:
    """Регистрирует начало запуска пайплайна, возвращает run_id."""
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO raw.pipeline_runs (pipeline_name, source_file, target_table)
            VALUES (%s, %s, %s)
            RETURNING run_id
            """,
            (pipeline_name, source_file, target_table),
        )
        run_id = cur.fetchone()[0]
    log.info(f"Запуск #{run_id} зарегистрирован: {pipeline_name} ({source_file})")
    return run_id


def finish_run_success(run_id: int, rows_loaded: int) -> None:
    """Отмечает запуск как успешный."""
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            """
            UPDATE raw.pipeline_runs
            SET status = 'success', finished_at = %s, rows_loaded = %s
            WHERE run_id = %s
            """,
            (datetime.now(timezone.utc), rows_loaded, run_id),
        )
    log.info(f"Запуск #{run_id} завершён успешно: {rows_loaded} строк")


def finish_run_failed(run_id: int, error_message: str) -> None:
    """Отмечает запуск как провалившийся."""
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            """
            UPDATE raw.pipeline_runs
            SET status = 'failed', finished_at = %s, error_message = %s
            WHERE run_id = %s
            """,
            (datetime.now(timezone.utc), error_message[:2000], run_id),
        )
    log.error(f"Запуск #{run_id} завершён с ошибкой")

def check_row_count_anomaly(target_table: str, rows_loaded: int, threshold: float = 0.8) -> bool:
    """Сравнивает rows_loaded с предыдущим успешным запуском той же таблицы.

    Возвращает True, если объём упал более чем на (1 - threshold) * 100%.
    """
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            """
            SELECT rows_loaded
            FROM raw.pipeline_runs
            WHERE target_table = %s AND status = 'success'
            ORDER BY run_id DESC
            LIMIT 1
            """,
            (target_table,),
        )
        row = cur.fetchone()

    if row is None or row[0] is None:
        log.info(f"{target_table}: первый успешный запуск, сравнивать не с чем")
        return False

    prev_rows = row[0]
    if rows_loaded < threshold * prev_rows:
        log.warning(
            f"{target_table}: подозрительное падение объёма — "
            f"было {prev_rows}, стало {rows_loaded} "
            f"({round(100 * rows_loaded / prev_rows, 1)}% от прошлого запуска)"
        )
        return True

    log.info(f"{target_table}: объём в норме ({rows_loaded} строк, было {prev_rows})")
    return False