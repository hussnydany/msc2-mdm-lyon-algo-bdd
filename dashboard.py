"""
Dashboard Marketing — E-Commerce Retail
Projet Final Algo & BDD 2026
-----------------------------------------
Dashboard Plotly/Dash interactif avec :
- 5 KPIs
- 6 graphiques
- 2 Dropdowns + 1 Slider
- 1 Callback principal
"""

import os
import mysql.connector
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from dash import Dash, html, dcc, Input, Output, callback
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "user":     os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME",     "ecommerce_marketing"),
}

# ── Palette couleurs ──────────────────────────────────────────────────────────
COLORS = {
    "Champions": "#6C63FF",
    "Fideles":   "#3ECFCF",
    "Potentiel": "#F7B731",
    "A_risque":  "#FC5C65",
    "Endormi":   "#A0AEC0",
}
BG      = "#0F0F1A"
CARD_BG = "#1A1A2E"
TEXT    = "#E2E8F0"
ACCENT  = "#6C63FF"


# ══════════════════════════════════════════════════════════════════════════════
# CHARGEMENT DES DONNÉES
# ══════════════════════════════════════════════════════════════════════════════

def load_data():
    """Charge toutes les données nécessaires au dashboard depuis MySQL."""
    conn = mysql.connector.connect(**DB_CONFIG)

    rfm = pd.read_sql("""
        SELECT r.*, cl.nom, cl.ville, cl.pays, cl.devise
        FROM rfm_segments r
        JOIN clients cl ON r.client_id = cl.client_id
    """, conn)

    commandes = pd.read_sql("""
        SELECT c.*, cl.pays
        FROM commandes c
        JOIN clients cl ON c.client_id = cl.client_id
        WHERE c.statut = 'livree'
    """, conn)
    commandes["date_commande"] = pd.to_datetime(commandes["date_commande"])

    campagnes = pd.read_sql("""
        SELECT cam.nom AS campagne, cam.type_campagne,
               ROUND(AVG(cc.ouvert)   * 100, 1) AS taux_ouverture,
               ROUND(AVG(cc.clique)   * 100, 1) AS taux_clic,
               ROUND(AVG(cc.converti) * 100, 1) AS taux_conversion
        FROM campagnes cam
        JOIN campagnes_clients cc ON cam.campagne_id = cc.campagne_id
        GROUP BY cam.campagne_id, cam.nom, cam.type_campagne
    """, conn)

    ca_cat = pd.read_sql("""
        SELECT cat.nom AS categorie,
               ROUND(SUM(lc.quantite * lc.prix_unitaire), 2) AS ca_total
        FROM lignes_commande lc
        JOIN produits p     ON lc.produit_id   = p.produit_id
        JOIN categories cat ON p.categorie_id  = cat.categorie_id
        JOIN commandes c    ON lc.commande_id  = c.commande_id
        WHERE c.statut = 'livree'
        GROUP BY cat.nom
        ORDER BY ca_total DESC
    """, conn)

    conn.close()
    return rfm, commandes, campagnes, ca_cat


rfm_df, commandes_df, campagnes_df, ca_cat_df = load_data()


# ══════════════════════════════════════════════════════════════════════════════
# APP DASH
# ══════════════════════════════════════════════════════════════════════════════

app = Dash(__name__, title="E-Commerce RFM Dashboard")

# ── Options dropdown ──────────────────────────────────────────────────────────
segment_options = [{"label": "Tous les segments", "value": "ALL"}] + [
    {"label": s, "value": s} for s in ["Champions", "Fideles", "Potentiel", "A_risque", "Endormi"]
]
pays_options = [{"label": "Tous les pays", "value": "ALL"}] + [
    {"label": p, "value": p} for p in sorted(rfm_df["pays"].dropna().unique())
]


def kpi_card(title: str, value: str, subtitle: str = "") -> html.Div:
    """Composant KPI réutilisable."""
    return html.Div([
        html.P(title, style={"color": "#94A3B8", "fontSize": "12px",
                              "marginBottom": "4px", "textTransform": "uppercase",
                              "letterSpacing": "1px"}),
        html.H2(value, style={"color": TEXT, "fontSize": "28px",
                               "margin": "0", "fontWeight": "700"}),
        html.P(subtitle, style={"color": "#64748B", "fontSize": "11px",
                                 "marginTop": "4px"}) if subtitle else None,
    ], style={"background": CARD_BG, "borderRadius": "12px", "padding": "20px 24px",
               "borderLeft": f"3px solid {ACCENT}", "flex": "1", "minWidth": "160px"})


