# Lien du projet

[dbt-maker](https://github.com/TyData29/dbt-maker)

# What's this ?

dbt-maker installe et configure un **environnement de projet dbt** couplé acessoirement à un répertoire de scripts python partageant la même connexion DW.
Il facilite le déploiement de nouveaux projets dbt Core : seules quelques variables d'environnement, essentiellement les secrets, sont à renseigner.

# Fonctionnalités 

Facilite la création d'un nouveau projet dbt Core associé à un environnement de développement Python
- Centralise les paramètres du projet dans un fichier 
- Initie le projet dbt
- Crée le connecteur python `pg_conn.py`
- Teste le fonctionnement de dbt, de la connexion Postgres depuis Python, de l'exécution de commandes dbt depuis Python

# Installation

## Création d'un nouveau projet "from scratch" sous Windows avec VSCode
1. Dans Github, créer un repo en sélectionnant **dbt-maker**  dans **“Start with a template”**
2. En local, ouvrir VSCode et choisir l’option **`Clone Git Repository`** et indiquer l’url du repo créé au 1

<img width="214" height="41" alt="Capture d'écran 2025-08-11 130223" src="https://github.com/user-attachments/assets/19f9f536-57e6-44c8-ab30-4938b7f5e514" />


1.  Indiquer la destination (répertoire parent du projet à créer)
2. Ouvir le répertoire créé dans VSCode
3. Créer l’environnement virtuel avec `Ctrl+Shift+P` avec ou sans l’installation des dépendances
4. Créer un fichier `.env` sur le modèle de `.env.template` et renseigner les secrets
5. Ouvrir un nouveau terminal (vérifier le chargement des variables d’environnement : `> $env:POSTGRES_HUB` ou équivalent (dans la liste des variables d'environnement définies dans `.env`)
   Elles sont en principe chargées automatiquement par les scripts situés dans `.vscode/` et `.set_envars/`
6. Mettre à jour `install/requirements.txt` si nécessaire 
7. Placé dans `install/` exécuter : `.\install.bat --dbt-setup` (Attention, cette commande exécute un dbt init, ne pas utiliser sur projet existant)

## Cloner un projet créé avec dbt-maker sous Windows avec VSCode

### Installation de l'instance locale du code du projet
1. Ouvrir une nouvelle fenêtre VSCode
Créer un **environnement virtuel** dans un nouveau répertoire
2. Utiliser le menu Start > Clone Git Repository et **cloner le repo souhaité** dans le répertoire choisi
2. Enregistrer `.env.template` comme `.env` **PUIS** renseigner les variables
3. Ouvrir un nouveau terminal et vérifer le bon chargement des variables d'environnement: `> $env:POSTGRES_HUB` ou équivalent (dans la liste des variables d'environnement définies dans `.env`) 
   Elles sont en principe chargées automatiquement par les scripts situés dans `.vscode/` et `.set_envars/`
4. Mettre à jour `install/requirements.txt` si nécessaire 
5. Placé dans `install/` exécuter : `.\install.bat` (**ne pas** utiliser l'extension `--dbt-setup`)
6. A vous de jouer !

### Commandes dbt à lancer pour exécuter le workflow
Dans un terminal Powershell, se positionner dans le répertoire du projet dbt (dans le doute, rechercher le fichier `dbt_project.yml`)
> `dbt build` pour exécuter l'intégralité du workflow (voir la [doc de dbt pour + d'infos](https://docs.getdbt.com/docs/introduction) )

# Crédits
@ [TyData - Freelance Geodata Expert & Analytics Engineer](https://github.com/TyData29)
