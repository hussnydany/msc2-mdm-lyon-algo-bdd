# Algo & BDD - Séances 3 et 4

## Mise en place

1. Ouvrir VS Code et se connecter à MySQL via Database Client
2. Avoir la base `spotifaille` (fichier `bdd/spotifaille.sql`)
3. Avoir la base `rfm-ecommerce` (fichier `bdd/rfm-ecommerce.sql`)

## S3 - SQL

Fichiers à exécuter dans l'ordre (dossier `requetes/`) :

| Fichier                    | Contenu                                                            |
| -------------------------- | ------------------------------------------------------------------ |
| `inspect.sql`              | SHOW TABLES, DESCRIBE, SHOW CREATE TABLE, INFORMATION_SCHEMA       |
| `ddl.sql`                  | CREATE TABLE (playlists, playlist_titres), ALTER TABLE, DROP TABLE |
| `update-delete.sql`        | UPDATE, DELETE (règle : SELECT avant, jamais sans WHERE)           |
| `sous-requetes.sql`        | IN, NOT IN, comparaison, sous-requête dans FROM                    |
| `cte.sql`                  | WITH ... AS, enchaînement de CTE                                   |
| `fonctions-procedures.sql` | CREATE FUNCTION, CREATE PROCEDURE, CALL                            |
| `views.sql`                | CREATE VIEW, DROP VIEW, vue profil clients                         |
| `rfm.sql`                  | Algorithme RFM étape par étape, CASE WHEN, vue RFM                 |

## S4 - Pipeline Python-SQL

### Prérequis

```bash
pip install mysql-connector-python requests matplotlib pandas dash plotly
```

### Fichiers (dossier `python/`)

| Fichier        | Contenu                                                                               |
| -------------- | ------------------------------------------------------------------------------------- |
| `pipeline.py`  | Pipeline complet : connexion, extraction, API geocoding, matplotlib, écriture en base |
| `dashboard.py` | Dashboard Dash/Plotly : métriques, graphiques, tableau filtrable, carte               |

### Lancement

1. Exécuter d'abord `bdd/rfm-ecommerce.sql` dans VS Code
2. Exécuter le pipeline : `python python/pipeline.py`
3. Lancer le dashboard : `python python/dashboard.py` puis ouvrir http://127.0.0.1:8050

### Mot de passe MySQL

Dans les fichiers Python, remplacer `<VOTRE_MOT_DE_PASSE>` par votre mot de passe MySQL.