# ── Layout ────────────────────────────────────────────────────────────────────
app.layout = html.Div([

    # Header
    html.Div([
        html.H1("🛍️ E-Commerce RFM Dashboard",
                style={"color": TEXT, "margin": "0", "fontSize": "26px", "fontWeight": "700"}),
        html.P("Analyse marketing · Algo & BDD 2026",
               style={"color": "#64748B", "margin": "4px 0 0 0", "fontSize": "13px"}),
    ], style={"padding": "24px 32px", "borderBottom": f"1px solid #1E293B"}),

    # Filtres
    html.Div([
        html.Div([
            html.Label("Segment RFM", style={"color": "#94A3B8", "fontSize": "12px",
                                              "textTransform": "uppercase", "letterSpacing": "1px"}),
            dcc.Dropdown(id="dd-segment", options=segment_options, value="ALL",
                         clearable=False,
                         style={"background": CARD_BG, "color": "#0F0F1A", "minWidth": "220px"}),
        ], style={"display": "flex", "flexDirection": "column", "gap": "6px"}),

        html.Div([
            html.Label("Pays", style={"color": "#94A3B8", "fontSize": "12px",
                                       "textTransform": "uppercase", "letterSpacing": "1px"}),
            dcc.Dropdown(id="dd-pays", options=pays_options, value="ALL",
                         clearable=False,
                         style={"background": CARD_BG, "color": "#0F0F1A", "minWidth": "200px"}),
        ], style={"display": "flex", "flexDirection": "column", "gap": "6px"}),

        html.Div([
            html.Label(id="slider-label", style={"color": "#94A3B8", "fontSize": "12px",
                                                   "textTransform": "uppercase", "letterSpacing": "1px"}),
            dcc.Slider(id="sl-score", min=3, max=15, step=1, value=3,
                       marks={i: str(i) for i in range(3, 16)},
                       tooltip={"placement": "bottom"}),
        ], style={"flex": "1", "minWidth": "280px", "display": "flex",
                   "flexDirection": "column", "gap": "8px"}),

    ], style={"display": "flex", "gap": "24px", "padding": "20px 32px",
               "background": "#0D0D1A", "alignItems": "flex-end", "flexWrap": "wrap"}),

    # KPIs
    html.Div(id="kpi-row",
             style={"display": "flex", "gap": "16px", "padding": "20px 32px", "flexWrap": "wrap"}),

    # Graphiques ligne 1
    html.Div([
        dcc.Graph(id="graph-segments",   style={"flex": "1", "minWidth": "280px"}),
        dcc.Graph(id="graph-ca-mois",    style={"flex": "2", "minWidth": "400px"}),
    ], style={"display": "flex", "gap": "16px", "padding": "0 32px 16px"}),

    # Graphiques ligne 2
    html.Div([
        dcc.Graph(id="graph-ca-pays",    style={"flex": "1", "minWidth": "300px"}),
        dcc.Graph(id="graph-scatter",    style={"flex": "2", "minWidth": "400px"}),
    ], style={"display": "flex", "gap": "16px", "padding": "0 32px 16px"}),

    # Graphiques ligne 3
    html.Div([
        dcc.Graph(id="graph-ca-cat",     style={"flex": "1", "minWidth": "300px"}),
        dcc.Graph(id="graph-campagnes",  style={"flex": "2", "minWidth": "400px"}),
    ], style={"display": "flex", "gap": "16px", "padding": "0 32px 32px"}),

], style={"background": BG, "minHeight": "100vh", "fontFamily": "system-ui, sans-serif"})


# ══════════════════════════════════════════════════════════════════════════════
# CALLBACK PRINCIPAL
# ══════════════════════════════════════════════════════════════════════════════

