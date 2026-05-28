# ============================================
# Dashboard RFM - La Literie Idéale
# Projet Algo & BDD - MSc2 Data Marketing
# ============================================
# Dépendances : pip install dash plotly pandas mysql-connector-python python-dotenv

import os
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from dash import Dash, dcc, html, Input, Output
from dotenv import load_dotenv
import mysql.connector

load_dotenv()

# ============================================
# 1. CHARGEMENT DES DONNÉES
# ============================================

def get_connection():
    """Connexion à la base MySQL."""
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "literie_ideale")
    )

def load_dashboard_data():
    """Charge toutes les données nécessaires au dashboard."""
    conn = get_connection()

    # Données RFM + infos clients
    df_rfm = pd.read_sql("""
        SELECT 
            r.id_client,
            c.prenom,
            c.nom,
            c.ville,
            c.code_postal,
            m.nom AS magasin,
            r.recence,
            r.frequence,
            r.montant,
            r.score_r,
            r.score_f,
            r.score_m,
            r.score_rfm,
            r.segment,
            r.latitude,
            r.longitude
        FROM clients_rfm r
        JOIN clients c ON r.id_client = c.id_client
        JOIN magasins m ON c.id_magasin = m.id_magasin
    """, conn)

    # Données commandes par mois
    df_cmd = pd.read_sql("""
        SELECT 
            DATE_FORMAT(date_commande, '%Y-%m') AS mois,
            m.nom AS magasin,
            COUNT(*) AS nb_commandes,
            ROUND(SUM(montant_total), 2) AS ca_mensuel
        FROM commandes cmd
        JOIN magasins m ON cmd.id_magasin = m.id_magasin
        GROUP BY mois, m.nom
        ORDER BY mois
    """, conn)

    # Top produits
    df_produits = pd.read_sql("""
        SELECT 
            p.nom AS produit,
            p.categorie,
            p.marque,
            SUM(cp.quantite) AS total_vendus,
            ROUND(SUM(cp.quantite * p.prix), 2) AS ca_produit
        FROM produits p
        JOIN commandes_produits cp ON p.id_produit = cp.id_produit
        GROUP BY p.id_produit, p.nom, p.categorie, p.marque
        ORDER BY total_vendus DESC
        LIMIT 10
    """, conn)

    conn.close()
    return df_rfm, df_cmd, df_produits

# Chargement au démarrage
df_rfm, df_cmd, df_produits = load_dashboard_data()

# Couleurs par segment
COULEURS_SEGMENTS = {
    "VIP":        "#1a1a2e",
    "Fidèle":     "#16213e",
    "Occasionnel":"#0f3460",
    "À risque":   "#e94560",
    "Dormant":    "#a0a0b0",
}

MAGASINS = ["Tous"] + sorted(df_rfm['magasin'].unique().tolist())
SEGMENTS = ["Tous"] + sorted(df_rfm['segment'].unique().tolist())

# ============================================
# 2. INITIALISATION DE L'APP
# ============================================

app = Dash(__name__)
app.title = "La Literie Idéale – Dashboard RFM"

# ============================================
# 3. LAYOUT
# ============================================

