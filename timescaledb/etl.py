import configparser
import psycopg2
from sql_queries import insert_table_queries, update_table_queries, alter_table_queries

def insert_tables(cur, conn):
    """uses database connection and loads data into dimension/fact tables"""
    for query in insert_table_queries:
        cur.execute(query)
        conn.commit()

def main():
    """reads connection data from .cfg file and connects with psycopg2"""
    config = configparser.ConfigParser()
    config.read('dwh.cfg')

    conn = psycopg2.connect("host={} dbname={} user={} password={} port={}".format(*config['TIMESCALEDB'].values()))
    cur = conn.cursor()
    
    #insert
    insert_tables(cur, conn)
    
    #copy/insert from csv
    file = open('nyc_data_rides.csv')
    cur.copy_from(file, 'rides', sep=',')    
    
    #alter 
    #can not be called as a list
    alter_1 = "ALTER TABLE rides ADD COLUMN pickup_geom geometry(POINT,2163)"
    alter_2 = "ALTER TABLE rides ADD COLUMN dropoff_geom geometry(POINT,2163)"   
    cur.execute(alter_1)    
    cur.execute(alter_2)    
    #alter_table_queries(cur, conn)
    
    #update 
    update_1 = "UPDATE rides SET pickup_geom = ST_Transform(ST_SetSRID(ST_MakePoint(pickup_longitude,pickup_latitude),4326),2163), dropoff_geom = ST_Transform(ST_SetSRID(ST_MakePoint(dropoff_longitude,dropoff_latitude),4326),2163)"
    cur.execute(update_1)
    #update_table_queries(cur, conn)
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    main()