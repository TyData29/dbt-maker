# set_env.ps1

# Chemin absolu vers le répertoire root de ce projet (répertoire parent de .tydata)
$env:PROJECT_ROOT_DIR = Split-Path $PSScriptRoot -Parent
Write-Host "Root directory: $env:PROJECT_ROOT_DIR"
# Charger les variables depuis le fichier .env
$envFile = Join-Path $env:PROJECT_ROOT_DIR ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^\s*([^#\s][^=]*)\s*=\s*(.*)\s*$") {
            $envName = $matches[1]
            $envValue = $matches[2]

            # >>> $env:$envName = $envValue
            [System.Environment]::SetEnvironmentVariable($envName, $envValue)

            #Write-Host "Chargé : $envName=$envValue"
        }
    }
} else {
    Write-Host ".env file $envFile non trouvé"
}


# Localisation répertoire dbt_project à partir du répertoire root du projet
$env:DBT_DIR = Join-Path $env:PROJECT_ROOT_DIR $env:DBT_PROJECT_NAME
# Localisation du fichier de profil dbt à charger à l'initialisation (situé depuis root dans install/utils/profiles.yml)
$env:CREDENTIALS_FILE_URL =  Join-Path $env:PROJECT_ROOT_DIR "install/utils/profiles.yml"

# Variables d'environnement pour les runs dbt
# [empty]
