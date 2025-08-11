import subprocess
import utils.pg_conn

def test_pg_conn():
    """Test de la connexion à la base de données PostgreSQL"""
    pg_conn = utils.pg_conn.PG_conn()
    
    try:
        conn = pg_conn.connect(autocommit=True)
        assert conn is not None, "La connexion n'a pas été établie"
        print("Connexion PostgreSQL réussie")
    except ValueError as e:
        print(f"Échec de la connexion PostgreSQL : {e}")
    finally:
        if pg_conn.conn:
            pg_conn.conn.close()
            print("Connexion PostgreSQL fermée")

def test_dbt_debug():
    """Test de l'exécution de 'dbt debug'"""
    try:
        result = subprocess.run(
            ['dbt', 'debug'],
            check=True,
            capture_output=True,
            text=True
        )
        print("DBT Debug réussi")
        print(result.stdout)  # Afficher les logs de la commande dbt debug
    except subprocess.CalledProcessError as e:
        print(f"Échec de l'exécution de dbt debug : {e}")
        print(e.stderr)  # Afficher les erreurs de la commande dbt debug

if __name__ == "__main__":
    test_pg_conn()  # Vérifier la connexion PostgreSQL
    test_dbt_debug()  # Vérifier le debug DBT
