@echo off
echo Configuration et initialisation du projet DBT...

::REM Charger les variables d'environnement depuis set_env.ps1
::powershell -ExecutionPolicy Bypass -File set_env.ps1


REM Initialiser un nouveau projet DBT
dbt init %DBT_PROJECT_NAME%

REM Copier le fichier de configuration personnalisé
copy "%CREDENTIALS_FILE_URL%" %DBT_DIR%\

REM Naviguer dans le répertoire du projet DBT
cd %DBT_DIR%

REM Exécuter dbt debug pour vérifier la configuration
dbt debug

echo Configuration et initialisation du projet DBT terminées.
pause