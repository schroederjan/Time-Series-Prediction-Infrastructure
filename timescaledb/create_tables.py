import configparser
import psycopg2
from sql_queries import create_table_queries, drop_table_queries, drop_extensions_queries, create_extensions_queries

def drop_tables(cur, conn):
    """uses database connection to reset tables in db by droping them, first"""
    for query in drop_table_queries:
        cur.execute(query)
        conn.commit()


def create_tables(cur, conn):
    """uses database connection to reset tables in db by creating new ones, second"""
    for query in create_table_queries:
        cur.execute(query)
        conn.commit()


def main():
    """reads connection data from .cfg file and connects with psycopg2"""
    config = configparser.ConfigParser()
    config.read('dwh.cfg')

    conn = psycopg2.connect("host={} dbname={} user={} password={} port={}".format(*config['TIMESCALEDB'].values()))
    cur = conn.cursor()

    drop_extensions_queries
    create_extensions_queries
    
    drop_tables(cur, conn)
    create_tables(cur, conn)

    conn.close()

if __name__ == "__main__":
    main()