Facilite la création d'un nouveau projet dbt Core associé à un environnement de développement Python
- Centralise les paramètres du projet dans un fichier 
- Initie le projet dbt
- Crée le connecteur python `pg_conn.py`
- Teste le fonctionnement de dbt, de la connexion Postgres depuis Python, de l'exécution de commandes dbt depuis Python

# Installation
### Sous Windows
1. Créer un **environnement virtuel** dans un nouveau répertoire
2. **Cloner le repo** dans le répertoire
2. Enregistrer `.env.template` comme `.env` **PUIS** renseigner les variables
3. Ouvrir un nouveau terminal et vérifer le bon chargement des variables d'environnement
3. Mettre à jour `install/requirements.txt` si nécessaire 
4. Placé dans `install/` exécuter : `.\install.bat --dbt-setup`
### Sous Linux