import os
import sys
import shutil
import subprocess
from pathlib import Path
import utils.pg_conn


ROOT_DIR = Path(__file__).resolve().parents[2]          # ...\dbt-maker-1
PROJECT_DIR = ROOT_DIR / "dbt_project"                  # ...\dbt-maker-1\dbt_project
PROFILES_DIR = PROJECT_DIR          
  
def test_pg_conn():
    """Test de la connexion à la base de données PostgreSQL."""
    pg_conn = utils.pg_conn.PG_conn()
    try:
        conn = pg_conn.connect(autocommit=True)
        assert conn is not None, "La connexion n'a pas été établie"
        print("Connexion PostgreSQL réussie")
    except Exception as e:
        print(f"Échec de la connexion PostgreSQL : {e}")
        sys.exit(1)
    finally:
        if getattr(pg_conn, "conn", None):
            pg_conn.conn.close()
            print("Connexion PostgreSQL fermée")

def _run(cmd, cwd=None):
    return subprocess.run(cmd, cwd=cwd, check=True, capture_output=True, text=True)

def test_dbt_debug():
    """Exécute `dbt debug` dans le bon dossier avec le bon profiles-dir."""
    print(f"[dbg] PROJECT_DIR  = {PROJECT_DIR}")
    print(f"[dbg] PROFILES_DIR = {PROFILES_DIR}")

    if not PROJECT_DIR.exists():
        print(f"Échec: PROJECT_DIR introuvable: {PROJECT_DIR}")
        sys.exit(2)
    if not (PROFILES_DIR / "profiles.yml").exists():
        print(f"Échec: profiles.yml introuvable dans: {PROFILES_DIR}")
        sys.exit(2)

    # On cherche le binaire dbt (dans la venv de préférence)
    dbt_exe = shutil.which("dbt")
    if not dbt_exe:
        print("Échec: `dbt` introuvable dans l'environnement courant.")
        print("Active ta venv puis installe l'adapter, par ex.:")
        print(rf'  {ROOT_DIR}\.venv\Scripts\activate')
        print("  pip install \"dbt-core==1.9.*\" \"dbt-postgres==1.9.*\"")
        sys.exit(127)

    # On force aussi DBT_PROFILES_DIR par sécurité
    env = os.environ.copy()
    env["DBT_PROFILES_DIR"] = str(PROFILES_DIR)

    cmd = [dbt_exe, "debug", "--project-dir", str(PROJECT_DIR), "--profiles-dir", str(PROFILES_DIR)]
    try:
        result = subprocess.run(cmd, cwd=str(PROJECT_DIR), env=env, check=True, capture_output=True, text=True)
        print("DBT Debug réussi")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("Échec de l'exécution de dbt debug")
        if e.stdout:
            print("----- stdout -----")
            print(e.stdout)
        if e.stderr:
            print("----- stderr -----")
            print(e.stderr)
        sys.exit(e.returncode)

if __name__ == "__main__":
    test_pg_conn()
    test_dbt_debug()
