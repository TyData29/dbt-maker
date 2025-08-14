@echo off
echo Installation des dependances Python...
pip install -r requirements.txt
echo Installation des dependances Python terminee.

:: Vérifier si le paramètre --dbt-setup est passé
set PARAM=%1
if "%PARAM%"=="--dbt-setup" (
    echo Execution de dbt_setup.bat...
    call dbt_setup.bat
    echo Configuration DBT terminee.
    echo ---------------------------
    call python_project_setup.bat
    echo Configuration du projet Python terminee.
) else (
    echo INFO : pour un setup dbt, utiliser --dbt-setup comme parametre
)


pause
