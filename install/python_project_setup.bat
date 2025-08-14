@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

echo [dbt-maker-setup-dbt] Verification de la connexion du projet Python...

REM Localiser ROOT_DIR = parent du dossier contenant ce script (dossier install)
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"
echo [dbt-maker-setup-dbt] ROOT_DIR = "%ROOT_DIR%"

REM Choisir l'interpreteur Python (ordre : venv actif, .venv local, py, python)
set "PY_EXE="

IF DEFINED VIRTUAL_ENV IF EXIST "%VIRTUAL_ENV%\Scripts\python.exe" SET "PY_EXE=%VIRTUAL_ENV%\Scripts\python.exe"
IF "%PY_EXE%"=="" IF EXIST "%ROOT_DIR%\.venv\Scripts\python.exe" SET "PY_EXE=%ROOT_DIR%\.venv\Scripts\python.exe"

IF "%PY_EXE%"=="" WHERE py >nul 2>nul
IF NOT ERRORLEVEL 1 IF "%PY_EXE%"=="" SET "PY_EXE=py"

IF "%PY_EXE%"=="" WHERE python >nul 2>nul
IF NOT ERRORLEVEL 1 IF "%PY_EXE%"=="" SET "PY_EXE=python"

IF "%PY_EXE%"=="" GOTO :NoPython

set "TEST_SCRIPT=%ROOT_DIR%\python_project\backend\_test_dbtmaker_setup.py"
IF NOT EXIST "%TEST_SCRIPT%" GOTO :NoScript

echo [dbt-maker-setup-dbt] Lancement: "%PY_EXE%" "%TEST_SCRIPT%"
"%PY_EXE%" "%TEST_SCRIPT%"
IF ERRORLEVEL 1 GOTO :PyError

echo [dbt-maker-setup-dbt] Test Python OK.
GOTO :EOF

:NoPython
echo([AVERTISSEMENT] Aucun interprete Python trouve (venv, .venv, py, python). Etape ignoree.
GOTO :EOF

:NoScript
echo([ERREUR] Script de test introuvable : "%TEST_SCRIPT%"
echo(         Attendu : %ROOT_DIR%\python_project\backend\_test_dbtmaker_setup.py
GOTO :EOF

:PyError
echo([AVERTISSEMENT] Le script de test Python a retourne une erreur.
GOTO :EOF
