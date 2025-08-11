@echo off
echo Installation des dépendances Python...
pip install -r requirements.txt
echo Installation des dépendances Python terminée.

:: Vérifier si le paramètre --dbt-setup est passé
set PARAM=%1
if "%PARAM%"=="--dbt-setup" (
    echo Exécution de dbt_setup.bat...
    call dbt_setup.bat
    echo Configuration DBT terminée.
) else (
    echo INFO : pour un setup dbt, utiliser --dbt-setup comme paramètre
)

pause