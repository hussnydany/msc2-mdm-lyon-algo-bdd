# =============================================================================
# DASHBOARD DASH
# =============================================================================
#
# Ce script cree un dashboard interactif avec Dash et Plotly.
#
# Prerequis :
#   - Avoir execute pipeline.py au moins une fois (pour creer rfm_enrichi)
#   - pip install dash plotly mysql-connector-python pandas
#
# Lancement :
#   python dashboard.py
#   Puis ouvrir http://127.0.0.1:8050 dans le navigateur
#
# =============================================================================
#
# COMMENT CREER UN  DASHBOARD DASH AVEC UN LLM
# =============================================================================
#
# on peut décrire ce que l'on veut afficher a un LLM (ChatGPT, Claude, etc.) et le laisser generer
# le code. Voici le type de prompt a lui donner :
#
#   "Cree un dashboard Dash/Plotly connecte a une base MySQL ecommerce_rfm.
#    La table rfm_enrichi contient : nom, ville, lat, lon, recence_jours,
#    frequence, montant_total, score_r, score_f, score_m, score_total, segment.
#    La vue vue_rfm contient les memes colonnes sans lat/lon.
#
#    Affiche :
#    - 4 KPIs en haut : nombre de clients, CA total, panier moyen, nb segments
#    - Un camembert (donut) de repartition des segments
#    - Un bar chart du panier moyen par segment
#    - Un tableau filtrable par segment avec tri natif
#    - Un classement interactif (choix du critere via radio + slider top N)
#    - Une carte scatter_mapbox des clients positionnee sur la France
#
#    Couleurs par segment :
#      VIP = vert (#2ecc71), Fidele = bleu (#3498db),
#      A reactiver = orange (#f39c12), Endormi = rouge (#e74c3c)
#
#    Style : fond gris clair, cartes blanches avec ombre, police Arial."
#
# =============================================================================


# -----------------------------------------------------------------------------
# IMPORTS
# -----------------------------------------------------------------------------

from dash import Dash, html, dcc, dash_table, Input, Output
import plotly.express as px
import plotly.graph_objects as go
import mysql.connector
import pandas as pd


# -----------------------------------------------------------------------------
# CHARGEMENT DES DONNEES
# -----------------------------------------------------------------------------
# On charge les donnees une seule fois au demarrage de l'application.
# -----------------------------------------------------------------------------

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="<votre-mot-de-passe>",
    database="ecommerce_rfm"
)

df = pd.read_sql("SELECT * FROM vue_rfm", conn)
enrichi = pd.read_sql("SELECT * FROM rfm_enrichi", conn)
conn.close()

# Couleurs par segment
COLORS = {
    'VIP': '#2ecc71',
    'Fidele': '#3498db',
    'A reactiver': '#f39c12',
    'Endormi': '#e74c3c'
}


# -----------------------------------------------------------------------------
# CREATION DE L'APPLICATION
# -----------------------------------------------------------------------------

app = Dash(__name__)
app.title = "Dashboard RFM"

