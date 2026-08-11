from fileinput import filename
import sys
from pathlib import Path

import pandas as pd

from src.db import get_connection
from src.logger import get_logger

log = get_logger(__name__)

RAW_DIR = Path("data/raw")


def load_csv(path: Path, table: str) -> int:
    """Грузит CSV в raw-таблицу через COPY. Все колонки text."""
    log.info(f"Начинаю загрузку {path.name} в raw.{table}")

    if not path.exists():
        log.error(f"Файл не найден: {path}")
        raise FileNotFoundError(f"Файл не найден: {path}")

    columns = pd.read_csv(path, nrows=0).columns.tolist()
    cols_ddl = ", ".join(f'"{c}" text' for c in columns)
    cols_list = ", ".join(f'"{c}"' for c in columns)

    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(f"DROP TABLE IF EXISTS raw.{table}")
                cur.execute(
                    f"CREATE TABLE raw.{table} ({cols_ddl}, "
                    f"_loaded_at timestamptz NOT NULL DEFAULT now(), "
                    f"_source text NOT NULL DEFAULT '{path.name}')"
                )

                sql = f"COPY raw.{table} ({cols_list}) FROM STDIN WITH (FORMAT csv, HEADER true)"
                with open(path, "r", encoding="utf-8") as f:
                    with cur.copy(sql) as copy:
                        while chunk := f.read(65536):
                            copy.write(chunk)

                cur.execute(f"SELECT count(*) FROM raw.{table}")
                rows = cur.fetchone()[0]

        log.info(f"Загружено {rows} строк в raw.{table}")
        return rows

    except Exception:
        log.exception(f"Ошибка при загрузке {path.name} в raw.{table}")
        raise


def filename_to_table(filename: str) -> str:
    """Превращает имя CSV-файла в имя таблицы.

    olist_orders_dataset.csv -> orders
    marketing_spend.csv -> marketing_spend
    """
    return filename.replace(".csv", "").replace("olist_", "").replace("_dataset", "")
   


if __name__ == "__main__":
    filename = sys.argv[1]
    table = filename_to_table(filename)
    load_csv(RAW_DIR / filename, table)