@app.callback(
    Output("kpi-row",         "children"),
    Output("graph-segments",  "figure"),
    Output("graph-ca-mois",   "figure"),
    Output("graph-ca-pays",   "figure"),
    Output("graph-scatter",   "figure"),
    Output("graph-ca-cat",    "figure"),
    Output("graph-campagnes", "figure"),
    Output("slider-label",    "children"),
    Input("dd-segment",  "value"),
    Input("dd-pays",     "value"),
    Input("sl-score",    "value"),
)
def update_dashboard(segment_filter, pays_filter, score_min):
    """
    Callback principal — met à jour les 5 KPIs + 6 graphiques
    en fonction des 3 filtres (segment, pays, score minimum).
    """
    # ── Filtrage RFM ──────────────────────────────────────────────────────────
    filtered = rfm_df.copy()
    if segment_filter != "ALL":
        filtered = filtered[filtered["segment"] == segment_filter]
    if pays_filter != "ALL":
        filtered = filtered[filtered["pays"] == pays_filter]
    filtered = filtered[filtered["score_total"] >= score_min]

    # ── Filtrage commandes cohérent ───────────────────────────────────────────
    client_ids = filtered["client_id"].tolist()
    cmd = commandes_df[commandes_df["client_id"].isin(client_ids)]

    # ── KPIs ──────────────────────────────────────────────────────────────────
    nb_clients    = len(filtered)
    ca_total      = filtered["montant_eur"].sum() if "montant_eur" in filtered else filtered["montant_total"].sum()
    panier_moyen  = (cmd["montant_total"].sum() / max(len(cmd), 1))
    nb_champions  = (filtered["segment"] == "Champions").sum()
    recence_moy   = filtered["recence_j"].mean() if len(filtered) else 0

    kpis = html.Div([
        kpi_card("Clients",         f"{nb_clients}",              "après filtres"),
        kpi_card("CA total (EUR)",  f"{ca_total:,.0f} €",         "montant_eur converti"),
        kpi_card("Panier moyen",    f"{panier_moyen:,.2f} €",     "par commande"),
        kpi_card("Champions",       f"{nb_champions}",            f"sur {nb_clients} clients"),
        kpi_card("Récence moy.",    f"{recence_moy:.0f} j",       "depuis dernière commande"),
    ], style={"display": "flex", "gap": "16px", "flexWrap": "wrap", "width": "100%"})

    chart_layout = dict(
        paper_bgcolor="rgba(0,0,0,0)",
        plot_bgcolor="rgba(0,0,0,0)",
        font_color=TEXT,
        margin=dict(l=20, r=20, t=40, b=20),
    )

    # ── 1. Pie — Segments ─────────────────────────────────────────────────────
    seg_count = filtered["segment"].value_counts().reset_index()
    seg_count.columns = ["segment", "count"]
    fig_pie = px.pie(seg_count, values="count", names="segment",
                     title="Répartition des segments",
                     color="segment",
                     color_discrete_map=COLORS,
                     hole=0.4)
    fig_pie.update_layout(**chart_layout)
    fig_pie.update_traces(textfont_color=TEXT)

    # ── 2. Area — CA mensuel ──────────────────────────────────────────────────
    if len(cmd):
        cmd_monthly = cmd.copy()
        cmd_monthly["mois"] = cmd_monthly["date_commande"].dt.to_period("M").astype(str)
        ca_mois = cmd_monthly.groupby("mois")["montant_total"].sum().reset_index()
        ca_mois.columns = ["mois", "ca"]
        fig_area = px.area(ca_mois, x="mois", y="ca",
                           title="Évolution du CA mensuel",
                           color_discrete_sequence=[ACCENT])
        fig_area.update_layout(**chart_layout,
                                xaxis=dict(tickangle=45),
                                yaxis_title="CA (€)")
    else:
        fig_area = go.Figure()
        fig_area.update_layout(title="Évolution du CA mensuel (aucune donnée)", **chart_layout)

    # ── 3. Bar — CA par pays ──────────────────────────────────────────────────
    ca_pays = filtered.groupby("pays")["montant_eur"].sum().reset_index()
    ca_pays = ca_pays.sort_values("montant_eur", ascending=False).head(10)
    fig_pays = px.bar(ca_pays, x="pays", y="montant_eur",
                      title="Top 10 pays — CA en EUR",
                      color_discrete_sequence=[ACCENT])
    fig_pays.update_layout(**chart_layout, yaxis_title="CA (€)")

    # ── 4. Scatter — RFM bubble ───────────────────────────────────────────────
    fig_scatter = px.scatter(filtered, x="recence_j", y="frequence",
                              size="montant_eur",
                              color="segment",
                              color_discrete_map=COLORS,
                              hover_name="nom",
                              title="Carte RFM : Récence vs Fréquence",
                              labels={"recence_j": "Récence (jours)",
                                      "frequence": "Fréquence (commandes)",
                                      "montant_eur": "CA (EUR)"},
                              size_max=40)
    fig_scatter.update_layout(**chart_layout)

    # ── 5. Bar — CA par catégorie ─────────────────────────────────────────────
    fig_cat = px.bar(ca_cat_df, x="ca_total", y="categorie",
                     orientation="h",
                     title="CA par catégorie de produit",
                     color_discrete_sequence=["#3ECFCF"])
    fig_cat.update_layout(**chart_layout, xaxis_title="CA (€)")

    # ── 6. Bar groupé — Performance campagnes ────────────────────────────────
    camp_melt = campagnes_df.melt(
        id_vars=["campagne", "type_campagne"],
        value_vars=["taux_ouverture", "taux_clic", "taux_conversion"],
        var_name="indicateur", value_name="taux"
    )
    camp_melt["indicateur"] = camp_melt["indicateur"].map({
        "taux_ouverture":   "Ouverture",
        "taux_clic":        "Clic",
        "taux_conversion":  "Conversion",
    })
    fig_camp = px.bar(camp_melt, x="campagne", y="taux",
                      color="indicateur",
                      barmode="group",
                      title="Performance des campagnes marketing (%)",
                      color_discrete_sequence=[ACCENT, "#3ECFCF", "#F7B731"])
    fig_camp.update_layout(**chart_layout, yaxis_title="Taux (%)")

    slider_label = f"Score RFM minimum : {score_min}"

    return kpis, fig_pie, fig_area, fig_pays, fig_scatter, fig_cat, fig_camp, slider_label


if __name__ == "__main__":
    app.run(debug=True, port=8050)