app.layout = html.Div(style={
    'fontFamily': 'Segoe UI, sans-serif',
    'backgroundColor': '#f4f6f9',
    'minHeight': '100vh',
    'padding': '0'
}, children=[

    # Header
    html.Div(style={
        'backgroundColor': '#1a1a2e',
        'color': 'white',
        'padding': '24px 40px',
        'marginBottom': '30px'
    }, children=[
        html.H1("🛏️ La Literie Idéale", style={'margin': 0, 'fontSize': '26px'}),
        html.P("Dashboard Segmentation RFM – MSc2 Data Marketing",
               style={'margin': '4px 0 0 0', 'opacity': 0.7, 'fontSize': '14px'})
    ]),

    # Filtres
    html.Div(style={
        'display': 'flex', 'gap': '30px', 'padding': '0 40px 20px', 'flexWrap': 'wrap'
    }, children=[
        html.Div([
            html.Label("🏪 Magasin", style={'fontWeight': 'bold', 'fontSize': '13px'}),
            dcc.Dropdown(
                id='filtre-magasin',
                options=[{'label': m, 'value': m} for m in MAGASINS],
                value='Tous',
                clearable=False,
                style={'width': '220px', 'marginTop': '6px'}
            )
        ]),
        html.Div([
            html.Label("🎯 Segment RFM", style={'fontWeight': 'bold', 'fontSize': '13px'}),
            dcc.Dropdown(
                id='filtre-segment',
                options=[{'label': s, 'value': s} for s in SEGMENTS],
                value='Tous',
                clearable=False,
                style={'width': '220px', 'marginTop': '6px'}
            )
        ]),
        html.Div([
            html.Label("💰 Montant minimum (€)", style={'fontWeight': 'bold', 'fontSize': '13px'}),
            dcc.Slider(
                id='filtre-montant',
                min=0,
                max=int(df_rfm['montant'].max()),
                step=500,
                value=0,
                marks={0: '0€', 5000: '5k€', 10000: '10k€', 15000: '15k€'},
                tooltip={"placement": "bottom", "always_visible": True}
            )
        ], style={'flex': 1, 'minWidth': '300px'}),
    ]),

    # KPIs
    html.Div(id='kpis', style={
        'display': 'flex', 'gap': '20px', 'padding': '0 40px 30px', 'flexWrap': 'wrap'
    }),

    # Graphiques ligne 1
    html.Div(style={
        'display': 'flex', 'gap': '20px', 'padding': '0 40px 20px', 'flexWrap': 'wrap'
    }, children=[
        html.Div(dcc.Graph(id='graph-segments-pie'),
                 style={'flex': 1, 'minWidth': '300px', 'backgroundColor': 'white',
                        'borderRadius': '12px', 'padding': '10px', 'boxShadow': '0 2px 8px rgba(0,0,0,0.06)'}),
        html.Div(dcc.Graph(id='graph-ca-segment'),
                 style={'flex': 2, 'minWidth': '400px', 'backgroundColor': 'white',
                        'borderRadius': '12px', 'padding': '10px', 'boxShadow': '0 2px 8px rgba(0,0,0,0.06)'}),
    ]),

    # Graphiques ligne 2
    html.Div(style={
        'display': 'flex', 'gap': '20px', 'padding': '0 40px 20px', 'flexWrap': 'wrap'
    }, children=[
        html.Div(dcc.Graph(id='graph-ca-mensuel'),
                 style={'flex': 2, 'minWidth': '400px', 'backgroundColor': 'white',
                        'borderRadius': '12px', 'padding': '10px', 'boxShadow': '0 2px 8px rgba(0,0,0,0.06)'}),
        html.Div(dcc.Graph(id='graph-top-produits'),
                 style={'flex': 1, 'minWidth': '300px', 'backgroundColor': 'white',
                        'borderRadius': '12px', 'padding': '10px', 'boxShadow': '0 2px 8px rgba(0,0,0,0.06)'}),
    ]),

    # Scatter RFM
    html.Div(style={'padding': '0 40px 30px'}, children=[
        html.Div(dcc.Graph(id='graph-rfm-scatter'),
                 style={'backgroundColor': 'white', 'borderRadius': '12px',
                        'padding': '10px', 'boxShadow': '0 2px 8px rgba(0,0,0,0.06)'})
    ]),

    # Footer
    html.Div("La Literie Idéale © 2025 – Dashboard généré avec Plotly Dash",
             style={'textAlign': 'center', 'padding': '20px',
                    'color': '#888', 'fontSize': '12px'})
])


# ============================================
# 4. CALLBACKS
# ============================================

def filtrer_df(magasin, segment, montant_min):
    """Filtre le dataframe RFM selon les critères sélectionnés."""
    df = df_rfm.copy()
    if magasin != 'Tous':
        df = df[df['magasin'] == magasin]
    if segment != 'Tous':
        df = df[df['segment'] == segment]
    df = df[df['montant'] >= montant_min]
    return df


