import os
import psycopg2
import logging

logging.basicConfig(level=logging.DEBUG)

class PG_conn:

    def __init__(self):
        """Charge les credentials depuis les variables d'environnement"""
        self.autocommit = False
        self.conn = None

        # Récupération des variables d'environnement
        try:
            self.credentials = {
                "host": os.environ["POSTGRES_HOSTNAME"],
                "port": os.environ.get("POSTGRES_PORT", 5432),
                "dbname": os.environ["POSTGRES_DB"],
                "user": os.environ["POSTGRES_USER"],
                "password": os.environ["POSTGRES_PASSWORD"]
            }
            self.default_schema = os.environ["POSTGRES_DEFAULT_SCHEMA"]
        except KeyError as e:
            raise ValueError(f"Variable d'environnement manquante : {e}")

    def connect(self, autocommit=True):
        """Etablit la connexion à la base de données PostgreSQL"""
        try:
            self.conn = psycopg2.connect(**self.credentials)
        except psycopg2.OperationalError as e:
            logging.error(f"Erreur de connexion à la base de données : {e.pgcode} - {e.pgerror}")
            logging.error(f"Adresse : {self.credentials['host']}, Port : {self.credentials['port']}, "
                          f"Base de données : {self.credentials['dbname']}, Utilisateur : {self.credentials['user']}")
            raise ValueError(f"Erreur de connexion : {e}")

        self.conn.autocommit = True if autocommit else False
        return self.conn
