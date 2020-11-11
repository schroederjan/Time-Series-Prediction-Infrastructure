import configparser
import psycopg2
from sql_queries import insert_table_queries

def insert_tables(cur, conn):
    """uses database connection and loads data into dimension/fact tables"""
    for query in insert_table_queries:
        cur.execute(query)
        conn.commit()

def main():
    """reads connection data from .cfg file and connects with psycopg2"""
    config = configparser.ConfigParser()
    config.read('dwh.cfg')

    conn = psycopg2.connect("host={} dbname={} user={} password={} port={}".format(*config['CLUSTER'].values()))
    cur = conn.cursor()
    
    insert_tables(cur, conn)

    conn.close()


if __name__ == "__main__":
    main()