@app.callback(
    Output('kpis', 'children'),
    Output('graph-segments-pie', 'figure'),
    Output('graph-ca-segment', 'figure'),
    Output('graph-rfm-scatter', 'figure'),
    Input('filtre-magasin', 'value'),
    Input('filtre-segment', 'value'),
    Input('filtre-montant', 'value')
)
def update_dashboard(magasin, segment, montant_min):
    df = filtrer_df(magasin, segment, montant_min)

    # --- KPIs ---
    nb_clients = len(df)
    ca_total = df['montant'].sum()
    ca_moyen = df['montant'].mean() if nb_clients > 0 else 0
    pct_vip = (df['segment'] == 'VIP').sum() / nb_clients * 100 if nb_clients > 0 else 0
    freq_moyenne = df['frequence'].mean() if nb_clients > 0 else 0

    def kpi_card(titre, valeur, couleur="#1a1a2e", icone=""):
        return html.Div(style={
            'backgroundColor': couleur, 'color': 'white',
            'borderRadius': '12px', 'padding': '20px 24px',
            'minWidth': '160px', 'flex': 1,
            'boxShadow': '0 2px 8px rgba(0,0,0,0.1)'
        }, children=[
            html.P(f"{icone} {titre}", style={'margin': 0, 'fontSize': '12px', 'opacity': 0.8}),
            html.H2(valeur, style={'margin': '6px 0 0 0', 'fontSize': '24px'})
        ])

    kpis = [
        kpi_card("Clients analysés", f"{nb_clients}", "#1a1a2e", "👥"),
        kpi_card("CA Total", f"{ca_total:,.0f} €", "#0f3460", "💶"),
        kpi_card("CA Moyen / Client", f"{ca_moyen:,.0f} €", "#16213e", "📊"),
        kpi_card("Clients VIP", f"{pct_vip:.1f} %", "#e94560", "⭐"),
        kpi_card("Fréquence Moyenne", f"{freq_moyenne:.1f} cmd", "#444", "🔁"),
    ]

    # --- Camembert segments ---
    seg_counts = df['segment'].value_counts().reset_index()
    seg_counts.columns = ['segment', 'count']
    fig_pie = px.pie(
        seg_counts, names='segment', values='count',
        color='segment', color_discrete_map=COULEURS_SEGMENTS,
        title="Répartition des segments clients",
        hole=0.4
    )
    fig_pie.update_layout(margin=dict(t=50, b=10, l=10, r=10), height=320)

    # --- CA moyen par segment ---
    seg_ca = df.groupby('segment').agg(
        ca_moyen=('montant', 'mean'),
        nb_clients=('id_client', 'count')
    ).reset_index().sort_values('ca_moyen', ascending=False)

    fig_ca = px.bar(
        seg_ca, x='segment', y='ca_moyen',
        color='segment', color_discrete_map=COULEURS_SEGMENTS,
        text='nb_clients',
        title="CA moyen et nombre de clients par segment",
        labels={'ca_moyen': 'CA Moyen (€)', 'segment': 'Segment', 'nb_clients': 'Nb clients'}
    )
    fig_ca.update_traces(texttemplate='%{text} clients', textposition='outside')
    fig_ca.update_layout(showlegend=False, height=320, margin=dict(t=50, b=10))

    # --- Scatter Fréquence vs Montant ---
    fig_scatter = px.scatter(
        df, x='frequence', y='montant',
        color='segment', color_discrete_map=COULEURS_SEGMENTS,
        size='score_rfm', hover_data=['prenom', 'nom', 'ville', 'score_rfm'],
        title="Fréquence d'achat vs Montant total — par segment",
        labels={'frequence': "Nb commandes", 'montant': "CA total (€)", 'segment': 'Segment'}
    )
    fig_scatter.update_layout(height=400, margin=dict(t=50, b=10))

    return kpis, fig_pie, fig_ca, fig_scatter


@app.callback(
    Output('graph-ca-mensuel', 'figure'),
    Output('graph-top-produits', 'figure'),
    Input('filtre-magasin', 'value')
)
def update_static_graphs(magasin):
    # --- CA mensuel ---
    df_m = df_cmd.copy()
    if magasin != 'Tous':
        df_m = df_m[df_m['magasin'] == magasin]

    df_m_agg = df_m.groupby('mois')['ca_mensuel'].sum().reset_index()
    fig_mensuel = px.line(
        df_m_agg, x='mois', y='ca_mensuel',
        title="Évolution du CA mensuel",
        labels={'mois': 'Mois', 'ca_mensuel': 'CA (€)'},
        markers=True
    )
    fig_mensuel.update_traces(line_color='#0f3460', line_width=2)
    fig_mensuel.update_layout(height=320, margin=dict(t=50, b=10))

    # --- Top 10 produits ---
    fig_produits = px.bar(
        df_produits.head(10), x='total_vendus', y='produit',
        orientation='h', color='categorie',
        title="Top 10 produits vendus",
        labels={'total_vendus': 'Quantité vendue', 'produit': ''}
    )
    fig_produits.update_layout(height=320, margin=dict(t=50, b=10), showlegend=False)

    return fig_mensuel, fig_produits


# ============================================
# 5. LANCEMENT
# ============================================

if __name__ == '__main__':
    print("🚀 Dashboard disponible sur http://127.0.0.1:8050")
    app.run(debug=True)
