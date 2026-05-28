# 🛏️ La Literie Idéale – Segmentation RFM & Dashboard Data Marketing

> Projet Final – Algo & BDD | MSc2 Manager Data Marketing | INSEEC 2026

---

## 📌 Problématique

**Comment segmenter les clients de La Literie Idéale selon leur comportement d'achat pour optimiser les campagnes marketing ?**

La Literie Idéale est une enseigne lyonnaise spécialisée dans la vente de literie haut de gamme, avec 4 points de vente sur la métropole de Lyon. L'entreprise dispose d'un historique de données clients et de commandes inexploité. Ce projet construit un pipeline data complet : base SQL → analyse RFM en Python → dashboard interactif.

---

## 🗂️ Structure du projet

```
literie-ideale-rfm/
│
├── literie_ideale.sql       # Création BDD, tables, données et requêtes SQL
├── rfm_pipeline.py          # Pipeline Python : connexion, RFM, API, écriture BDD
├── dashboard.py             # Dashboard interactif Plotly Dash
├── .env.example             # Template des variables d'environnement
├── .gitignore               # Exclut .env du repo
└── README.md
```

---

## 🗄️ Schéma de la base de données

![Schéma BDD](schema_dbdiagram.png)

### Tables
| Table | Description |
|---|---|
| `magasins` | 4 points de vente de La Literie Idéale |
| `clients` | 200 clients fictifs de la métropole lyonnaise |
| `produits` | 20 produits (matelas, sommiers, accessoires…) |
| `commandes` | 541 commandes sur 2023–2025 |
| `commandes_produits` | Table de liaison many-to-many |
| `clients_rfm` | Résultats RFM enrichis, générés par le pipeline Python |

---

## ⚙️ Installation

### Prérequis
- Python 3.9+
- MySQL 8+

### 1. Cloner le repo
```bash
git clone https://github.com/ton-username/literie-ideale-rfm.git
cd literie-ideale-rfm
```

### 2. Installer les dépendances
```bash
pip install mysql-connector-python pandas requests python-dotenv dash plotly
```

### 3. Configurer l'environnement
```bash
cp .env.example .env
# Remplir .env avec tes identifiants MySQL
```

### 4. Créer la base de données
```bash
mysql -u root -p < literie_ideale.sql
```

### 5. Lancer le pipeline RFM
```bash
python rfm_pipeline.py
```

### 6. Lancer le dashboard
```bash
python dashboard.py
# Ouvrir http://127.0.0.1:8050
```

---

## 🧠 Algorithme RFM

| Dimension | Description | Score |
|---|---|---|
| **Récence** | Nb de jours depuis le dernier achat | 1 (ancien) → 3 (récent) |
| **Fréquence** | Nb total de commandes | 1 (rare) → 3 (fréquent) |
| **Montant** | CA total généré | 1 (faible) → 3 (élevé) |

**Score RFM = Score R + Score F + Score M** (de 3 à 9)

### Segments
| Segment | Critères |
|---|---|
| ⭐ **VIP** | Score ≥ 8 |
| 💚 **Fidèle** | Score ≥ 6 et récence ≥ 2 |
| ⚠️ **À risque** | Score ≥ 6 mais récence faible |
| 🔵 **Occasionnel** | Score 4–5 |
| 💤 **Dormant** | Score ≤ 3 |

---

## 🌍 API Géolocalisation

Utilisation de l'API **adresse.data.gouv.fr** (gratuite, sans clé) pour enrichir les clients avec leurs coordonnées GPS (latitude/longitude) à partir de leur adresse postale.

```
GET https://api-adresse.data.gouv.fr/search/?q=12+rue+de+la+Republique+69001+Lyon&limit=1
```

---

## 📊 Dashboard

Le dashboard Plotly Dash propose :

- **5 KPIs** : nombre de clients, CA total, CA moyen, % VIP, fréquence moyenne
- **Camembert** : répartition des segments
- **Barres** : CA moyen par segment
- **Courbe** : évolution du CA mensuel
- **Top 10 produits** vendus
- **Scatter plot** : fréquence vs montant par segment
- **3 filtres interactifs** : magasin, segment, montant minimum

---

## 🛠️ Stack technique

| Outil | Usage |
|---|---|
| MySQL | Base de données relationnelle |
| Python / Pandas | Manipulation et analyse des données |
| Plotly Dash | Dashboard interactif |
| api-adresse.data.gouv.fr | Enrichissement géolocalisation |
| dbdiagram.io | Modélisation du schéma |
| GitHub | Versioning et rendu |

---

*Projet réalisé dans le cadre du MSc2 Manager Data Marketing – INSEEC 2026*
