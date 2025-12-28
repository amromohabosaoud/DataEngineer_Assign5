import os, sys, psycopg2
from pathlib import Path
from psycopg2.extras import execute_values

SCHEMA = "assignment5"


def connect():
    return psycopg2.connect(
        dbname="dwh",
        user="postgres",
        password="admin",
        host="localhost",
        port="5433",
    )

def copy_into_table(cur, qualified_table: str, csv_file_path: Path):
    with csv_file_path.open("r", encoding="utf-8") as f:
        cur.copy_expert(
            f"COPY {qualified_table} FROM STDIN WITH (FORMAT CSV, HEADER TRUE)",
            f,
        )

def hex_mod10(postal_code: str | None) -> int | None:
    if postal_code is None:
        return None
    s = str(postal_code).strip().lower()
    if not s:
        return None

    rem = 0
    for ch in s:
        if "0" <= ch <= "9":
            v = ord(ch) - ord("0")
        elif "a" <= ch <= "f":
            v = 10 + (ord(ch) - ord("a"))
        else:
            return None
        rem = (rem * 16 + v) % 10
    return rem

def region_code_to_name(region_code: int | None) -> str | None:
    if region_code is None:
        return None
    region_map = {
        1: "Stockholm",
        2: "Södermanland / Östergötland",
        3: "Jönköping",
        4: "Skåne",
        5: "Kronoberg / Kalmar",
        6: "Värmland / Dalarna",
        7: "Gävleborg / Västernorrland",
        8: "Västerbotten / Norrbotten",
        9: "Blekinge",
        0: "Gotland",
    }
    return region_map.get(region_code)


