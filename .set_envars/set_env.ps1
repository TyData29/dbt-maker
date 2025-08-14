# set_env.ps1

# Chemin absolu vers le répertoire root de ce projet (répertoire parent de .tydata)
$env:PROJECT_ROOT_DIR = Split-Path $PSScriptRoot -Parent
Write-Host "Root directory: $env:PROJECT_ROOT_DIR"
# Charger les variables depuis le fichier .env
$envFile = Join-Path $env:PROJECT_ROOT_DIR ".env"
Write-Host "Loading environment variables from: $envFile"
if (Test-Path $envFile) {
    Get-Content -LiteralPath $envFile | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }   # skip vide/commentaire

        # clé=valeur (tout ce qui suit le premier '=' fait partie de la valeur)
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $envName  = $line.Substring(0, $eq).Trim()
        $envValue = $line.Substring($eq + 1).Trim()

        # nettoyer BOM éventuel sur le premier nom
        $envName = $envName -replace "^\uFEFF",""

        # enlever des guillemets éventuels autour de la valeur
        if (($envValue.StartsWith('"') -and $envValue.EndsWith('"')) -or
            ($envValue.StartsWith("'") -and $envValue.EndsWith("'"))) {
            $envValue = $envValue.Substring(1, $envValue.Length - 2)
        }

        # assignation scope Process (session courante)
        #${Global:Env:$envName} = $envValue
        [System.Environment]::SetEnvironmentVariable($envName, $envValue, "Process")

        #Write-Host "Chargé : $envName=$envValue > " [Environment]::GetEnvironmentVariable($envName,'Process')
    }
    Write-Host "Chargement des variables d'environnement OK !"
} else {
    Write-Host ".env file $envFile non trouvé"
}


# Localisation répertoire dbt_project à partir du répertoire root du projet
$env:DBT_DIR = Join-Path $env:PROJECT_ROOT_DIR $env:DBT_PROJECT_NAME
# Localisation du fichier de profil dbt à charger à l'initialisation (situé depuis root dans install/utils/profiles.yml)
$env:CREDENTIALS_FILE_URL =  Join-Path $env:PROJECT_ROOT_DIR "install/utils/profiles.yml"

# Variables d'environnement pour les runs dbt
# [empty]
