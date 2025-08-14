@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ====== Parametres attendus ======
REM DBT_PROJECT_NAME : Nom du projet dbt (obligatoire)
REM DBT_PROFILE_NAME : (optionnel) Nom du profil a utiliser ; sinon auto-detect depuis profiles.yml

echo [dbt-setup] Demarrage...

REM 1) Localiser les chemins
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"
set "UTILS_DIR=%SCRIPT_DIR%utils"
set "SRC_PROFILES=%UTILS_DIR%\profiles.yml"

if "%DBT_PROJECT_NAME%"=="" (
  echo [ERREUR] DBT_PROJECT_NAME n'est pas defini.
  exit /b 1
)

REM Nettoyage d'un eventuel commentaire inline
for /f "tokens=1 delims=#" %%A in ("%DBT_PROJECT_NAME%") do set "DBT_PROJECT_NAME=%%~A"
for /f "tokens=* delims= " %%A in ("%DBT_PROJECT_NAME%") do set "DBT_PROJECT_NAME=%%~A"

set "PROJECT_DIR=%ROOT_DIR%\%DBT_PROJECT_NAME%"

echo [dbt-setup] ROOT_DIR      = "%ROOT_DIR%"
echo [dbt-setup] PROJECT_DIR   = "%PROJECT_DIR%"
echo [dbt-setup] SRC_PROFILES  = "%SRC_PROFILES%"

REM 2) Creer le repertoire du projet
if not exist "%ROOT_DIR%\" (
  echo [ERREUR] Racine introuvable: "%ROOT_DIR%".
  exit /b 1
)

if exist "%PROJECT_DIR%\" (
  dir /a "%PROJECT_DIR%" | findstr /r "^[ ]*[0-9][0-9]*" >nul
  if not errorlevel 1 (
    echo [ERREUR] Le dossier "%PROJECT_DIR%" existe et n'est pas vide. Abandon.
    echo          ^(Vider le dossier ou definir FORCE=1 pour continuer et laisser dbt gerer.^)
    if not "%FORCE%"=="1" exit /b 1
  )
) else (
  mkdir "%PROJECT_DIR%"
  if errorlevel 1 (
    echo [ERREUR] Echec de creation du dossier projet.
    exit /b 1
  )
)

REM 3) Copier utils\profiles.yml dans le dossier du projet
if not exist "%SRC_PROFILES%" (
  echo [ERREUR] Fichier introuvable: "%SRC_PROFILES%".
  exit /b 1
)
copy /Y "%SRC_PROFILES%" "%PROJECT_DIR%\profiles.yml" >nul
if errorlevel 1 (
  echo [ERREUR] Echec de copie de profiles.yml dans le projet.
  exit /b 1
)

REM 4) Determiner le nom du profil
set "PROFILE_NAME=%DBT_PROFILE_NAME%"
if "%PROFILE_NAME%"=="" (
  set "PROFILE_NAME="
  for /f "usebackq delims=:" %%A in (`findstr /R "^[A-Za-z0-9_-][A-Za-z0-9_-]*:" "%PROJECT_DIR%\profiles.yml"`) do (
    set "PROFILE_NAME=%%A"
    goto :got_profile
  )
  :got_profile
  if "%PROFILE_NAME%"=="" (
    echo [ERREUR] Impossible de detecter la cle de profil dans profiles.yml.
    echo          Renseigne DBT_PROFILE_NAME ou verifie le fichier.
    exit /b 1
  )
  for /f "tokens=* delims= " %%A in ("%PROFILE_NAME%") do set "PROFILE_NAME=%%~A"
)

echo [dbt-setup] PROFILE_NAME  = "%PROFILE_NAME%"

REM 5) Se placer dans la racine
pushd "%ROOT_DIR%"
if errorlevel 1 (
  echo [ERREUR] Impossible de se placer dans "%ROOT_DIR%".
  exit /b 1
)

REM 6) dbt init avec --profile et --profiles-dir (vers le fichier copie)
echo [dbt-setup] Lancement: dbt init "%DBT_PROJECT_NAME%" --profile "%PROFILE_NAME%" --profiles-dir "%PROJECT_DIR%"
dbt init "%DBT_PROJECT_NAME%" --profile "%PROFILE_NAME%" --profiles-dir "%PROJECT_DIR%"
if errorlevel 1 (
  echo [ERREUR] dbt init a echoue.
  popd
  exit /b 1
)

REM 7) Verification
if exist "%PROJECT_DIR%\dbt_project.yml" (
  echo [dbt-setup] Verification: dbt debug --profiles-dir "%PROJECT_DIR%"
  pushd "%PROJECT_DIR%"
  dbt debug --profiles-dir "%PROJECT_DIR%"
  set "DBG_ERR=%ERRORLEVEL%"
  popd
  if not "%DBG_ERR%"=="0" (
    echo [AVERTISSEMENT] dbt debug a signale un probleme de profil ou de connexion.
  )
) else (
  echo [AVERTISSEMENT] dbt_project.yml introuvable dans "%PROJECT_DIR%".
)

popd
echo [dbt-setup] Terminé.
exit /b 0
