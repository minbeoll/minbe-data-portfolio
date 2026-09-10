import mysql.connector

def get_conn(cfg: dict):
    return mysql.connector.connect(
        host=cfg["mysql"]["host"],
        port=cfg["mysql"]["port"],
        user=cfg["mysql"]["user"],
        password=cfg["mysql"]["password"],
        database=cfg["mysql"]["database"],
        autocommit=False,
    )
