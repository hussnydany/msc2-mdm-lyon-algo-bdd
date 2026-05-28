"""
Pipeline Marketing - E-Commerce Retail
Projet Final Algo & BDD 2026
-----------------------------------------
1. Connexion MySQL
2. Extraction & manipulation Pandas
3. Appel API externe (Frankfurter — taux de change par devise)
4. Algorithme RFM e-commerce (Récence · Fréquence · Montant)
5. Écriture des résultats en base
"""

import os
import mysql.connector
import pandas as pd
import requests
from datetime import date
from dotenv import load_dotenv

# ── Chargement variables d'environnement ──────────────────────────────────────
load_dotenv()

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "user":     os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME",     "ecommerce_marketing"),
}

DATE_REF = date(2026, 4, 1)   # date de référence pour le calcul RFM


# ══════════════════════════════════════════════════════════════════════════════
# 1. CONNEXION ET EXTRACTION
# ══════════════════════════════════════════════════════════════════════════════

def get_connection():
    """Retourne une connexion MySQL active."""
    conn = mysql.connector.connect(**DB_CONFIG)
    print("✅ Connexion MySQL établie")
    return conn


def extract_commandes(conn) -> pd.DataFrame:
    """
    Charge toutes les commandes livrées avec infos client depuis MySQL.

    Returns
    -------
    pd.DataFrame : colonnes client_id, nom, ville, pays, devise,
                   date_commande, montant_total
    """
    query = """
        SELECT
            c.client_id,
            cl.nom,
            cl.ville,
            cl.pays,
            cl.devise,
            c.date_commande,
            c.montant_total
        FROM commandes c
        JOIN clients cl ON c.client_id = cl.client_id
        WHERE c.statut = 'livree'
    """
    df = pd.read_sql(query, conn)
    df["date_commande"] = pd.to_datetime(df["date_commande"])
    print(f"📦 {len(df)} commandes chargées pour {df['client_id'].nunique()} clients")
    return df


# ══════════════════════════════════════════════════════════════════════════════
# 2. ALGORITHME RFM (Récence · Fréquence · Montant)
# ══════════════════════════════════════════════════════════════════════════════

def score_rfm(value: float, thresholds: list, reverse: bool = False) -> int:
    """
    Attribue un score de 1 à 5 selon des seuils.
    reverse=True : plus la valeur est basse, meilleur est le score (ex: récence).

    Params
    ------
    value      : valeur à scorer
    thresholds : liste de 4 seuils [t1, t2, t3, t4]
    reverse    : inverser le sens du score

    Returns
    -------
    int : score entre 1 et 5
    """
    t1, t2, t3, t4 = thresholds
    if not reverse:
        if   value >= t4: return 5
        elif value >= t3: return 4
        elif value >= t2: return 3
        elif value >= t1: return 2
        else:             return 1
    else:
        if   value <= t1: return 5
        elif value <= t2: return 4
        elif value <= t3: return 3
        elif value <= t4: return 2
        else:             return 1


def compute_rfm(df: pd.DataFrame) -> pd.DataFrame:
    """
    Calcule les métriques RFM par client et attribue les scores + segments.

    Métriques e-commerce
    --------------------
    - Récence  : jours depuis la dernière commande
    - Fréquence: nombre de commandes livrées
    - Montant  : chiffre d'affaires total généré (en devise locale)

    Returns
    -------
    pd.DataFrame : une ligne par client avec métriques, scores et segment
    """
    # ── Métriques brutes ──────────────────────────────────────────────────────
    rfm = df.groupby("client_id").agg(
        nom           = ("nom",           "first"),
        ville         = ("ville",         "first"),
        pays          = ("pays",          "first"),
        devise        = ("devise",        "first"),
        last_order    = ("date_commande", "max"),
        frequence     = ("client_id",     "count"),
        montant_total = ("montant_total", "sum"),
    ).reset_index()

    rfm["recence_j"]     = (pd.Timestamp(DATE_REF) - rfm["last_order"]).dt.days
    rfm["montant_total"] = rfm["montant_total"].round(2)

    # ── Scoring (seuils calibrés sur le jeu de données retail) ───────────────
    rfm["score_r"] = rfm["recence_j"].apply(
        lambda x: score_rfm(x, [14, 30, 90, 180], reverse=True)
    )
    rfm["score_f"] = rfm["frequence"].apply(
        lambda x: score_rfm(x, [2, 3, 5, 7])
    )
    rfm["score_m"] = rfm["montant_total"].apply(
        lambda x: score_rfm(x, [50, 200, 500, 1000])
    )
    rfm["score_total"] = rfm["score_r"] + rfm["score_f"] + rfm["score_m"]

    # ── Segmentation ──────────────────────────────────────────────────────────
    def segment(score: int) -> str:
        if   score >= 13: return "Champions"
        elif score >= 10: return "Fideles"
        elif score >= 7:  return "Potentiel"
        elif score >= 4:  return "A_risque"
        else:             return "Endormi"

    rfm["segment"]     = rfm["score_total"].apply(segment)
    rfm["date_calcul"] = DATE_REF.isoformat()

    print("\n📊 Distribution des segments :")
    print(rfm["segment"].value_counts().to_string())
    return rfm


