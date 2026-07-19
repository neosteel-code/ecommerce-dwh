import os

import psycopg
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    """Соединение с PostgreSQL. Параметры берутся из .env."""
    return psycopg.connect(
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    )


if __name__ == "__main__":
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT version()")
            print(cur.fetchone()[0])

            cur.execute(
                "SELECT nspname FROM pg_namespace "
                "WHERE nspname IN ('raw','stg','core','mart') ORDER BY 1"
            )
            print("schemas:", [row[0] for row in cur.fetchall()])
