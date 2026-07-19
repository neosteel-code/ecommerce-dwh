import sys
from pathlib import Path

import pandas as pd

from src.db import get_connection

RAW_DIR = Path("data/raw")


def load_csv(path: Path, table: str) -> int:
    """Грузит CSV в raw-таблицу через COPY. Все колонки text."""
    columns = pd.read_csv(path, nrows=0).columns.tolist()
    cols_ddl = ", ".join(f'"{c}" text' for c in columns)
    cols_list = ", ".join(f'"{c}"' for c in columns)

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
            return cur.fetchone()[0]


if __name__ == "__main__":
    filename = sys.argv[1]
    table = filename.replace(".csv", "").replace("olist_", "").replace("_dataset", "")
    rows = load_csv(RAW_DIR / filename, table)
    print(f"raw.{table}: {rows} rows")
