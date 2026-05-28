# 🛍️ E-Commerce Marketing — Analyse RFM

> **Projet Final — Algo & BDD 2026**  
> MSc2 Manager Data Marketing · INSEEC  

---

## Problématique métier

Un site de vente en ligne multi-pays veut **segmenter sa base clients** pour personnaliser ses campagnes marketing et optimiser son chiffre d'affaires.

**Questions clés :**
- Qui sont les clients les plus rentables (Champions) ?
- Quels clients risquent de ne plus acheter (churn) ?
- Quelle est la performance réelle des campagnes par segment ?
- Comment comparer les CA de clients achetant dans des devises différentes (EUR, USD, GBP, JPY…) ?

**Solution :** Un pipeline complet SQL → Python → Dashboard avec un algorithme RFM e-commerce et une API de taux de change pour normaliser les montants en EUR.

---

## Schéma de la base de données

> Schéma généré sur [dbdiagram.io](https://dbdiagram.io) — code source dans `bdd/schema_dbdiagram.dbml`

```
┌────────────┐     ┌──────────────────┐     ┌────────────┐
│  clients   │────<│  campagnes_      │>────│ campagnes  │
│ (35 lignes)│     │  clients (M2M)   │     │ (5 lignes) │
└─────┬──────┘     └──────────────────┘     └────────────┘
      │
      ├──────────< commandes >───< lignes_commande >──── produits ──── categories
      │           (70+ lignes)    (many-to-many)        (20 lignes)    (5 lignes)
      │
      ├──────────< avis >─────── produits
      │
      └──────────  rfm_segments
                   (résultats pipeline Python)
```

**8 tables** | **2 many-to-many** | **FOREIGN KEY** sur toutes les jointures | **UNIQUE** sur email + client_id RFM | **NOT NULL** sur champs critiques

---

## Structure du projet

```
ecommerce_marketing/
│
├── bdd/
│   ├── ecommerce.sql             ← Création BDD, tables, données, requêtes, vues, fonctions
│   └── schema_dbdiagram.dbml     ← Code pour dbdiagram.io (schéma visuel)
│
├── python/
│   ├── pipeline.py               ← Connexion MySQL, RFM, API taux de change, écriture en base
│   └── dashboard.py              ← Dashboard Dash/Plotly interactif
│
├── requirements.txt              ← Dépendances Python
├── .env.example                  ← Template variables d'environnement
├── .gitignore                    ← .env exclu du repo (mot de passe protégé)
└── README.md
```

---

## Installation et lancement

### Prérequis
- Python 3.10+
- MySQL 8.0+
- VS Code + extension Database Client

### 1. Cloner le repo
```bash
git clone https://github.com/<TON_USERNAME>/ecommerce-marketing.git
cd ecommerce-marketing
```

### 2. Installer les dépendances Python
```bash
pip install -r requirements.txt
```

### 3. Configurer les variables d'environnement
```bash
cp .env.example .env
# Éditer .env et remplacer ton_mot_de_passe_ici par ton mot de passe MySQL
```

### 4. Créer la base de données
```bash
# Dans VS Code via Database Client, ouvrir et exécuter :
bdd/ecommerce.sql
```

### 5. Lancer le pipeline Python
```bash
python python/pipeline.py
```
Le pipeline :
- Se connecte à MySQL
- Calcule les scores RFM pour chaque client (Récence + Fréquence + Montant)
- Appelle l'API **Frankfurter** pour convertir les montants en EUR selon la devise du client
- Écrit les résultats dans la table `rfm_segments`

### 6. Lancer le dashboard
```bash
python python/dashboard.py
# Ouvrir http://127.0.0.1:8050
```

---

## Cahier des charges technique — Checklist

### Partie 1 : Modélisation et base de données

| Critère | Fichier | Détail |
|---------|---------|--------|
| ✅ Schéma dbdiagram.io (≥3 tables avec relations) | `bdd/schema_dbdiagram.dbml` | 8 tables, schéma sur dbdiagram.io |
| ✅ Au moins une relation many-to-many | `bdd/ecommerce.sql` | `lignes_commande` (commandes↔produits) + `campagnes_clients` (clients↔campagnes) |
| ✅ Fichier SQL (CREATE + INSERT) | `bdd/ecommerce.sql` | 35 clients, 20 produits, 70+ commandes |
| ✅ Contrainte FOREIGN KEY | `bdd/ecommerce.sql` | Sur toutes les tables de jointure |
| ✅ Contrainte NOT NULL et UNIQUE | `bdd/ecommerce.sql` | `email UNIQUE NOT NULL`, `client_id UNIQUE` dans rfm_segments |
| ✅ 5 requêtes SELECT (WHERE, GROUP BY, HAVING, ORDER BY, LIMIT) | `bdd/ecommerce.sql` | 6 requêtes commentées |
| ✅ Jointure sur 3 tables ou plus | `bdd/ecommerce.sql` | Requête 1 : lignes_commande + produits + categories + commandes |
| ✅ Sous-requête | `bdd/ecommerce.sql` | Requête 4 : `NOT IN (SELECT DISTINCT ...)` |
| ✅ CTE (WITH … AS) | `bdd/ecommerce.sql` | CTE double : `derniere_commande` + `stats_client` |
| ✅ Vue (CREATE VIEW) | `bdd/ecommerce.sql` | `vue_profil_client` |
| ✅ Fonction stockée | `bdd/ecommerce.sql` | `get_rfm_segment(score INT)` |
| ✅ Procédure stockée | `bdd/ecommerce.sql` | `resume_pays(p_pays VARCHAR)` |

### Partie 2 : Pipeline Python

| Critère | Fichier | Détail |
|---------|---------|--------|
| ✅ Connexion à la base MySQL | `python/pipeline.py` | `get_connection()` via mysql-connector + .env |
| ✅ Manipulation Pandas | `python/pipeline.py` | `extract_commandes()`, `compute_rfm()` — groupby, calculs, merge |
| ✅ Appel API externe | `python/pipeline.py` | **Frankfurter API** — taux de change multi-devises vers EUR, gratuite, sans clé |
| ✅ Algorithme marketing (RFM) | `python/pipeline.py` | `compute_rfm()` : Récence + Fréquence + Montant, scores 1→5 |
| ✅ Écriture résultats en base | `python/pipeline.py` | `write_rfm_to_db()` → table `rfm_segments` avec UPSERT |
| ✅ Code commenté et structuré | `python/pipeline.py` | Docstrings sur chaque fonction, paramètres typés |

### Partie 3 : Dashboard interactif

| Critère | Fichier | Détail |
|---------|---------|--------|
| ✅ Dashboard Plotly fonctionnel | `python/dashboard.py` | Dash app, port 8050 |
| ✅ Au moins 3 KPIs | `python/dashboard.py` | 5 KPIs : clients, CA EUR, panier moyen, Champions, récence |
| ✅ Au moins 2 graphiques | `python/dashboard.py` | 6 graphiques : pie segments, area CA mensuel, bar pays, scatter RFM, bar catégories, bar campagnes |
| ✅ Filtre interactif | `python/dashboard.py` | 2 Dropdowns (segment, pays) + 1 Slider (score minimum) |
| ✅ Callback | `python/dashboard.py` | `update_dashboard()` — 3 inputs, 8 outputs |

---

## Algorithme RFM e-commerce

L'algorithme est adapté au **retail en ligne** — le Montant remplace l'Engagement :

| Dimension | Définition | Score 5 | Score 1 |
|-----------|-----------|---------|---------|
| **R — Récence** | Jours depuis la dernière commande | ≤ 14 jours | > 180 jours |
| **F — Fréquence** | Nombre de commandes livrées | ≥ 7 commandes | < 2 commandes |
| **M — Montant** | CA total généré | ≥ 1 000 € | < 50 € |

**Score total = R + F + M** (de 3 à 15)

| Segment | Score | Stratégie marketing |
|---------|-------|---------------------|
| **Champions** | ≥ 13 | Programme VIP, ventes privées, early access |
| **Fidèles** | 10–12 | Upsell, cross-sell, programme de fidélité |
| **Potentiel** | 7–9 | Nurturing, offres personnalisées |
| **À risque** | 4–6 | Campagne réactivation, offre spéciale |
| **Endormi** | < 4 | Offre choc ou désengagement assumé |

---

## API externe utilisée

**Frankfurter** — `https://api.frankfurter.app`

- Gratuite, sans clé API, sans inscription
- Retourne les taux de change en temps réel basés sur la BCE
- Utilisée pour convertir les montants clients (USD, GBP, JPY, CAD…) en EUR
- Permet une comparaison équitable du CA entre clients de pays différents

---

## Requête SQL mise en avant

CTE double pour calculer le profil RFM brut par client :

```sql
WITH derniere_commande AS (
    SELECT client_id, MAX(date_commande) AS last_order
    FROM commandes
    WHERE statut = 'livree'
    GROUP BY client_id
),
stats_client AS (
    SELECT client_id,
           COUNT(*)                     AS frequence,
           ROUND(SUM(montant_total), 2) AS montant_total
    FROM commandes
    WHERE statut = 'livree'
    GROUP BY client_id
)
SELECT c.client_id, c.nom, c.devise,
       DATEDIFF('2026-04-01', dc.last_order) AS recence_jours,
       sc.frequence, sc.montant_total
FROM clients c
LEFT JOIN derniere_commande dc ON c.client_id = dc.client_id
LEFT JOIN stats_client      sc ON c.client_id = sc.client_id
WHERE dc.last_order IS NOT NULL
ORDER BY recence_jours;
```

---

## Sécurité — mot de passe MySQL

Le mot de passe MySQL n'est **jamais committé** dans le repo :
- Stocké dans `.env` (non versionné, listé dans `.gitignore`)
- `.env.example` fourni comme template sans valeur sensible
- Les scripts Python lisent la config via `python-dotenv` : `os.getenv("DB_PASSWORD")`