def main():
    base_dir = Path(".").resolve()
    data_dir = base_dir / "data"

    customers_csv = data_dir / "customers.csv"
    articles_csv = data_dir / "articles.csv"
    transactions_csv = data_dir / "transactions.csv"
    weather_csv = data_dir / "open-meteo-2019.csv"

    for p in [customers_csv, articles_csv, transactions_csv, weather_csv]:
        if not p.exists():
            raise FileNotFoundError(f"Missing required file: {p}")

    conn = connect()
    conn.autocommit = False

    try:
        with conn.cursor() as cur:
            cur.execute(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA};")
            cur.execute(f"SET search_path TO {SCHEMA};")
        conn.commit()

        with conn.cursor() as cur:
            cur.execute(f"SET search_path TO {SCHEMA};")
            cur.execute("DROP TABLE IF EXISTS stg_customers;")
            cur.execute("DROP TABLE IF EXISTS stg_articles;")
            cur.execute("DROP TABLE IF EXISTS stg_transactions;")
            cur.execute("DROP TABLE IF EXISTS stg_meteo;")
            cur.execute(
                """
                CREATE TABLE stg_customers (
                    customer_id TEXT,
                    fn TEXT,
                    active TEXT,
                    club_member_status TEXT,
                    fashion_news_frequency TEXT,
                    age TEXT,
                    postal_code TEXT
                );
                """
            )

            cur.execute(
                """
                CREATE TABLE stg_articles (
                    article_id TEXT,
                    product_code TEXT,
                    prod_name TEXT,
                    product_type_no TEXT,
                    product_type_name TEXT,
                    product_group_name TEXT,
                    graphical_appearance_no TEXT,
                    graphical_appearance_name TEXT,
                    colour_group_code TEXT,
                    colour_group_name TEXT,
                    perceived_colour_value_id TEXT,
                    perceived_colour_value_name TEXT,
                    perceived_colour_master_id TEXT,
                    perceived_colour_master_name TEXT,
                    department_no TEXT,
                    department_name TEXT,
                    index_code TEXT,
                    index_name TEXT,
                    index_group_no TEXT,
                    index_group_name TEXT,
                    section_no TEXT,
                    section_name TEXT,
                    garment_group_no TEXT,
                    garment_group_name TEXT,
                    detail_desc TEXT
                );
                """
            )

            cur.execute(
                """
                CREATE TABLE stg_transactions (
                    t_dat TEXT,
                    customer_id TEXT,
                    article_id TEXT,
                    price TEXT,
                    sales_channel_id TEXT
                );
                """
            )

            cur.execute(
                """
                CREATE TABLE stg_meteo (
                    day TEXT,
                    weather_code_raw TEXT
                );
                """
            )

            print("Loading customers...")
            copy_into_table(cur, f"{SCHEMA}.stg_customers", customers_csv)
            print("Loading articles...")
            copy_into_table(cur, f"{SCHEMA}.stg_articles", articles_csv)
            print("Loading transactions...")
            copy_into_table(cur, f"{SCHEMA}.stg_transactions", transactions_csv)
            print("Loading meteo...")
            copy_into_table(cur, f"{SCHEMA}.stg_meteo", weather_csv)

            print("Inserting into final tables...")
            cur.execute(
                f"""
                SET search_path TO {SCHEMA};

                INSERT INTO customers (customer_id, fn, active, club_member_status, fashion_news_frequency, age, postal_code)
                SELECT
                    customer_id,
                    NULLIF(fn, '')::NUMERIC::INTEGER,
                    NULLIF(active, '')::NUMERIC::INTEGER,
                    NULLIF(club_member_status, ''),
                    NULLIF(fashion_news_frequency, ''),
                    NULLIF(age, '')::NUMERIC::INTEGER,
                    NULLIF(postal_code, '')
                FROM stg_customers;

                INSERT INTO articles (
                    article_id, product_code, prod_name, product_type_no, product_type_name, product_group_name,
                    graphical_appearance_no, graphical_appearance_name, colour_group_code, colour_group_name,
                    perceived_colour_value_id, perceived_colour_value_name, perceived_colour_master_id, perceived_colour_master_name,
                    department_no, department_name, index_code, index_name, index_group_no, index_group_name,
                    section_no, section_name, garment_group_no, garment_group_name, detail_desc
                )
                SELECT
                    article_id,
                    NULLIF(product_code, '')::NUMERIC::INTEGER,
                    NULLIF(prod_name, ''),
                    NULLIF(product_type_no, '')::NUMERIC::INTEGER,
                    NULLIF(product_type_name, ''),
                    NULLIF(product_group_name, ''),
                    NULLIF(graphical_appearance_no, '')::NUMERIC::INTEGER,
                    NULLIF(graphical_appearance_name, ''),
                    NULLIF(colour_group_code, '')::NUMERIC::INTEGER,
                    NULLIF(colour_group_name, ''),
                    NULLIF(perceived_colour_value_id, '')::NUMERIC::INTEGER,
                    NULLIF(perceived_colour_value_name, ''),
                    NULLIF(perceived_colour_master_id, '')::NUMERIC::INTEGER,
                    NULLIF(perceived_colour_master_name, ''),
                    NULLIF(department_no, '')::NUMERIC::INTEGER,
                    NULLIF(department_name, ''),
                    NULLIF(index_code, ''),
                    NULLIF(index_name, ''),
                    NULLIF(index_group_no, '')::NUMERIC::INTEGER,
                    NULLIF(index_group_name, ''),
                    NULLIF(section_no, '')::NUMERIC::INTEGER,
                    NULLIF(section_name, ''),
                    NULLIF(garment_group_no, '')::NUMERIC::INTEGER,
                    NULLIF(garment_group_name, ''),
                    NULLIF(detail_desc, '')
                FROM stg_articles;

                INSERT INTO meteo (day, weather_code)
                SELECT
                    NULLIF(day, '')::DATE,
                    NULLIF(weather_code_raw, '')::NUMERIC::INTEGER
                FROM stg_meteo;

                INSERT INTO transactions (t_dat, customer_id, article_id, price, sales_channel_id)
                SELECT
                    NULLIF(t_dat, '')::DATE,
                    customer_id,
                    article_id,
                    NULLIF(price, '')::NUMERIC,
                    NULLIF(sales_channel_id, '')::NUMERIC::INTEGER
                FROM stg_transactions;
                """
            )
        print("Computing regions...")
        
        with conn.cursor() as setup_cur:
            setup_cur.execute(f"SET search_path TO {SCHEMA};")
        
        with conn.cursor(name='fetch_cursor') as fetch_cur:
            fetch_cur.execute(f"SELECT customer_id, postal_code FROM {SCHEMA}.stg_customers;")

            rows = []
            batch_size = 10000

            with conn.cursor() as insert_cur:
                def flush():
                    nonlocal rows
                    if not rows:
                        return
                    execute_values(
                        insert_cur,
                        f"""
                        INSERT INTO {SCHEMA}.customer_region (customer_id, postal_code_mod10, region_name)
                        VALUES %s
                        ON CONFLICT (customer_id) DO UPDATE
                        SET postal_code_mod10 = EXCLUDED.postal_code_mod10,
                            region_name = EXCLUDED.region_name
                        """,
                        rows,
                        page_size=batch_size,
                    )
                    rows = []

                for customer_id, postal_code in fetch_cur:
                    mod10 = hex_mod10(postal_code)
                    region = region_code_to_name(mod10)
                    rows.append((customer_id, mod10, region))
                    if len(rows) >= batch_size:
                        flush()
                flush()

        with conn.cursor() as cur:
            cur.execute(
                f"""
                SET search_path TO {SCHEMA};
                DROP TABLE IF EXISTS stg_customers;
                DROP TABLE IF EXISTS stg_articles;
                DROP TABLE IF EXISTS stg_transactions;
                DROP TABLE IF EXISTS stg_meteo;
                """
            )

        conn.commit()
        
        with conn.cursor() as cur:
            cur.execute(f"SET search_path TO {SCHEMA};")
            
            cur.execute("SELECT COUNT(*) FROM customers;")
            cust_count = cur.fetchone()[0]
            
            cur.execute("SELECT COUNT(*) FROM articles;")
            art_count = cur.fetchone()[0]
            
            cur.execute("SELECT COUNT(*) FROM transactions;")
            trans_count = cur.fetchone()[0]
            
            cur.execute("SELECT COUNT(*) FROM meteo;")
            meteo_count = cur.fetchone()[0]
            
            cur.execute("SELECT COUNT(*) FROM customer_region;")
            region_count = cur.fetchone()[0]
            
            print("\nETL import completed successfully!")
            print(f"\nRow counts:")
            print(f"  customers: {cust_count:,}")
            print(f"  articles: {art_count:,}")
            print(f"  transactions: {trans_count:,}")
            print(f"  meteo: {meteo_count:,}")
            print(f"  customer_region: {region_count:,}")

    except Exception as e:
        conn.rollback()
        print(f"\nTL failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        conn.close()


if __name__ == "__main__":
    main()