# ══════════════════════════════════════════════════════════════════════════════
# 3. ENRICHISSEMENT API EXTERNE — Frankfurter (taux de change en EUR)
# ══════════════════════════════════════════════════════════════════════════════
# API gratuite, sans clé : https://www.frankfurter.app

def fetch_exchange_rates(devises: list) -> dict:
    """
    Appelle l'API Frankfurter pour récupérer les taux de change vers EUR.

    Params
    ------
    devises : liste de codes devise (ex: ['USD', 'GBP', 'JPY'])

    Returns
    -------
    dict : {devise: taux_vers_EUR}  — EUR → EUR vaut toujours 1.0
    """
    rates = {"EUR": 1.0}

    # Devises à récupérer (on exclut EUR)
    to_fetch = [d for d in devises if d != "EUR"]
    if not to_fetch:
        return rates

    symbols = ",".join(set(to_fetch))
    url = f"https://api.frankfurter.app/latest?from=EUR&to={symbols}"

    try:
        resp = requests.get(url, timeout=8)
        resp.raise_for_status()
        data = resp.json()
        # L'API renvoie les taux EUR → devise ; on inverse pour avoir devise → EUR
        for devise, taux_eur_vers_devise in data.get("rates", {}).items():
            rates[devise] = round(1 / taux_eur_vers_devise, 6)
        print(f"✅ Taux récupérés pour : {list(rates.keys())}")
    except Exception as exc:
        print(f"⚠️  API Frankfurter indisponible : {exc}")
        print("   → Les montants en EUR resteront NULL")

    return rates


def enrich_currency(rfm: pd.DataFrame) -> pd.DataFrame:
    """
    Ajoute les colonnes taux_change et montant_eur au DataFrame RFM.
    Permet de comparer les montants dépensés sur une base commune (EUR).

    Returns
    -------
    pd.DataFrame : rfm enrichi avec taux_change et montant_eur
    """
    devises_uniques = rfm["devise"].dropna().unique().tolist()
    print(f"\n💱 Appel API taux de change pour {len(devises_uniques)} devises…")

    rates = fetch_exchange_rates(devises_uniques)

    rfm["taux_change"] = rfm["devise"].map(rates)
    rfm["montant_eur"] = (rfm["montant_total"] * rfm["taux_change"]).round(2)

    print("✅ Enrichissement devise terminé")
    return rfm


# ══════════════════════════════════════════════════════════════════════════════
# 4. ÉCRITURE EN BASE — table rfm_segments
# ══════════════════════════════════════════════════════════════════════════════

def write_rfm_to_db(conn, rfm: pd.DataFrame) -> None:
    """
    Écrit (ou met à jour) les résultats RFM dans la table rfm_segments.
    Utilise INSERT … ON DUPLICATE KEY UPDATE pour les ré-exécutions idempotentes.

    Params
    ------
    conn : connexion MySQL active
    rfm  : DataFrame RFM enrichi
    """
    cursor = conn.cursor()

    upsert_sql = """
        INSERT INTO rfm_segments
            (client_id, recence_j, frequence, montant_total,
             score_r, score_f, score_m, score_total, segment,
             date_calcul, taux_change, montant_eur)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            recence_j     = VALUES(recence_j),
            frequence     = VALUES(frequence),
            montant_total = VALUES(montant_total),
            score_r       = VALUES(score_r),
            score_f       = VALUES(score_f),
            score_m       = VALUES(score_m),
            score_total   = VALUES(score_total),
            segment       = VALUES(segment),
            date_calcul   = VALUES(date_calcul),
            taux_change   = VALUES(taux_change),
            montant_eur   = VALUES(montant_eur)
    """

    rows = [
        (
            int(row.client_id),
            int(row.recence_j),
            int(row.frequence),
            float(row.montant_total),
            int(row.score_r),
            int(row.score_f),
            int(row.score_m),
            int(row.score_total),
            row.segment,
            row.date_calcul,
            float(row.taux_change) if pd.notna(row.taux_change) else None,
            float(row.montant_eur) if pd.notna(row.montant_eur) else None,
        )
        for row in rfm.itertuples(index=False)
    ]

    cursor.executemany(upsert_sql, rows)
    conn.commit()
    cursor.close()
    print(f"\n💾 {len(rows)} lignes écrites dans rfm_segments")


# ══════════════════════════════════════════════════════════════════════════════
# 5. MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    print("=" * 55)
    print("  PIPELINE E-COMMERCE MARKETING — Algo & BDD 2026")
    print("=" * 55)

    conn = get_connection()

    # Extraction
    df_commandes = extract_commandes(conn)

    # RFM
    rfm = compute_rfm(df_commandes)

    # Enrichissement taux de change (API Frankfurter)
    rfm = enrich_currency(rfm)

    # Aperçu console
    cols = ["client_id", "nom", "devise", "recence_j", "frequence",
            "montant_total", "taux_change", "montant_eur",
            "score_total", "segment"]
    print("\n📋 Aperçu RFM enrichi :")
    print(rfm[cols].to_string(index=False))

    # Écriture en base
    write_rfm_to_db(conn, rfm)

    conn.close()
    print("\n✅ Pipeline terminé avec succès.")


if __name__ == "__main__":
    main()