app.layout = html.Div(
    style={'fontFamily': 'Arial', 'margin': '20px', 'backgroundColor': '#f8f9fa'},
    children=[

        # --- TITRE ---
        html.H1(
            "Dashboard RFM - E-commerce",
            style={'textAlign': 'center', 'color': '#2c3e50', 'marginBottom': '30px'}
        ),

        # -----------------------------------------------------------------
        # SECTION 1 : METRIQUES (KPIs)
        # -----------------------------------------------------------------

        html.Div(
            style={'display': 'flex', 'justifyContent': 'space-around', 'marginBottom': '30px'},
            children=[
                html.Div(
                    style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white',
                           'borderRadius': '10px', 'width': '200px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3(f"{len(df)}", style={'color': '#2c3e50', 'fontSize': '36px', 'margin': '0'}),
                        html.P("Clients", style={'color': '#7f8c8d', 'margin': '0'})
                    ]
                ),
                html.Div(
                    style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white',
                           'borderRadius': '10px', 'width': '200px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3(f"{df['montant_total'].sum():,.0f} EUR",
                                style={'color': '#2c3e50', 'fontSize': '36px', 'margin': '0'}),
                        html.P("CA total", style={'color': '#7f8c8d', 'margin': '0'})
                    ]
                ),
                html.Div(
                    style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white',
                           'borderRadius': '10px', 'width': '200px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3(f"{df['montant_total'].mean():,.0f} EUR",
                                style={'color': '#2c3e50', 'fontSize': '36px', 'margin': '0'}),
                        html.P("Panier moyen", style={'color': '#7f8c8d', 'margin': '0'})
                    ]
                ),
                html.Div(
                    style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white',
                           'borderRadius': '10px', 'width': '200px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3(f"{df['segment'].nunique()}",
                                style={'color': '#2c3e50', 'fontSize': '36px', 'margin': '0'}),
                        html.P("Segments", style={'color': '#7f8c8d', 'margin': '0'})
                    ]
                ),
            ]
        ),

        # -----------------------------------------------------------------
        # SECTION 2 : GRAPHIQUES
        # -----------------------------------------------------------------

        html.Div(
            style={'display': 'flex', 'gap': '20px', 'marginBottom': '30px'},
            children=[
                # Camembert a gauche
                html.Div(
                    style={'flex': '1', 'backgroundColor': 'white', 'borderRadius': '10px',
                           'padding': '15px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3("Repartition des segments", style={'textAlign': 'center'}),
                        dcc.Graph(
                            figure=px.pie(
                                df,
                                names='segment',
                                color='segment',
                                color_discrete_map=COLORS,
                                hole=0.4  # donut au lieu de camembert plein
                            ).update_layout(margin=dict(t=20, b=20))
                        )
                    ]
                ),
                # Barres a droite
                html.Div(
                    style={'flex': '1', 'backgroundColor': 'white', 'borderRadius': '10px',
                           'padding': '15px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
                    children=[
                        html.H3("Panier moyen par segment", style={'textAlign': 'center'}),
                        dcc.Graph(
                            figure=px.bar(
                                df.groupby('segment')['montant_total'].mean().round(2).reset_index(),
                                x='segment',
                                y='montant_total',
                                color='segment',
                                color_discrete_map=COLORS,
                                labels={'montant_total': 'EUR', 'segment': ''}
                            ).update_layout(showlegend=False, margin=dict(t=20, b=20))
                        )
                    ]
                ),
            ]
        ),

        # -----------------------------------------------------------------
        # SECTION 3 : FILTRE PAR SEGMENT + TABLEAU
        # -----------------------------------------------------------------

        html.Div(
            style={'backgroundColor': 'white', 'borderRadius': '10px', 'padding': '20px',
                   'marginBottom': '30px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
            children=[
                html.H3("Detail par segment"),
                dcc.Dropdown(
                    id='segment-filter',
                    options=[{'label': 'Tous', 'value': 'Tous'}] +
                            [{'label': s, 'value': s} for s in df['segment'].unique()],
                    value='Tous',
                    style={'width': '300px', 'marginBottom': '15px'}
                ),
                html.Div(id='segment-count', style={'marginBottom': '10px', 'color': '#7f8c8d'}),
                dash_table.DataTable(
                    id='table-clients',
                    columns=[
                        {'name': 'Nom', 'id': 'nom'},
                        {'name': 'Ville', 'id': 'ville'},
                        {'name': 'Recence (j)', 'id': 'recence_jours'},
                        {'name': 'Frequence', 'id': 'frequence'},
                        {'name': 'Montant (EUR)', 'id': 'montant_total'},
                        {'name': 'R', 'id': 'score_r'},
                        {'name': 'F', 'id': 'score_f'},
                        {'name': 'M', 'id': 'score_m'},
                        {'name': 'Total', 'id': 'score_total'},
                        {'name': 'Segment', 'id': 'segment'},
                    ],
                    sort_action='native',
                    page_size=10,
                    style_table={'overflowX': 'auto'},
                    style_header={'backgroundColor': '#2c3e50', 'color': 'white', 'fontWeight': 'bold'},
                    style_cell={'textAlign': 'center', 'padding': '8px'},
                    style_data_conditional=[
                        {'if': {'filter_query': '{segment} = "VIP"'}, 'backgroundColor': '#d5f5e3'},
                        {'if': {'filter_query': '{segment} = "Endormi"'}, 'backgroundColor': '#fadbd8'},
                    ]
                ),
            ]
        ),

        # -----------------------------------------------------------------
        # SECTION 4 : CLASSEMENT INTERACTIF
        # -----------------------------------------------------------------

        html.Div(
            style={'backgroundColor': 'white', 'borderRadius': '10px', 'padding': '20px',
                   'marginBottom': '30px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
            children=[
                html.H3("Classement des clients"),
                html.Div(
                    style={'display': 'flex', 'gap': '40px', 'marginBottom': '15px'},
                    children=[
                        html.Div([
                            html.Label("Trier par :", style={'fontWeight': 'bold'}),
                            dcc.RadioItems(
                                id='sort-criteria',
                                options=[
                                    {'label': ' Montant total', 'value': 'montant_total'},
                                    {'label': ' Frequence', 'value': 'frequence'},
                                    {'label': ' Recence', 'value': 'recence_jours'},
                                    {'label': ' Score total', 'value': 'score_total'},
                                ],
                                value='montant_total',
                                style={'marginTop': '5px'}
                            ),
                        ]),
                        html.Div([
                            html.Label("Top N :", style={'fontWeight': 'bold'}),
                            dcc.Slider(
                                id='top-n',
                                min=3, max=20, step=1, value=10,
                                marks={3: '3', 5: '5', 10: '10', 15: '15', 20: '20'}
                            ),
                        ], style={'width': '300px'}),
                    ]
                ),
                dcc.Graph(id='ranking-chart'),
            ]
        ),

        # -----------------------------------------------------------------
        # SECTION 5 : CARTE
        # -----------------------------------------------------------------

        html.Div(
            style={'backgroundColor': 'white', 'borderRadius': '10px', 'padding': '20px',
                   'marginBottom': '30px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'},
            children=[
                html.H3("Carte des clients"),
                dcc.Graph(
                    figure=px.scatter_mapbox(
                        enrichi,
                        lat='lat',
                        lon='lon',
                        color='segment',
                        color_discrete_map=COLORS,
                        hover_name='nom',
                        hover_data=['ville', 'segment', 'montant_total', 'score_total'],
                        size='montant_total',
                        size_max=20,
                        zoom=5,
                        center={'lat': 46.6, 'lon': 2.5},
                        mapbox_style='open-street-map',
                        height=500
                    ).update_layout(margin=dict(l=0, r=0, t=20, b=0))
                ),
            ]
        ),

        # --- PIED DE PAGE ---
        html.P(
            "Dashboard RFM - Algo & BDD - INSEEC Lyon 2026",
            style={'textAlign': 'center', 'color': '#bdc3c7', 'marginTop': '30px'}
        ),
    ]
)


# Callback 1 : filtre du tableau par segment
@app.callback(
    [Output('table-clients', 'data'),
     Output('segment-count', 'children')],
    [Input('segment-filter', 'value')]
)
def filtrer_segment(segment):
    """
    Quand l'utilisateur choisit un segment dans le menu deroulant,
    cette fonction filtre le DataFrame et met a jour le tableau.
    """
    if segment == 'Tous':
        filtered = df
    else:
        filtered = df[df['segment'] == segment]

    count_text = f"{len(filtered)} clients"
    return filtered.to_dict('records'), count_text


# Callback 2 : classement interactif
@app.callback(
    Output('ranking-chart', 'figure'),
    [Input('sort-criteria', 'value'),
     Input('top-n', 'value')]
)
def classement(critere, top_n):
    """
    Quand l'utilisateur change le critere de tri ou le top N,
    cette fonction retrie le DataFrame et genere un nouveau graphique.
    """
    # Pour la recence un petit nombre = mieux donc on trie en croissant
    ascending = (critere == 'recence_jours')
    df_sorted = df.sort_values(critere, ascending=ascending).head(top_n)

    fig = px.bar(
        df_sorted,
        x='nom',
        y=critere,
        color='segment',
        color_discrete_map=COLORS,
        labels={'nom': '', critere: critere.replace('_', ' ').title()},
    )
    fig.update_layout(
        xaxis_tickangle=-45,
        margin=dict(t=20, b=80),
        showlegend=True
    )
    return fig


# -----------------------------------------------------------------------------
# LANCEMENT
# -----------------------------------------------------------------------------

if __name__ == '__main__':
    print("\n=== Dashboard RFM ===")
    print("Ouvrir http://127.0.0.1:8050 dans le navigateur")
    print("Ctrl+C pour arreter\n")
    app.run(debug=True)
