@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ========= Config attendue =========
REM set DBT_PROJECT_NAME=dbt_project   (doit etre defini avant appel)
REM OPTIONNEL: set DBT_PROFILE_NAME=xxx (sinon auto-detecte depuis profiles.yml)
REM OPTIONNEL: set FORCE=1             (pour purger/recreer le projet)

REM 0) Localisations: script = install\, racine = parent de install\
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"

REM Chemin du profiles.yml A UTILISER (fixe)
set "PROFILES_DIR=%SCRIPT_DIR%utils"
set "PROFILES_SRC=%PROFILES_DIR%\profiles.yml"

REM 1) Verifs basiques
if "%DBT_PROJECT_NAME%"=="" (
  echo([ERREUR] DBT_PROJECT_NAME n'est pas defini.
  exit /b 1
)
if not exist "%PROFILES_SRC%" (
  echo([ERREUR] Fichier introuvable: "%PROFILES_SRC%"
  exit /b 1
)

set "PROJECT_DIR=%ROOT_DIR%\%DBT_PROJECT_NAME%"

echo [dbt-maker-setup:->dbt] ROOT_DIR     = "%ROOT_DIR%"
echo [dbt-maker-setup:->dbt] PROJECT_DIR  = "%PROJECT_DIR%"
echo [dbt-maker-setup:->dbt] PROFILES_SRC = "%PROFILES_SRC%"

REM 2) Detecter le nom du profil (cle YAML racine) si non fourni
if "%DBT_PROFILE_NAME%"=="" (
  set "DBT_PROFILE_NAME="
  for /f "usebackq tokens=1 delims=:" %%A in (`findstr /R "^[A-Za-z0-9_-][A-Za-z0-9_-]*:" "%PROFILES_SRC%"`) do (
    set "DBT_PROFILE_NAME=%%A"
    goto :_have_profile
  )
  :_have_profile
  if "%DBT_PROFILE_NAME%"=="" (
    echo([ERREUR] Impossible de detecter la cle de profil dans "%PROFILES_SRC%".
    exit /b 1
  )
)
echo [dbt-maker-setup:->dbt] PROFILE_NAME = "%DBT_PROFILE_NAME%"

REM 3) Si FORCE=1 et que le projet existe, supprimer avant dbt init
if exist "%PROJECT_DIR%\" (
  if /I "%FORCE%"=="1" (
    echo [dbt-maker-setup:->dbt] FORCE=1 -> suppression de "%PROJECT_DIR%"
    rmdir /S /Q "%PROJECT_DIR%"
    if errorlevel 1 (
      echo([ERREUR] Echec de suppression de "%PROJECT_DIR%".
      exit /b 1
    )
  ) else (
    echo([ERREUR] Le dossier "%PROJECT_DIR%" existe deja. Utilise FORCE=1 pour le purger et le recreer.
    exit /b 1
  )
)

REM -- 4) Lancer dbt init depuis la RACINE, avec un --profiles-dir ABSOLU

REM Normaliser PROFILES_DIR en chemin absolu (evite toute dependance au CWD)
for %%I in ("%SCRIPT_DIR%utils") do set "PROFILES_DIR=%%~fI"

pushd "%ROOT_DIR%"
if errorlevel 1 (
  echo([ERREUR] Impossible d'acceder a "%ROOT_DIR%".
  exit /b 1
)

echo [dbt-maker-setup:->dbt][dbg] CWD avant init  : %CD%
echo [dbt-maker-setup:->dbt][dbg] profiles-dir    : %PROFILES_DIR%

echo [dbt-maker-setup:->dbt] Lancement: dbt init "%DBT_PROJECT_NAME%" --profile "%DBT_PROFILE_NAME%" --profiles-dir "%PROFILES_DIR%"
dbt init "%DBT_PROJECT_NAME%" --profile "%DBT_PROFILE_NAME%" --profiles-dir "%PROFILES_DIR%"
set "ERR=%ERRORLEVEL%"

popd

if not "%ERR%"=="0" (
  echo([ERREUR] dbt init a echoue.
  exit /b 1
)

REM 5) (Optionnel) Recopier le profiles.yml dans le dossier du projet pour reference
copy /Y "%PROFILES_SRC%" "%PROJECT_DIR%\profiles.yml" >nul

REM 6) Verifier la config
pushd "%PROJECT_DIR%"
dbt debug --profiles-dir "%PROFILES_DIR%"
set "DBG_ERR=%ERRORLEVEL%"
popd

if not "%DBG_ERR%"=="0" (
  echo([AVERTISSEMENT] dbt debug a signale un probleme de profil/connexion.
)

echo [dbt-maker-setup:->dbt] Termine.
exit /b 0
